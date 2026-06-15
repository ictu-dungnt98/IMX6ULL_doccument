# Chapter 41: Pixel Pipeline (PXP)

> Nguồn: `IMX6ULLRM.pdf` — trang 2489–2964

<!-- page 2489 -->

Chapter 41
Pixel Pipeline (PXP)
41.1
Overview
This document describes the micro-architecture for the Pixel Processing Pipeline used to
process graphics buffers or composite video and graphics data before sending to an LCD
display or TV encoder.
It is used to minimize the memory footprint required for the display pipeline and provide
an area and performance optimized to both SDRAM-less and SRAM-based systems.
The PXP integrates of several independent processing stages into a cohesive strategy to
create flexible pixel pipeline.
The PXP combines the following into a single processing engine:
• Scaling
• Color Space Conversion (CSC)
• Secondary Color Space Conversion (CSC2)
• Pixel Conversion Lookup Memory Table (LUT)
• Rotation
• Dithering and Waveform Processing
By integrating multiple blocks, intermediate buffer operations to external memory are
removed, reducing external memory bandwidth, power, and software control complexity.
The PXP block diagram is shown below.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2489

<!-- page 2490 -->

LUT
Composite
Alpha
Blending / 
Color Key
CSC1
AS
Alpha
Surface
Engine
PS
Process
Surface
Scaling
PXFMT
Output 
Buffer
Rotation
2
CSC2
Rotation
Dithering
x3CH
Fetch
with
Data
Array
WFE
ALU
Store
Histogram
Collision
Detection
Data
Swizzle
New
V1 PXP
Blocks
Modified
32-bit
64-bit
MUX
CSC1
Dithering
V2 PXP
Blocks
PXFMT
MUX3
MUX0
MUX1
MUX12
MUX8
MUX11
MUX14
MUX16
MUX17
MUX9
Figure 41-1. PXP Architecture
41.2
Clocks
The following table describes the clock sources for PXP. Please see Clock Controller
Module (CCM) for clock setting, configuration and gating information.
Table 41-1. PXP Clocks
Clock name
Clock Root
Description
clk
axi_clk_root
PXP clock
41.3
Top-level architecture
The PXP consist of several pipelined blocks that perform the video source frame scaling,
color space conversion, alpha-blending/color key algorithm, secondary CSC, pixel
correction, input and/or output rotation, dithering and waveform processing.
Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2490
NXP Semiconductors

<!-- page 2491 -->

The legacy blocks operate within the requirements of the legacy PXP architecture, and
perform operations on either 8x8 or 16x16 pixel blocks in the representative source
buffers. The legacy pipeline operate within the context of two iteration counters that
iterate through the appropriate grid of input blocks to produce the rotated output grid
blocks in scan-line order. The dither blocks included in the legacy pipeline also operate in
a block mode while the waveform processing engines (WFE) will operate in a scan line
format based on the active size.
Figure 41-1 shows the high-level architecture of the scaling, color space conversion,
blending, pixel correction, rotation engines, dithering, waveform processing, along with
histogram. The Alpha Surface Engine fetches one RGB graphics plane alpha surface
(AS). The scaling engine fetches a single processed surface (PS), which can be blended
with the AS surface. The scaling engine also supports an alpha channel for the PS image.
Although the legacy PXP processes NxN pixel macro blocks, each of the AS or PS
surfaces can have any pixel alignment within the output buffer. There are no restrictions
and any pixel coordinates within the output buffer are valid. The upper left origin of the
output buffer is defined as pixel 0,0. The upper left and lower right coordinates for each
of the AS and PS are inclusive within the output buffer.
Figure 41-2 represents a sample output buffer configuration with both an AS and PS
included. The alignment of each AS and PS within the output buffer can be at any
arbitrary pixel locations. For example, the PS has an upper left coordinate (ULC) of 2,2
and a lower right coordinate (LRC) at pixel 13,13. The maximum value for the ULC and
LRC for each of the AS and PS is bounded by the LRC of the output buffer, 15,15 for
this example.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2491

<!-- page 2492 -->

0,0 = Origin Pixel
0
0
2.2
0.8
15
Output Buffer,
Lower Right Coordinate
(LRC) = 15,15
15,15
13,13
15
Figure 41-2. Sample output buffer configuration
The AS engine supports RGB pixel formats, and the PS engine supports ARGB, RGB,
YUV, and YCbCr pixel formats. The CSC1 can be used to convert to RGB pixel formats
so that the PS surface can be blended with the AS surfaces in the compositing engine in
the RGB color space. There are two rotate engines in the PXP pipeline. Rotation can
occur after image composition, at the output of the PS engine, or both. In the first
scenario, all the data produced by the AS and PS engines is rotated. When the rotation
module is programmed to rotate only PS images, the AS is not rotated, and AS pixels are
combined with rotated PS surfaces. The CSC2 unit can convert to any RGB, YUV, or
YCbCr color spaces for final output. Pixels can be corrected using a programmable LUT
resource to achieve any desired pixels effects. For detailed information, please refer to
Output Modes to RGBW4444CFA. The dither engine supports ordered dithering mode in
addition to the standard quantization and pass-through modes. The WFE is a
programmable engine that can be programed as required to process each pixel and pixel
meta data. The Histogram sub-block collects statistics about the pixel data passing
through it that is useful to the EPDC in waveform selection and displaying the frame. The
Histogram also contains mask and comparison functionality that can be used for collision
detection and reporting the collided area within an update area.
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2492
NXP Semiconductors

<!-- page 2493 -->

The PXP also supports two parallel image processing paths. The legacy flow can operate
in parallel with waveform processing engines. Please refer to HW_PXP_CTRL and
HW_PXP_CTRL2 for details on how to enable each of the individual data flows. In
addition to this, LUT engine can be used as either part of the legacy flow or as a part of
the second parallel data flow.
41.3.1
Processing Details
The legacy PXP architecture has been driven primarily by the requirement that the output
buffer must be processed and rotated without intermediate frame buffer stored in external
memory.
This reduces the use of external memory bandwidth requirements thus reducing overall
system power consumed. The new architecture has two sets of fetch and store engines to
enable parallel image processing and the ability to use only parts of the block like the
WFE or parts of the legacy flow.
Since the output of the rotation block must be NxN pixel blocks in scan order, the entire
legacy pipeline will operate on NxN pixel blocks. In essence, the pipeline will be able to
operate on blocks in a random access fashion, but the entire pipeline will operate within
the context of two iteration counters that will iterate through the horizontal and vertical
input blocks to generate the required output block.
Legacy Processing Pipeline
The control block will coordinate the processing of the pixel blocks within the source and
destination image buffers. It begins by issuing a command to each stage of the pipeline
requesting that operations be done for the block at offset x, y. When the block accepts the
command, it asserts its acknowledge signal for a single cycle to indicate the acceptance
and allow the control unit to move to the next block.
When the PS and AS fetch engines have received a command, they will fetch the required
data and place it into their fetch buffers. If compositing the RGB AS surface with the PS
surface, then the output of the PS engine needs to be converted to the RGB color space
using CSC1, since all compositing occurs in the RGB color space. For YUV output pixel
formats, the CSC1 unit can be enabled to convert pixels into the RGB space for
subsequent compositing with AS pixels. Then, the CSC2 module can convert the
resulting pixels back into the YUV output color space. If the final output color space is
YUV and there is no compositing required (AS not present, for example), then both the
CSC units can be bypassed and the pixel data path will pass the YUV pixels to the
rotation engine. For YUV output formats, scaling operations, LUT, rotation, and
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2493

<!-- page 2494 -->

dithering operations are still valid, but blending RGB AS surfaces with YUV PS surfaces
is NOT supported. The two CSC units in the overall pixel data path must be used to
achieve the desired source frame compositing and output pixel formatting.
The alpha blender/color key module will process a pixel any time that both inputs present
valid data.
A handshake will be created between each stage and a pipeline controller to handle the
advance of the pipeline and generation of the iteration counters. The pipeline controller
will also maintain the interlocks with the LCD interface for the case where the LCD
display and pixel processing pipeline use the SRAM to maintain the double buffer block
intermediate buffer.
The New Processing Pipelines
The WFE fetch and store engines work in scan line format. The WFE fetch engine has
internal memory of 32 words where each word is 64 bits. The store engines can co-
ordinate data flow through the pipeline to the next fetch engine such as LCDIF for
display. In handshake mode, the store engine writes data to the memory and signals, the
fetch engine of the next stage that the programmed number of lines are ready to be
fetched.
41.3.2
Scaling Operation
The scaling engine operates on YUV (or YCbCr) 422 or 420 and any RGB formatted
pixels. Each color plane is sourced from color planes indicated by different base address
registers.
The scaling source data can be stored as 3 individual planes for each Y, U, and V data,
stored as two planes as a single Y and interleaved UV plane, or stored as a single plane
with YUV/RGB interleaved on a per byte basis.
The scaled output image is presented to the CSC module as YUV444 or RGB888 pixels
with a single byte for each color channel. The scaler can reduce an input image by a
maximum factor of 16. In this case, the output image will be 1/16 the dimension of the
input image in each of the X and Y axis. There are no limits, essentially, on increasing
the source image size. The theoretical maximum increase is 4096 since a 12 bit fractional
step function is used when scaling an input image. Scaling in either axis, X or Y is
independent, so a source image can appear stretched in either direction.
All source images pass through the scale engine. The PXP alpha blend module and AS
pixel streams are in the RGB888 format, so PS pixel buffers must be converted to the
RGB888 format for alpha blending. The scaling engine works with the CSC1 module to
translate YUV/YCbCr pixel formats to RGB888 for output frame buffer compositing
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2494
NXP Semiconductors

<!-- page 2495 -->

using the alpha blender. The CSC2 module can by bypassed or enabled to convert pixels
to any output color space. In the case of processing RGB pixels in the PS engine. The
CSC1 unit can be bypassed so compositing can occur in the alpha engine.
The scaling operation is divided into two scaling steps. The first step is a decimation
scaler, and the second step is a bilinear filter. The decimation filter provide a maximum
down scaling factor of 8, and the subsequent bilinear filter provides a maximum scaling
factor of 2. Combined, the maximum scaling factor can be up to 16. The decimation and
bilinear scaling engines are independently programmable. There is also an initial offset
that is programmable to allow more source data to be considered in the bilinear scaling
engine.
41.3.3
Decimation Image Scaling
The first of two scaling engines is the decimation filter.
The intent of the decimation filter is to use as much source data as is possible to create
the output image frame buffer. The decimation filter simply discards certain pixels from
the source PS image depending on the reduction selected.
For RGB pixel formats, each color channel is treated equally since there is the same
amount of pixel data within each color plane. For YUV422/420 formats, the chroma
samples are already subsampled by 2. In these decimation scenarios, the chroma
decimation factor is adjusted to account for the pre-decimation of the chroma samples.
For example, since YUV422 is already sub-sampled by 2 horizontally, an X decimation
factor of 2 does not apply to the YUV422 pixels in the X direction. All the chroma
samples are passed on to the bilinear filter in this case. As another example, an X
decimation factor of 4 will decimate the chroma samples by 2, since this factor combined
with the pre-decimation factor of 2 in the pixel source buffers totals an overall decimation
factor of 4.
The following example will show which pixels (in green) in a source RGB buffer that are
passed to the bilinear filter for an X decimation factor of 2 and a Y decimation factor of
4. All pixels coincident with dashed lines are discarded.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2495

<!-- page 2496 -->

Figure 41-3. RGB decimation X /2, Y /4
Using the same decimation factor as the above scenario for RGB pixels, but using
YUV420 source buffers, it can be shown that the decimation factor for the Y and UV
components of data are decimated differently. This is due to the pre-decimation of the
chroma samples in the source frame buffers. Figure 4: YUV420 decimation X /2, Y /4
indicates that the U/V samples in the X direction are not decimated, but the Y samples in
the X direction are decimated by the factor of 2.
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2496
NXP Semiconductors

<!-- page 2497 -->

Y sample only
YUV cosited sample
Figure 41-4. YUV420 decimation X /2, Y /4
41.3.4
Bilinear Image Scaling Filter
The PXP implements a bilinear scaling filter to resize an input image to a different
resolution for display output.
The bilinear filter is a weighted average of the four nearest pixels that can be sourced to
approximate the pixel in the output frame buffer.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2497

<!-- page 2498 -->

When scaling YUV data, the UV values are offset by 0x80 (top bit inverted) to shift the
signed UV bits into an unsigned equivalent with a range of 0 to 255. YCbCr data does not
have to be shifted since it is defined as an unsigned byte. The
REG_CSC1_COEF0[YCBCR_MODE] bit controls whether this operation is applied to
the input UV bytes.
After scaling, the offset is removed so that the range for UV data is signed from -128 to
127.
The reason for this adjustment is based on the implementation of an unsigned scaling
engine, and therefore, is to ensure that the scaled values are handled properly. Consider
the following table:
Format
pixel0
pixel1
average
Result
decimal
-2
+2
0
Correct
CbCr
0x7E
0x82
0x80
Correct (0x80 is 0 in CbCr)
UV
0xFE
0x02
0x80
Incorrect (0x80 is -128 in UV)
decimal
-32
+16
-8
Correct
CbCr
0x60
0x90
0x78
Correct (0x78 is -8 in CbCr)
UV
0xE0
0x10
0x78
Incorrect (0x78 is +120 in UV)
To compute the output pixel value at position as indicated by P, consider the diagram
below.
p00
Px0
4 source image pixel:
p00, p10, p01, p11
Ry
P
1 destination image pixel:
P, bilinear filter
(1-Ry)
p01
Px1
p11
Rx
(1-Rx)
p10
Figure 41-5. Output Pixel Value
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2498
NXP Semiconductors

<!-- page 2499 -->

A step function is used to indicate the position of the pixel "P" in the output frame. This
position may not coincide with a single pixel position in the input frame buffer. In this
case, the four closest pixels in the input frame are used to approximate the value of the
pixel in the output frame.
The PXP scaler first computes a linear filter in the X axis to create the two intermediate
pixel values Px0 and Px1. The step function's X fractional component is used to provide
the weighting factor for blending p00 with p10 to provide Px0. Likewise, Px1 is also
derived from a linear filter using p01 and p11.
The equations for Px0 and Px1 are as follows:
Px0 = p00*(1-Rx) + p10*Rx
Px1 = p01*(1-Rx) + p11*Rx
The PXP scaler uses the intermediate X pixels Px0 and Px1 and implements a bilinear
filter on these two pixel values to produce the final pixel value at position P. The
remainder of the step function for the Y axis is used to compute the weighted average
pixel result. The equation for final filtered pixel is:
P = Px0*(1-Ry) + Px1*Ry
41.3.5
YUV 4:2:2 Image Scaling
The following figure illustrates the positioning of YUV samples for the 4:2:2 formats.
There are twice as many Y luma samples then U and V chroma samples horizontally.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2499

<!-- page 2500 -->

Pixel Column
Scan
Lines
Y, U, V Sample
Y Sample Only
Ps
0
0
1
2
3
4
5
1
2
3
Figure 41-6. YUV Sample Positioning, 4:2:2
Consider the scaled output pixel Ps (pixel scaled) which has an accumulated step function
of X=1.5 and Y=0.5. The remainder for the step function is Rx = 0.5 and Ry = 0.5. Or,
the sub pixel position of output pixel Ps is half way between line 0 and 1 and half way
between column 1 and 2.
The Y output component of Ps is simply the bilinear function of the four nearest Y
samples from the input image. Specifically, the Y values at [1,0], [2,0], [1,1], and [2,1]
are used to compute the Y for Ps.
For the U and V components of Ps, there are no samples present in the column position 1.
The bilinear filter uses chroma components located at [0,0], [2,0], [0,1] and [2,1]. Since
the chroma components are not sub sampled vertically, the remainder used to combine
pixels vertically is Ry=0.5 (the same as for Y). However, horizontally, the scaling engine
shifts the remainder by a factor of 2. So an X axis step function value of X=1.5 has a
remainder Rx=0.75. Source chroma values are not replicated, they are completely
interpolated using the four nearest chroma samples to approximate U and V at Ps.
41.3.6
YUV 4:2:0 Image Scaling
The following figure illustrates the positioning of YUV samples for the 4:2:0 formats.
Chroma is sub sampled both horizontally and vertically. In this format, the chroma frame
buffers contain ¼ the data that the luma frame buffers store.
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2500
NXP Semiconductors

<!-- page 2501 -->

Chroma
Shift/Copy
Pixel Column
Scan
Lines
U, V Sample
Y Sample Only
0
0
1
2
3
4
5
Ps
1
2
3
Figure 41-7. YUV Sample Positioning, 4:2:0
The Y output component for all scaled pixels in 4:2:0 formats are the same as for the
4:2:2 pixel formats.
The U and V output components have two considerations when computing the output
pixel Ps.
1. All chroma samples from the input source image are shifted left and up by ½ a
sample position of the input pixel matrix.
2. Odd scan lines are replicated using the previous even chroma scan line values. So,
output image chroma values that map between even to odd scan lines are replicated
in the vertical axis. In contrast, output image chroma values between odd to even
scan lines are interpolated vertically.
The chroma values are interpolated horizontally as in the 4:2:2 pixel format.
As an example, consider the interpolated pixel Ps in the 4:2:0 diagram above. For the Y
component, the interpolated output luma is a function of the Y values in the source frame
buffer at position [1,0], [2,0], [1,1], [2,1].
For the U and V interpolated samples, the chroma values on scan line position 0.5 are
shifted so that they coincide with the even luma sample points. They are also replicated
so that a single chroma scan line is used twice. The chroma scan line at 0.5 is replicated
to represent the 4:2:2 sample points for scan line 0 and 1. The chroma scan line at 2.5 is
replicated to represent the 4:2:2 sample points for scan line 2 and 3. This pattern of
chroma replication occurs for the entire source frame buffer during the scaling operation.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2501

<!-- page 2502 -->

Chroma
shift/copy
to line 0,1
Scan
Lines
Pixel Column
0
0
1
2
3
1
2
PsB
PsA
0.5
1.5
2.5
Figure 41-8. Scaled Chroma Computation Examples
The preceding diagram has two examples for the computation of the scaled chroma
output pixel. For chroma at output position PsA (vertical position 0.5), interpolation
occurs in the X axis using chroma values at column 0 and column 2. However, since line
0 and line 1 have equal chroma values due to chroma line replication, scaling in the Y
axis results in replication of chroma values.
For chroma at output position PsB (vertical position 1.5), interpolation occurs in both the
X and Y axis. The Y axis is an interpolation since the chroma values copied to scan line 1
and 2 and not the same.
In summary, any output image pixels that map to an odd scan line above and an even
scan line below are interpolated vertically. Output image pixels that map to an even scan
line above and an odd scan line below are replicated vertically.
41.3.7
RGB/YUV444 Image Scaling
For all RGB formats, the RGB pixels are converted up to RGB888 with 8 bits per each
color component.
Then each color component is passed to the scaling engine and each component is treated
in the same manor. The RGB scaling operation is the same as for the Y scaling operation
described in the preceding sections. Also, YUV444 contains a byte for each color plane at
each pixel location, so all three color components are scaled in the same manor.
41.3.8
Color Space Conversion (CSC)
There are two modules in the PXP to convert pixels between color spaces. They are
referred to as CSC1 and CSC2.
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2502
NXP Semiconductors

<!-- page 2503 -->

CSC1 exists after the scaling unit and is dedicated to converting from YUV to RGB.
CSC2 is a full duplex color space converter in that is can convert into either RGB or
YUV (or YCbCr) color spaces depending on the desired output pixel format. All
coefficients are programmed as two's compliment numbers and both CSC units can be
bypassed if CSC is not desired at either position of these CSC units in the pixel data path.
41.3.9
CSC1 Operation
The CSC1 module receives scaled YUV/YCbCr444 pixels from the scale engine and
converts the pixels to the RGB888 color space only if CSC1 is enabled.
The CSC1 module will convert only to the RGB color space and it can be bypassed to
allow YUV pixels through the data path. These pixels are loaded into the pixel FIFO for
processing by subsequent modules in the pixel data path.
The following equations are used to perform YUV/YCbCr -> RGB conversion. The
constants will be stored in the PXP control registers as two's compliment values to allow
flexibility in the implementation and to allow for differences in the video encode and
decode operations. In addition, this provides a software mechanism to manipulate
brightness or contrast.
R = C0(Y+Yoffset) + C1(V+UVoffset)
G = C0(Y+Yoffset) + C3(U+UVoffset) + C2(V+UVoffset)
B = C0(Y+Yoffset) + C4(U+UVoffset)
Note: In the equations above, U and V are synonymous with Cb and Cr in regards to the
color space format of the source frame buffer.
Saturation of each color channel is checked and corrected for excursions outside the
nominal YUV/YCbCr color spaces. Overflow for the three channels are saturated at
0x255 and underflow is saturated at 0x00.
The table below indicates the expected coefficients for YUV and YCbCr modes of
operation:
Coefficient
YUV
YCbCr
Yoffset
0x000
0x1F0 (-16)
UVoffset
0x000
0x180 (-128)
C0
0x100 (1.00)
0x12A (1.164)
C1
0x123 (1.140)
0x198 (1.596)
C2
0x76B (-0.581)
0x730 (-0.813)
C3
0x79B (-0.394)
0x79C (-0.392)
C4
0x208 (2.032)
0x204 (2.017)
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2503

<!-- page 2504 -->

41.3.10
YUV versus YCbCr Support
By default, the PXP color space coefficients are set to support the conversion of YUV
data to RGB data.
If YCbCr input is present, software must change the coefficient registers appropriately
(see the register definitions for values). Software must also set the YCBCR_MODE bit in
the COEFF0 register to ensure proper conversion of YUV versus YCBCR data.
41.3.11
CSC2 operation
The CSC2 module receives pixels in any color space and can convert the pixels into any
of RGB, YUV, or YCbCr color spaces.
All coefficients are programmable and in the two's compliment notation. The output
pixels are passed onto the LUT and rotation engine for further processing.
The following equations indicate the CSC2 modules ALU architecture.
Selecting RGB output in REG_CSC2_CTRL[CSC_MODE] configures the ALU in the
following manor:
R = A1(Y-D1) + A2(U-D2) + A3(V-D3)
G = B1(Y-D1) + B2(U-D2) + B3(V-D3)
B = C1(Y-D1) + C2(U-D2) + C3(V-D3)
Selecting YUV output configures the ALU in the alternate manor:
Y = A1*R + A2*G + A3*B + D1
U = B1*R + B2*G + B3*B + D2
V = C1*R + C2*G + C3*B + D3
Saturation of each color channel is checked and corrected for excursions outside the
nominal color space. Overflow for the three channels are saturated at 0x255 and
underflow is saturated at 0x00.
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2504
NXP Semiconductors

<!-- page 2505 -->

41.3.12
Alpha Blending/Color Key
Regardless of pixel input format, the PS and AS pixels are normalized to 32-bits,
organized as one alpha and three data bytes. Alpha blending occurs in the RGB space, if
blending is required, PS pixels should be converted to RGB space. If no alpha blending is
required, then YUV pixels can bypass the alpha blending ALU without color space
conversion. All pixels are processed by the pixel ALU, but the ALU operations can be
disabled to achieve pixel pass through for either PS or AS or fetch data channels source
pixels.
41.3.13
Alpha Blend
There are two alpha blend modes in this module. First is the normal blending mode using
single alpha parameter. Second is the porter-duff blending mode used in 2D. Both modes
alpha blend modes are described in the sub-sections below.
41.3.13.1
Normal Alpha Blend
The alpha value for an individual pixel represents a mathematical weighting factor
applied to the AS pixel. An alpha value of 0x00 corresponds to a transparent pixel and a
value of 0xFF corresponds to an opaque pixel.
The effective alpha value for an AS pixel is determined by the AS_CTRL[ALPHA] and
AS_CTRL[ALPHA_CTRL] register fields. If AS_CTRL[ALPHA_CTRL] =
ALPHA_OVERRIDE , the alpha value for the pixel is taken from the
AS_CTRL[ALPHA] . This can be useful for applying a constant alpha to an entire image
or for image formats that don't include an alpha value. If AS_CTRL[ALPHA_CTRL] =
ALPHA_MULTIPLY, the pixel's alpha value will be multiplied by the pixel's ALPHA
value in order to allow scaling of the pixel's alpha or to provide better control for pixel
formats such as RGB1555, which only contains a single bit of alpha.
For each color channel, the equation used to blend two source pixels is defined below:
Gá = PIO programmed global alpha (8-bit value).
Eá = Embedded alpha associated with AS pixel.
á = Gá * Eá + 0x80
The result for the red channel as an example:
R[7:0] = (á * PS.r) + ((1 - á) * AS.r)
When á is 0xff, the PS pixel will not be blended with the AS pixel, but PS will be passed
as the output pixel and will not be blended with AS. In this case, AS will be discarded.
Likewise, if á is 0x00 for a given pixel, PS will be loaded as the output pixel.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2505

<!-- page 2506 -->

AS_CTRL[ALPHA_INVERT] provides the option to invert the final alpha value. This
essentially inverts the effect the alpha value has on the AS and PS blending operation.
41.3.13.2
Porter-Duff Alpha Blend
Porter-Duff blend includes 12 blending modes to describe digital image composite. These
processes include Clear, Source Only, Destination Only, Source Over, Source In, Source
Out, Source Atop, Destination Over, Destination In, Destination Out, Destination Atop
and XOR. Through these process it can achieve any 2D image composite.
To control the blending modes, please see below picture. All the registers showed below
are included in HW_PXP_ALPHA_A_CTRL.
s0_alpha
s0_alpha'
s0_alpha''
s01_alpha
s0_global_alpha
s0_pixel
s0_pixel'
s0_alpha_mode:
0: s0_alpha
1: 0xFF-s0_alpha
s0_global_alpha_mode:
0: s0_global_alpha
1: s0_alpha
2: s0_alpha' * s0_global_alpha
3: s0_alpha' * s0_global_alpha
s0_s1_factor_mode:
0: 0xFF
1: 0
2: s0_alpha''
3: 0xFF-s0_alpha''
s0_color_mode:
0: s0_pixel
1: s0_pixel * s0_alpha''
s1_alpha
s1_alpha'
s1_alpha''
s10_alpha
s1_global_alpha
s1_pixel
s1_pixel'
s1_alpha_mode:
0: s1_alpha
1: 0xFF-s1_alpha
s1_global_alpha_mode:
0: s1_global_alpha
1: s1_alpha
2: s1_alpha' * s1_global_alpha
3: s1_alpha' * s1_global_alpha
s1_s0_factor_mode:
0: 0xFF
1: 0
2: s1_alpha''
3: 0xFF-s1_alpha''
s1_color_mode:
0: s1_pixel
1: s1_pixel * s1_alpha''
Figure 41-9. Porter-Duff Alpha Blend
41.3.14
Color Key
The color key function is provided to create transparent effects on the output pixel.
Color keying is applied on the input pixels after they are converted to 8-bits for each red,
green, and blue color channels (color keys are not applied directly to 16-bit pixel formats
but to their corresponding 24-bit representation). A color key range is programmable for
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2506
NXP Semiconductors

<!-- page 2507 -->

both PS and AS pixels. If the PS 24-bit pixel is within the PS color key range, then AS is
passed through the pixel pipeline. In this case, alpha blending does NOT occur.
Conversely, if PS is within the AS color key range, then PS is passed via the PXP data
pipeline. If both PS and AS color key tests pass, then the back ground color register is
passed onto following PXP processing components in the pipeline.
The condition for color keying to be satisfied is:
CK0.r.low <= PS.r <= CK0.r.high
CK0.g.low <= PS.g <= CK0.g.high
CK0.b.low <= PS.b <= CK0.b.high
For example, if the "red" 8-bit value for the PS pixel (or PS.r) is between the color key
low and high values (CK0.r.l and CK0.r.h), the condition is true for the red color plane.
When ALL three color planes meet this condition, then only the PS pixel is loaded into
the output register.
To disable color keying, program the low color key register value to 0xff and the high
value to 0x00. This will guarantee that the color key range test will never be true.
41.3.15
LUT
The lookup table (LUT) is used to modify pixels in a manner that is not linear and that
cannot be achieved by the color space conversion modules.
Nonlinear response to the input pixels can be achieved based on how the lookup table is
programmed.
Programming of the direct access LUT table can be facilitated by single PIO register
writes or DMA access. For efficient loading of the LUT, DMA access should be used.
41.3.16
Lookup Modes
The LUT has four lookup modes. The lookup modes determine how the src_pixel is used
to address the LUT memory.
The four lookup modes are:
1. DIRECT_Y8
2. DIRECT_RGB444
3. DIRECT_RGB454
4. CACHE_RGB565
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2507

<!-- page 2508 -->

The DIRECT modes access the LUT memory as a monolithic SRAM. The
CACHE_RGB565 will access the memory as a 2-way set associative cache.
41.3.17
DIRECT_Y8
DIRECT_Y8 is used for a 256-byte lookup. In DIRECT_Y8, the most significant byte of
the pixel is used to address the LUT entry.
This byte reflects the Y/R channel of the pixel data path. Luma, or monochrome,
transformations are possible with this lookup mode. The address is generated as:
src_pixel[23:16]. In DIRECT_Y8 operation, the memory is byte addressable.
41.3.18
DIRECT_RGB444
DIRECT_RGB444 is used for a 8KB (4K pixel) RGB444 to RGB565 lookup.
Pixel formats that are in the YUV color space at the position of the LUT in the PXP data
path can also be converted. To take advantage of the full 16KBmemory, the
REG_LUT_CTRL[SEL_8KB] bit can be used to select the upper or lower 8KB memory,
thus facilitating the use of 2 separate 444 LUT tables. In DIRECT_RGB444, the
src_pixel is RGB/YUV[23;0] data is used to generate the lookup address. The address is
generated as: {R/Y[23:20],G/U[15:12],B/V[7:4]}. In DIRECT_RGB444, the memory is
pixel (2 byte) addressable.
41.3.19
DIRECT_RGB454
DIRECT_RGB454 is used for a 16KB (8K pixel) RGB454 to RGB565 lookup.
Pixel formats that are in the YUV color space at the position of the LUT in the PXP data
path can also be converted. In DIRECT_RGB454, the src_pixel is RGB/YUV[23;0] data
is used to generate the lookup address. The address is generated as: {R/Y[23:20],G/
U[15:11],B/V[7:4]}. In DIRECT_RGB454, the memory is pixel (2 byte) addressable.
41.3.20
CACHE_RGB565
The CACHE_RGB565 lookup is used for a 128KB (65K pixel) RGB/YUV565 to RGB/
YUV565 lookup.
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2508
NXP Semiconductors

<!-- page 2509 -->

The 128KB memory requirement is too costly from an area perspective to implement a
complete lookup table in the LUT's on chip memory. For this reason, a LRU (least
recently used) 16KB 2-way set associative cache has been implemented to reference the
full 128KB lookup table stored in external memory.
The 2-way set associative cache is organized in the following way:
• 16KB total data storage
• 512 entries split between 256 ways
• 6 pixels/entry cache line
Cache efficiency is very critical. For a cache miss, the PXP will be stalled until the cache
line can be filled. For a 32 bit DDR memory interface, the latency can be calculated as
follows:
# cycles latency for read command through DDR controller + CAS Latency + # burst
cycles for read data to be returned + # cycles latency for data through DDR controller to
LUT + 1 cycle for cache access of new data
The src_pixel is RGB[23:0] data used to generate the lookup address. To improve the
cache efficiency the RGB/YUV565 address and the lookup table must be formatted in the
following way:
Address: A[15:0] = R7G7G6B7 R6G5B6 R5G4B5 R4G3B4 R3G2B3
The address is organized as follows:
• A[15:12] tag address, used to compare a hit between cache ways
• A[11:4] index address, used to select cache set (i.e. row of memory)
• A[3:0] block address, used to select Pixel in the cache line
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2509

<!-- page 2510 -->

Address
Index
Way 1
2-Way Set Associative Cache
Valid
Tag
Data
(16 Pixels)
0
1
2
3
N-2
N-1
Valid [Index]
Address[tag bits] = Tag[index]
Hit
Data
Pixel 0
Data
Pixel 1
Data Selection
Valid [Index]
Address[tag bits] = Tag[index]
address (block bits)
Pixel Data
Data
Pixel 14
Data
Pixel 15
Way 2
Valid
Tag
Data
(16 Pixels)
Figure 41-10. 2-Way Set Associative Cache and Data Selection
41.3.21
Output Modes
The LUT has three output modes for color space conversion.
1. Y8
2. RGBW4444CFA
3. RGB888
41.3.22
Y8
With out_mode set to Y8, in conjunction with DIRECT_Y8 lookup mode, the intended
operation is Gama Correction.
Only the third byte is processed by the lookup table. The third byte is represented by the
Y value or the R value in the data path since pixel data is either YUV[23:0] or
RGB[23:0] where the Y or R byte encompass bits [23:16] respectfully. So, bits 15:0 are
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2510
NXP Semiconductors

<!-- page 2511 -->

always bypassed and left unchanged. Currently, the LUT is intended to process Y data
when any YUV, Y8, or Y4 output pixel formats are selected. However, this resource can
be enabled and used for any conceivable purpose.
Note: When the DIRECT_RGB444, DIRECT_RGB454 or CACHE_RGB565 lookup
mode is selected in conjunction with the Y8 output mode the low order byte of the two
bytes read from the LUT memory will be used as the Gama Correction value.
41.3.23
RGBW4444CFA
With REG_LUT_CTRL[OUT_MODE] set to RGBW4444CFA, the REG_CFA[DATA]
is used to select one nibble from the LUT 16 bit output value.
The LUT memory lookup will contain a RGBW4444 value. The REG_CFA[DATA] will
select the R,G,B or W nibble as the pixel value to present to the PXP data path based on
the matrix defined by the REG_CFA[DATA] register. The 4 bit value is presented in the
Y, or third byte lane, of the PXP data path. The final pixel transferred to the next PXP
stage is {CFA[3:0],CFA[3:0],LUT[15:0]}
41.3.23.1
CFA Correction
The 32-bit REG__CFA[DATA] register is used to encode 16 CFA correction values.
The CFA correction values are encoded as follows:
• 00 selects R
• 01 selects G
• 10 selects B
• 11 selects W
The CFA correction uses 4x4 block processing. Figure 5; CFA mapping translation
shows how CFA 4x4 blocks will iterate over the PXP's 8x8 or 16x16 pixel block being
processed:
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2511

<!-- page 2512 -->

CFA Blocks
2
1
5
13
5
9
13
1
5
1
9
13
1
5
9
13
0
4
12
4
8
12
0
4
0
8
12
0
4
8
12
3
7
15
7
11
15
3
7
3
11
15
3
7
11
15
2
6
14
6
10
14
2
6
2
10
14
2
6
10
14
1
9
13
5
9
13
1
5
1
9
13
1
5
9
13
0
1
4
8
12
4
8
12
0
4
0
8
12
0
4
8
12
5
9
13
5
9
13
1
5
1
9
13
1
5
9
13
6
10
14
6
10
14
2
6
2
10
14
2
6
10
14
7
11
15
7
11
15
3
7
3
11
15
3
7
11
15
4
8
12
4
8
12
0
4
0
8
12
0
4
8
12
2
6
14
6
10
14
2
6
2
10
14
2
6
10
14
3
7
15
7
11
15
3
7
3
11
15
3
7
11
15
0
4
12
4
8
12
0
4
0
8
12
0
4
8
12
1
5
13
5
9
13
1
5
1
9
13
1
5
9
13
2
6
14
6
10
14
2
6
2
10
14
2
6
10
14
3
7
15
7
11
15
3
7
3
11
15
3
7
11
15
3
0
5
10
9
8
11
10
11
8
9
10
11
HW Reg Bits
4x4 CFA block processing across
16x16 pixel block
3
2
1
0
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
31 30 29 28
..........................
Figure 41-11. CFA mapping translation
41.3.24
RGB888
With out_mode set to RGB888, the memory output data is interpolated from RGB565 to
RGB888.
The RGB[23:0] data is formatted as follows: R[7:3]R[7:5],G[7:2]G[7:6],B[7:3]B[7:5].
41.3.25
Rotation
Rotation can occur after compositing the AS and PS buffers in the output stage.
To rotate graphics, the hardware must read pixels in one direction across a frame buffer
and write them in a alternate orientation. For the 90 and 270 degree cases, this means that
lines of pixels must either be read or written vertically in a frame buffer.
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2512
NXP Semiconductors

<!-- page 2513 -->

Destination buffer
Source buffer
Note that fetches from the source buffer are from non-incrementing
addresses, and are thus very inefficient from a bus memory controller
standpoint.
Figure 41-12. Rotation Read and Write
In order to rotate efficiently, multiple columns must be rotated to enable the engine to
both fetch and store bursts of pixels, thus improving memory performance. The simplest
method of doing this is to operate on square blocks of pixels. To rotate the image, each
sub-block of pixels must be rotated by the required rotation angle.
When multiple lines are read from the source buffer, data can be both 
read and written as bursts to the memory controller. In this example, 
photos are read in a 4x4 pixel block and rotated, 
improving memory efficiency.
Source buffer
Destination buffer
Figure 41-13. Rotated Sub-blocks
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2513

<!-- page 2514 -->

To manage the rotation process, the source image can be broken into a grid of sub-blocks
that have coordinates as shown in the diagram below. In addition to rotating the sub-
block, each block must be translated to a new coordinate location. For each of the
rotation angles (0, 90, 180, 270), it is possible to define a simple algorithm for computing
the new translated grid address. The hardware must then simply compute the memory
address from the base grid address for both load and store operations.
When the image is broken into a grid and sub-blocks, each sub-block can 
be numbered with a coordinate. In addtion to being rotated, each 
sub-block is translated to a new grid coordinate. The new coordinate can 
easily be calculated from the source coordinate and the angle of rotation.
0.0
0.1
1.1
2.1
2.2
1.2
0.2
3.2
3.1
3.0
2.0
Source buffer
Destination buffer
1.0
0.0
1.0
2.0
2.1
1.1
0.1
0.2
1.2
2.2
2.3
1.3
0.3
Figure 41-14. Grid of Sub-Blocks with Coordinates
In order to balance the requirements of reasonable burst sizes to the memory controller as
well as keep the hardware storage requirements to a minimum, the blending/rotation
engine will operate on either 8x8 or 16x16 pixel blocks. When using the Rotate engine
with the input fetch engine, you need to program the input fetch engine to work in 8x8
block mode.
NOTE
An important artifact of the PXP is when rotating a source
image and the output is NOT divisible by the block size
selected. The output engine essentially truncates any output
pixels after the desired number of pixels has been written. Since
the output buffer is written as a horizontal row of blocks, the
incorrect pixels could be truncated and the final output image
can look shifted. In the case where the block size is
programmed to 8x8, and the output size that is programmed is
12x12, then there is a remainder of 4 pixels that will be
truncated in either the X and/or Y axis when the PXP operation
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2514
NXP Semiconductors

<!-- page 2515 -->

is complete. The output will be shifted by 4 pixels in this
example. To compensate for this, the source base address needs
to be adjusted so the correct pixels get truncated and the image
does not look shifted. In this example, with 90 degrees of
rotation, the PS base address should be adjusted by 4 times the
actual PS base address -(4*pitch).
41.3.26
Output Buffer
The output buffer engine accepts data from the PXP pixel pipeline and issues requests to
transfer the output pixels to external DRAM or the internal SRAM double buffer row of
blocks.
41.3.27
Address calculator
Each of the blocks will manage its own fetch address using a common address calculator
block that computes real addresses from a base address and relative block offset from the
base.
Each block will then perform the multiple line fetches (or stores) required to perform the
operation. This hides all the address buffer computations from the processing blocks and
allows each block to simply track the coordinate of the block it is working on.
41.3.28
Block size selection
The PXP can be configured to process blocks that are either 8x8 pixels or 16x16 pixels
with the REG_CTRL[BLOCK_SIZE] control bit.
When selecting a 16x16 pixel block size, the accesses to fetch AS and PS images and
write the final frame buffer are more efficient since twice as much data is requested and
processed per memory request.
When optimizing the system for memory bandwidth and image processing time,
configure the PXP to process 16x16 pixel blocks.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2515

<!-- page 2516 -->

41.3.29
Interlaced Video Support
The PXP has some minimal ability to generate interlaced video content from a
progressive source. There two available options, based on the bandwidth requirements
and how software is managing video frames.
The PXP can either interlace on the input side (by reading every other line of input data)
or on the output side (by writing the individual lines of video into two separate fields).
Generally, output interleaving should be used since it is the most flexible mode (it allows
scaling and full overlay support) and it only requires a single pass of the PXP to generate
two separate output fields.
Input interleaving can be beneficial in cases where the PXP is running at 60fps, since it
requires fewer fetches to produce the output data. There is no direct hardware support for
input interleaving, in that, there is no configuration bit that can be set to alter how the
PXP processes a frame for input interleaving. Input interleaving is achieved by simply
setting the source frame buffer pitch value to twice the value it would normally be set to
for the equivalent progressive frame. The output parameters also need to be consistent
with the desired processing effect. For example, the vertical resolution would be set to
account for the reduced resolution to process the interlaced input buffers.
41.3.30
LCDIF Handshake
The PXP and LCDIF support a mode where the internal SRAM can be used for the frame
buffer to minimize external memory bandwidth required.
This is accomplished by creating two buffers in SRAM, a double buffer row of blocks,
where each correspond to 8/16-lines of the frame buffer. The buffers must be consecutive
and allocated as a single block of data.
Buffer in OCRAM
Buffer0 (width*[4/8/16]*bpp)
rgbptr
Buffer1 (width*[4/8/16]*bpp)
Figure 41-15. Buffer in OCRAM
The storage required can be calculated for an 8x8 block size as
• storage = 16 (lines) * rotated_row_length * pixel_size
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2516
NXP Semiconductors

<!-- page 2517 -->

and for 16x16 block size as
• storage = 32 (lines) * rotated_row_length * pixel_size
where pixel_size = 4 for 32bpp or 2 for 16bpp modes. The following table lists the
storage requirements for common image sizes using 8x8 block size:
Image Size
Storage (16bpp)
Storage (24bpp)
Storage (32bpp)
320x240 (QVGA) - 0/180 rotation
10KB
15KB
20KB
320x240 (QVGA) - 90/270 rotation
7.5KB
11.5KB
15KB
640x480 (VGA) - 0/180 rotation
20KB
30KB
40KB
640x480 (VGA) - 90/270 rotation
15KB
22.5KB
30KB
The following diagram shows how the minimal rotation buffer would be organized. As
the engine and LCD progress down the image, they continually swap roles of filling and
emptying each eight-line buffer.
Source buffer
0.0
1.0
2.0
3.0
3.1
2.1
1.1
0.1
0.2
1.2
2.2
3.2
Destination buffer
LCD
Reads
The LCD controller (our output scaner) would read one buffer as the
blending rotation angle files the second buffer. In this manner, the 
entire rotated frame buffer need not be written to memory.
0
1
0.1
1.1
2.1
2.0
1.0
0.0
Figure 41-16. Minimal Rotation Buffer Organization
When this mode is enabled, the PXP will process one row of pixel blocks and write the
results to the first SRAM buffer (buffer 0). The PXP will then alternate between writing
subsequent rows to buffer 0 and buffer 1. After the PXP generates the data for one buffer,
the LCDIF will begin reading that buffer and send the contents to the display device.
Once the LCDIF finishes reading a buffer, it will start displaying from the other buffer
while the PXP continues filling the previously processed buffer.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2517

<!-- page 2518 -->

PXP
LCDIF
B0
B1
B0
B0
B1
B1
B0
B1
Render Into
Display from
b0 ready
b1 ready
b0 ready
b1 ready
b0 done
b1 done
b0 done
b1 done
Figure 41-17. PXP and LCDIF Buffer Sharing
To accomplish the buffer sharing, the PXP and LCDIF will maintain buffer status using a
pair of handshake signals. When a buffer is filled by the PXP, it will assert the
pxp_lcdif_bx_ready (where x is 0 or 1) signal to indicate to the LCDIF that the buffer has
valid data. The LCDIF will then release the buffer by asserting the lcdif_pxp_bx_done
signal.
The basic protocol is shown in the diagram below:
Clk
lcdif_pxp_b0_done
pxp_lcdif_b0_ready
Figure 41-18. Buffer Sharing Protocol
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2518
NXP Semiconductors

<!-- page 2519 -->

The PXP will continue to assert the bx_ready signal until the corresponding bx_done
signal is sampled high for one clock cycle. It will then deassert the bn_ready until the
next time the buffer has been filled. After the PXP samples the bx_done signal asserted, it
is free to begin filling the buffer with the next block size lines of display data. If a buffer
has not been released when the PXP is ready to process data for that buffer, it will
suspend rendering operations until the buffer has been released by the LCDIF.
41.3.31
LCDIF Abort
When the memory subsystem is not loaded, the PXP should be able to render the buffers
faster than the LCDIF can drain the buffers.
It is possible under some scenarios (high LCDIF output rates with high memory latency)
that the PXP may not be able to keep up with the LCDIF, even in the SRAM mode of
operation. When this happens, the LCDIF will signal that it has completed one of the
buffers before the other has been rendered by the PXP. This condition will be detected by
the PXP's control logic as an "LCDIF Abort", which will cause the PXP to abort
processing in the current row and proceed to the following row. It will acknowledge the
abort to the LCDIF by raising the buffer_ready signal for the current buffer to enable the
LCDIF to begin displaying the partially-filled buffer. While an abort will create artifacts
in the video display, it does minimize the artifacts by limiting them to the remaining
pixels blocks in the current row versus ruining the entire frame buffer.
clk
pxp_lcdif_b0_ready
lcdif_pxp_b0_done
pxp_lcdif_b1_ready
lcdif_pxp_b1_done
LCDIF Abort
Figure 41-19. LCDIF Abort
41.3.32
Theory of Operation
The PXP can be used to accelerate graphics operations by offloading graphics processing
from the processor. The block can perform alpha blending and color key substitution on
two RGB graphics buffers.
The PXP is organized as having a processed surface (PS) and an alpha surface (AS) that
can be blended with the processed surface. There are no restrictions on the location of the
AS or PS within the output surface (OS). As the PXP processes NxN blocks, operations
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2519

<!-- page 2520 -->

are performed on a pixel by pixel basis. The AS and PS pixels are alpha blended, color
keyed, process by CSC and LUT resources as individual pixel components. This allows
efficient block processing with supporting arbitrary alignment for both the AS and PS
surfaces. The resulting pixel block is then written to the corresponding block in the
output buffer.
41.3.33
Pixel Handling
All pixels are internally represented as 32-bit values regardless of input or output pixel
formats. The pixels get converted in the AS and PS buffer engines to 24-bit pixel values.
There is also an 8-bit alpha value at stages up to the alpha blender within the PXP for
blending within the RGB color space. Compositing of AS and PS images can only occur
in the RGB color space. If compositing is not required, then YUV pixels can be
transferred and processed at all PXP pixel resource components.. The color orientation of
pixels within the PXP can be controlled by the CSC1, CSC2 , and LUT resources.
For RGB, input pixels are converted into 22-bit pixel values using the following rules for
both AS and PS:
1. 32-bit ARGB8888 pixels are read directly with no conversion.
2. 32-bit RGB888 pixels are assumed to have an alpha value of 0xFF (full opaque).
3. 6-bit RGB565 and RGB555 values are expanded into the corresponding 24-bit color
space and assigned an alpha value of 0xFF (opaque). The expansion process
replicates the upper pixel bits into the lower pixel bits (for instance a 16-bit RGB555
triplet of 0x1F/0x10/0x07 would be expanded to 0xFF/0x84/0x39).
4. 16-bit RGB1555 values are expanded into the corresponding 24-bit color space and
assigned an alpha value of either 0x00 or 0xFF, based on the 1-bit alpha value in the
pixel. The ALPHA_MULTIPLY function is useful in this scenario to allow scaling
of the opaque pixels to a semi-transparent value.
Alpha values can be passed through the entire PXP data path and output in ARGB888
and ARGB555 pixel modes. Also, output pixels can be assigned an alpha value using the
REG_OUT_CTRL[ALPHA] register. 16-bit pixels values are formed from the most
significant bits of the 24-bit pixel values.
When YUV/YCbCr output formats are selected, all pixels are internally represented as
either RGB or YUV pixels values. The CSC2 or LUT can convert internal RGB/YUV
pixels into the correct output format. In this way, any PS color space can be blended with
AS RGB pixels and output in any color space.
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2520
NXP Semiconductors

<!-- page 2521 -->

41.3.34
Output Buffer Composition
The output buffer will be rendered by composing each pixel block from the associated PS
and AS buffers.
The AS pixel buffer can be blended or color-keyed with the associated data from the PS
buffer (either the PS image pixels or REG_PS_BACKGROUND register based on PS
programmed coordinates).
0.0
1.0
2.0
3.0
4.0
5.0
Output Buffer
0.1
1.1
2.1
3.1
4.1
5.1
0.2
1.2
2.2
3.2
4.2
5.2
0.3
1.3
2.3
3.3
4.3
5.3
0.4
5.4
4.4
3.4
2.4
1.4
Background Color
PS Buffer
ULC=0.3
LRC-47.31
AS Buffer
ULC=4.27
LRC=43.39
Figure 41-20. Output Buffer Composition
41.3.35
PS Image Processing
As the PXP processes image buffers, it iterates over the output buffer by fetching the
corresponding input buffer blocks and processing the pixels embedded in these.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2521

<!-- page 2522 -->

41.3.36
Letterboxing
At each pixel coordinate, the control logic determines if the PS pixel (argument also
applies to AS pixels) will be used in rendering the output pixel.
This is determined by checking the output pixel's coordinates against the
REG_OUT_PS_ULC and REG_OUT_PS_LRC (ULC and LRC in short) register
contents. For pixels outside this region, the PS pixel will be loaded with the pixel value
from REG_PS_BACKGROUND, which can be used to effectively control the
letterboxing color. There are no block size or block boundary restrictions when setting
the ULC or LRC for either the AS or PS. The only restriction is that the ULC and LRC
are within the OUT LRC extents.
PS_ULC(x,y)
PS Image
PSBACKGROUND_COLOUR PS_LRC(x,y)
OUT_LRC(x,y)
OUT Buffer
The region outside the PS coordinates will
be filled with the value specified in the 
PSBACKGROUND register.
Figure 41-21. OUT Buffer
41.3.37
Clipping source images
A subset of the PS buffer can be used in rendering the output buffer. The PXP_PS_BUF
register can indicate an offset into the PS buffer that will be used for display within the
OUTPUT buffer.
The pixel at the address defined in the PXP_PS_BUF register will be the pixel that is
displayed at the pixel coordinate indicated by PXP_OUT_PS_ULC within the output
buffer. Essentially, the PXP_PS_BUF register can be used to establish an offset into the
PS buffer thus clipping all PS buffer pixels that are at a lower address. The
PXP_PS_PITCH will always indicate the number of bytes that are vertically adjacent in
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2522
NXP Semiconductors

<!-- page 2523 -->

the PS buffer. The settings in the PXP_PS_BUF, PXP_OUT_PS_ULC, and
PXP_OUT_PS_LRC will determine the subset of the PS buffer, or clipped PS source
buffer, that will be used in the output buffer.
It is important to note that when scaling the PS buffer, the coordinates of the PS buffer
within the output buffer need to be consistent with the scaling factors and original PS
buffer size.
PS width
Actual PS
base addr
Offset PS
base addr
PS Buffer
PS_ULC
Clipped PS Region
LRC_X_ULC_X
LRC_Y_ULC_Y
PS height
OUT Buffer
OUT width
OUT height
PS_LRC
OUT_LRC
Subset of PS is sourced and
dispalyed in OUT buffer. No 
scaling is applied.
OUT base
addr
Figure 41-22. PS Buffer Scaling
When sourcing a subset of the PS image, it should fall completely within the PS buffer to
avoid displaying incorrect data. The following conditions should be met:
x_base_addr_offset + x_scale * (LRC_X-ULC_X) <= PS_pitch
y_base_addr_offset + y_scale * (LRC_Y-ULC_Y) <= PS_size
The PXP hardware does not check for these conditions and will render the image as
programmed. The following case could indicate invalid programming parameters for the
PXP:
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2523

<!-- page 2524 -->

PS width
Actual PS
base addr
Offset PS
base addr
PS Buffer
PS_ULC
LRC_X_ULC_X
LRC_Y_ULC_Y
PS height
OUT Buffer
OUT width
OUT height
Incorrect programming can extend outside
the PS buffer in the both directions. This
is depicted by the red and burgundy
regions in this example.
data aliases to here
Figure 41-23. Example with Invalid Parameters
41.3.38
Color Key Processing
Pixels may be made transparent to the corresponding AS by using the PS color key
registers.
If a PS pixel matches the range specified by the REG_PS_COLORKEYLOW and
REG_PS_COLORKEYHIGH registers, the pixel from the associated AS will be
displayed. If no AS is present for the pixel, a black pixel will be generated since the
default AS pixel is 0x00000000 (transparent black pixel).
The most common use for this is when a bitmap does not support an alpha-field or for
applications such as "green screen" where an image is substituted for a solid background
color .
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2524
NXP Semiconductors

<!-- page 2525 -->

Figure 41-24. The PS image (player) and AS image (stadium)
The green portion of the background image can be color keyed to display the contents of
the AS buffer for locations that match the color range. For this example, the color range
is:
PS Colorkey: 00<R<80 70<G<ff 00<B<80
The resulting image becomes:
Figure 41-25. Resulting Image
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2525

<!-- page 2526 -->

41.3.39
In Place Processing (PS buffer is destination buffer)
The PXP also has the ability to process an image and write the resulting buffer back to
the original PS buffer. This is referred to as "in place" rendering.
This could be useful for basic blit operations into the PS buffer. IN_PLACE operations
are achieved by programming the OUT base address to the pixel location in the PS buffer
that marks the upper left pixel of the update region. The actual region that is updated
should be indicated by programming the ULC = (0,0) and the LRC = (X,Y). The region
bounded by the coordinates will be updated, and the rest of the PS buffer will not be
modified.
41.3.40
Alpha Surface (AS) Processing
The AS surface has a complete set of registers that determines how the AS effects the
final OUT surface.
Most of the registers that exist for the PS surface also are defined for the AS surface
where applicable. This is provided to replicate the SW interface for each PS and AS
processes.
41.3.41
Alpha Handling
Alpha values in the AS are embedded in the source image pixels. For AS pixel formats
that do not support an alpha value, the pixel is assigned an alpha value of 0xFF (opaque).
This can be modified by the AS control by setting either the ALPHA_MULTIPLY or
ALPHA_OVERRIDE bit in the associated AS_CTRL register. If ALPHA_MULTIPLY
is enabled, the 8-bit ALPHA value from the AS_CTRL register is multiplied by the
source alpha before blending with the PS image. If the ALPHA_OVERRIDE bit is set,
the 8-bit ALPHA value is simply substituted for the pixel.
41.3.42
Color Key Processing (AS_CTRL)
The AS_CTRL register also contains an ENABLE_COLORKEY bit that can be used to
enable or disable color key substitution for the AS.
Top-level architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2526
NXP Semiconductors

<!-- page 2527 -->

When enabled, the pixel values are compared to the ASCOLORKEYLOW and
ASCOLORKEYHIGH registers to determine if a match has occurred. When an AS pixel
matches the color key range, the pixel from the AS image is considered transparent and
the corresponding PS pixel is rendered. If both the PS and AS pixels match their
corresponding color key ranges, the AS pixel is displayed unmodified.
AS color keys are handled in a manner similar to PS color keys. The same images used in
the PS color key example could be used with the images swapped. In this case, matches
on the AS image to the ASCOLORKEY register would display the PS pixels.
41.4
Output Image Processing
Several PXP options affect the resulting output image.
41.4.1
Output Image Size
The PXP generates an output image in the resolution programmed by the
REG_OUT_LRC. As the PXP processes pixels, it iterates over the NxN blocks (in output
scan-block order) based on the final image resolution.
41.4.2
Output Format
The result of PXP operations are written to the buffer pointed to by the REG_OUT_BUF/
REG_OUT_BUF2 registers. The pixel format is controlled by the
REG_OUT_CTRL[FORMAT] bit-field.
32-bit pixels are formed directly from the internal 24-bit representations and 16-bit pixel
formats are generated by truncating the internal 24-bit values to the appropriate number
of bits. For formats supporting an alpha value, the PXP assigns the alpha using the 8-bit
value in the REG_OUT_CTRL[ALPHA] field. For ARGB1555, the most significant
alpha bit is appended to the output pixel. Also, for ARGB4444, the most significant
nibble is appended to the output pixel. Single and dual buffer YUV output formats are
also available. Since each pixel in the data path is represented by a full YUV444 24bpp
value, decimation reduces the output in cases of YUV422/420 output formats.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2527

<!-- page 2528 -->

41.4.3
Rotation/Flip operations
The PXP supports four rotation angles in conjunction with vertical and horizontal flip
options. The flip operations effectively take place before the rotation.
Rotations of 0, 90, 180, and 270 degrees are supported and any combination of rotation
and flip are supported. There is no performance difference between any of these modes of
operation.
41.5
Queuing PXP transactions
The PXP supports a primitive ability to queue up one operation while the current
operation is running. This is enabled through the use of the REG_NEXT register.
When this register is written, it enables the PXP to reload its current register contents
with the data found at the location pointed to by this address when it completes
processing of the current frame. This feature may be useful in helping to reduce the
interrupt latency in servicing the PXP, especially in cases where the PXP and LCDIF are
using the on-chip SRAM buffer handshake (since the PXP must begin generating next
frame data immediately).
If the PXP is idle when the REG_NEXT register is written, the PXP treats this as an
indication that it should immediately load the values at the pointer and begin processing
the frame. This ability should allow software to use the same routines when programming
the PXP (so that the first frame doesn't differ from subsequent frames).
When loading values from the NEXT register, all registers in the PXP are reloaded. Some
register loads have no effect
After writing the REG_NEXT register, the PXP will set the REG_NEXT[ENABLED] bit
of the REG_NEXT register to indicate that the next command has been queued. Software
should first check the status of this bit to ensure that a previous command has not been
enabled. Likewise, after programming the first frame in a sequence of frames, software
should poll this bit until it is sampled logic 1'b0 before queuing the next operation.
The PXP will issue interrupts from frames as they complete, regardless of whether they
were started by writing the control registers directly or using the REG_NEXT register.
When software receives an interrupt, it should check/clear the PXP's status register as
normal, poll the REG_PXP[ENABLED] bit, and then issue the next operation. A queued
operation may be cancelled by issuing a CLEAR operation to the REG_PXP[ENABLED]
register bit. The SET and TOGGLE operations should never be used with this register.
Queuing PXP transactions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2528
NXP Semiconductors

<!-- page 2529 -->

41.6
Error Handling
The PXP does minimal checking on the control registers, so it is important that these are
correctly specified. The PXP does monitor the bus transactions for errors and will report
errors in the status register.
Upon receipt of a bus error, the PXP will set the ERROR interrupt and abort any further
operations. Bus errors can be generated from any system access that results in an error
response returned from the internal SIM Bus errors in the PXP are signaled as either a
read or a write error, but do not indicate the failing address. Software may deduce the
failing address from the current block status indicators.
41.6.1
Known PXP Limitations/Issues
The PXP has the following known limitations:
1. When using the NEXT register, the interrupt enable setting should remain the same
for all frames. If not, the PXP will change the interrupt enable register value and
possible cause the loss of an interrupt.
2. Rotations of 180/270 are not supported when performing LCD handshakes
41.7
Dither Engine Block
There are 3 instances of the dither processing block (Dither0, Dither1 and Dither2)
instantiated in the system and each has separate controls.
The dither engine takes in a buffer of 8 bit components at a time in block order from the
previous module that is connected to its input. It is designed to process ~1 pixel/clk. It
can process the pixels in a number of ways. It can write out the pixels unmodified (pass
through), it can quantize the pixels from 8 bits to any smaller number of bits down to 1
bpp. The dithering algorithms supported is Ordered dithering.
A LUT (Look Up Table) transform can be configured to be done on the pixel either
before or after dither dithering but not both. In addition there is a “final” independent
register based LUT that can be applied at the end of the dither process just before the
pixel is written out to the output buffer. The LUT values for this final LUT are
programmed by software into register.
There are 3 instances of the dither processing block (Dither0, Dither1 and Dither2)
instantiated in the system and each has separate controls.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2529

<!-- page 2530 -->

41.7.1
Top Level Connections
The dithering engine is connected to the output of the rotation engine, but it can be
bypassed by programming Mux 11. See the figure below:
Dithering
Engine
Output buffer
0
1
0
1
Figure 41-26. Dither Engine External Connections
The Dither Engine must be configured and enabled through the HW_DITHER_CTRL
control register. The data flow is controlled through the valid, ready and pixel handshake
signals with the Fetch and Store blocks. The Dither Engine must be enabled and given all
required information such as LUT configuration, etc. After starting, the Fetch Engine will
signal to the dither engine when it has data for processing.
The dimension information of the operation is not programmed in the Dither engine. It
comes from the higher level pxp control register fields.
41.7.2
Dither Engine Design
The following diagram shows the detailed internal structure of the Dither Engine.
Dither Engine Block
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2530
NXP Semiconductors

<!-- page 2531 -->

Pre-dither LUT 
pipeline
Quantization 
only
Memory
Ordered 
Dithering
Bypass (no transformation)
Post-dither LUT 
pipeline
Ordered dither 
Index matrix 
LUT pipeline
valid
ready
pixel_in
pixel_in 
after LUT
Lookup from memory
Lookup from memory
Lookup from memory
pixel’
pixel’
pixel’
after LUT
pixel_out
valid
ready
Final 
LUT
LUT Control 
and values 
from registers
pixel_in
Memory LUT: sequential
logic, 3 clk cycles
Dithering: combinatorial
logic
Memory LUT: sequential
logic, 3 clk cycles
external matrix
value
Figure 41-27. Detailed Block Diagram
1. Y8 configuration:- In this configuration only Dither0 is enabled. The Fetch Engine
will fetch Y8 data and feet it to Dither0. Dither0 then writes resultant data, Y4 for
instance, to the Store engine.
2. RGB configuration:- In this mode all three dither engine instances are enabled. The
Fetch Engine reads in RGB data from memory and gives 8 bits of the triplet to each
dither engine. The resulting quantized or dithered data from each dither engine is
passed to the same Store engine as in Y8 configuration and the Store Engine
synchronizes, packs the data back together and writes it memory.
1. Pass Through:- In this mode the pixel data passes through unmodified
2. Floyd-Steinberg Dithering:- This mode quantizes and dithers the pixels according to
the standard Floyd-Steinberg algorithm that can be found in the literature. This
algorithm employs an error dispersion technique that saves a fraction of the
quantization error from each pixel and adds those partial errors to neighboring pixels.
Therefore, the error memory buffers shown in the diagram are used in this mode to
save the partial errors and retreives them as they are needed when processing
corresponding pixels in the next row below the current row.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2531

<!-- page 2532 -->

3. Atkinson Dithering:- This mode employs the standard Atkinson dithering algorithm
to quantize and dither the pixels. The standard algorithm in the literature is
implemented. Atkinson is an error dispersion algorithm similar to Floyd-Steinberg
except that the partial error coeficients are different and the error is dispersed two
lines below the current row instead of one line below.
4. Ordered Dithering:- This is a standard algorithm that applies an index, or bayer
matrix to the pixels. Applying this matrix has the effect of changing the likelihood of
a pixel being rounded up or down when being quatized. If this mode is specified, it
requires use of the LUT memory so the HW_PXP_DITHER_CTRL.LUT_MODE
field must be set to 0, or off. The IDX_MATRIXx_SIZE field specifies the
dimensions of the index, or bayer matrix. This is used to properly index into the LUT
memory to retreive the correct corresponding value to apply to the current pixel.
5. Quantization only:- This mode simply quantizes the pixel from 8 down to whatever
bits per pixel are specifed in the NUM_QUANT_BIT field. No dithering algorithm is
used.
Before a detailed discussion of block functionality, it is important to note that there are 3
instances of the dither block within the PXP. All three, Dither0, Dither1 and Dither2 are
connected to the same Fetch and Store engines. The system works in two configurations
1. Y8 configuration:- In this configuration only Dither0 is enabled. The Fetch Engine
will fetch Y8 data and feet it to Dither0. Dither0 then writes resultant data, Y4 for
instance, to the Store engine.
2. RGB configuration:- In this mode all three dither engine instances are enabled. The
Fetch Engine reads in RGB data from memory and gives 8 bits of the triplet to each
dither engine. The resulting quantized or dithered data from each dither engine is
packed to 24 bit RGB and be written to memory by Store Engine.
The Dither Engine has the functionality to do a register based final LUT at the end of
dither processing. This LUT is controlled by the FINAL_LUT_ENABLE bit. Notice that
in the HW_PXP_DITHER_CTRL register there are separate ENABLEx,
DITHER_MODEx and IDX_MATRIXx_SIZE controls for each engine. The
NUM_QUANT_BIT and LUT_MODE control fields are common and apply to all dither
engine instances.
To be included in a pxp processing flow operation, the
HW_PXP_CTRL_ENABLE_DITHER bit must be set when the operation is executed.
This is in addition to the HW_PXP_DITHER_CTRL.ENABLEx bits.
The process flow through the Dither Engine is detailed in the following sections.
Step1: Pre-Dither
Dither Engine Block
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2532
NXP Semiconductors

<!-- page 2533 -->

The pixels are read into the pre-dither pipeline sub-block through the handshake with the
Fetch Engine/ If there is error data or Ordered dither LUT matrix data that corresponds
with the current pixel (this is mode dependent) then all these elements are fetched,
synchronized and presented to the dither stage (green blocks in the above figure)
simultaneously. The pre-dither, post_dither and Ordered dither matrix LUT pipeline
module instances keep the data synchronized and flowing through the block. The pixel
can go through a lookup table before the dither stage in the Pre-dither LUT pipeline or
after in the Post-dither LU T pipeline. These blocks and the Ordered dither index pipeline
block share the LUT memory through the LUT Memory Controller block. There is only
one memory that is shared between these three functions and only one use can be selected
for a given operation. In other words, the block can be configured to use pre-dither
lookup, post-dither lookup or ordered dither mode but only one at a time. The pre or post
lookup function is enabled through the HW_PXP_DITHER_CTRL.LUT_MODE field.
Ordered dithering is enabled through the HW_PXP_DITHER_CTRL.DITHER_MODEx
field (Again, the memory can be used for only one purpose during any given operation).
The LUT function uses an 8 bit address (the input data) to lookup 8 bits of data. The LUT
memory must be pre-configured with the desired lookup table data.
Step2: Dither
After the pre-dither stage, the pixel and colateral data passes through the dither stage.
There are 3 programmable modes in this stage that are specified with the
HW_PXP_DITHER_CTRL.DITHER_MODEx field.
1. Pass Through:- In this mode the pixel data passes through unmodified
2. Ordered Dithering:- This is a standard algorithm that applies an index, or bayer
matrix to the pixels. Applying this matrix has the effect of changing the likelihood of
a pixel being rounded up or down when being quatized. If this mode is specified, it
requires use of the LUT memory so the HW_PXP_DITHER_CTRL.LUT_MODE
field must be set to 0, or off. The IDX_MATRIXx_SIZE field specifies the
dimensions of the index, or bayer matrix. This is used to properly index into the LUT
memory to retreive the correct corresponding value to apply to the current pixel.
3. Quantization only:- This mode simply quantizes the pixel from 8 down to whatever
bits per pixel are specifed in the NUM_QUANT_BIT field. No dithering algorithm is
used.
The output of this step is the quantized/dithered pixel packed into the most significant
bits of an 8 bit byte. The unused bits in the lower part of the byte will be set to zero.
Step3: Post-Dither
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2533

<!-- page 2534 -->

The post-dither block is similar to its pre-dither counterpart. The processed pixel is
queued up in preparation for write to the Store Engine. If DITHER_MODEx is not equal
to Ordered mode, and a lookup operation is not selected in the pre-dither step, the
LUT_MODE can be set to select a lookup operation in this step using the LUT memory.
Step4: Final Lookup
This combinatorial LUT step takes bits [7:4] of the output pixel and looks up an 8 bit
value from the 16 value LUT to generate the final output pixel to the Store Engine. The
LUT values are programmed into the LUT through the
HW_PXP_DITHER_FINAL_LUT_DATA0 - 3 registers. This operation is enabled
through the HW_PXP_DITHER_CTRL.FINAL_LUT_ENABLE register field. This LUT
is only available on the Dither0 instance.
41.7.3
Pipelined Data Flow
It is possible that the fetch engine could stall when there are valid pixels in various stages
of the dither block. In this case the dither pipelines will not stall but will continue to drain
and move data out to the store engine. Also, if the Store Engine stalls for a period of time
and can not take any more data, flow control is implemented within the Dither block back
to the Fetch Engine so that no pixel or error data is lost or becomes unsynchonized.
There are three BUSY bits in the HW_PXP_DITHER_CTRL register, one for each
Dither Engine instance that software can poll to discover if the engine is busy or idle.
41.7.4
Initialization of Dedicated Memories
The internal memories for the Dither Engine instances, including 3 LUT memories can
all be initialized through the register interface. This is done by configuring the
HW_PXP_MEM_CTRL register and then writing the initialization data into the
HW_PXP_INIT_MEM_DATA register. This simple interface is used as follows. Write
the HW_PXP_MEM_CTRL.SELECT field with a value between 0-4 corresponding to
the memory to be initialized. Write the HW_PXP_MEM_CTRL.ADDR field with the
starting memory address to be written. Set the HW_PXP_MEM_CTRL.START field to
begin the initialization operation. Note at all these fields can be set with a single write to
the register. Then write the HW_PXP_MEM_DATA register with the data to be written
to the location at HW_PXP_MEM_CTRL.ADDR. Each write to the data register
increments and value of address so repeated writes to this register will put the data into
sequential memory locations beginning with the offset in the ADDR field. The LUT
memories are 8 bits wide. When 32 bit DATA writes occur with one of those memories
Dither Engine Block
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2534
NXP Semiconductors

<!-- page 2535 -->

selected, the lower 8 bits are written. To fill these memories 256 writes to the
HW_PXP_MEM_DATA register are required. Note that initialization for these memories
are not necessary.
41.7.5
Register Configuration Interface
The HW_PXP_DITHER_CTRL register control fields to be set for each operation are
included in the following table.
Signal or Group
Description
ENABLE
The hardware signal enables the dither block to function.
DITHER_MODE
Dither mode 0: passthrough, 3: Ordered, 4: no dithering
quantization only, 1,2,5,6,7: Reserved. There is on field for
each Dither Engine instance.
NUM_QUANT_BIT
How many bits to quantize to. Valid values are 7 down to 1.
LUT_MODE
Configures a LUT operation from local memory. The options
are either pre-dither, post-dither or off. This setting affects all
three Dither Engine instances.
IDX_MATRIXx_SIZE
These fields, one per instance, specifies the dimension (the
matrix is square) of the Index Matrix used in Ordered dither
mode.
FINAL_LUT_ENABLE
This field is only applicble to instance 0 of the three Dither
Engines and enables/disables the final register based LUT of
the output pixel just before outputing it to the Store Engine.
41.8
Waveform Engines
41.8.1
Overview
The WFE (Wavefrom Engine) is a very flexible, programable engine that can be used to
implement various algorithms to transform the incoming data to the output. It is always
used in connection with the Fetch Engine on the input side and a Store Engine on the
output. These three sub-blocks work as a unit. There is an optional ALU block between
the WFE and Store engines that can be used to make further modifications to the WFE
output before storing the output. See the figure below.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2535

<!-- page 2536 -->

 
Waveform Engine 
Fetch 
with 
Data Array
Store
RAM 256 x 8
ALU
RAM 256 x 32
Figure 41-28. Block Diagram
The WFE can process one pixel and associated data per clock.
The Fetch Engine fetches and formats the input pixel data streams according to the
requirements and programming of the WFE. The WFE takes in the data from the Fetch
Engine through a standard valid/ready signalling interface.
Inside the WFE the data passes through a 3 stage pipeline. Each stage consists of various
programmable logic elements including muxes, lookup tables, comparitors, ALU’s and
registers. The output information calculated in the WFE is output to the Store Engine also
using a standard valid/ready signalling interface.
The Store Engine reads the data from the WFE in the programmed format reformats the
data according to working buffer pixel formats and stores the frame and associated data
to memory.
41.8.2
Functionality
There is one WFE instance arranged in the PXP standard flow. It can be used as WFE-A
or WFE-B.
In the standard usecase WFE-A is used for pixel collision detection and also to compute
grayscale color transition information used later in the REGL/D algorithm. WFE-B
engine takes in pixel information and the results of WFE-A processing and implements
the REAGL/D algorithm on the data. The output results in all the information necessary
for the EPDC block to update the E-INK panel.
The definitions, functionality and programming of the logical elements within the WFE is
prorietary information. The register programming necessary for any given function
required will be supplied. The WFE block can be independently held in reset by setting
the HW_PXP_WFE_x_CTRL[SW_RESET] bit to 1. This bit should only be set when the
HW_PXP_WFE_x_CTRL[ENABLE] bit is 0.
Waveform Engines
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2536
NXP Semiconductors

<!-- page 2537 -->

41.9
PXP Store Engine Block Description
41.9.1
Overview
The essential function of the Store Engine is to store input data from the input sub-block
to memory or directly output to next sub-block. The input source is 32 bits per channel
per valid clock. There is one instance of the Store Engine in the PXP. The main supported
features are:
• Two DMA controllers thus it can work on two channel data storage at the output at
the same time. If there is only one stream data input, store engine should use channel
0 but not channel1.
• Accepts as input up to 8 bytes data (two channels, 32 bits each) and 8 bits flag input.
After shift operation it can store up to 64bpp per valid clock to memory.
• Data fill function for initialization. It can fill a fixed 32 bit data value to a specified
memory buffer.
• Handshake mode with a downstream connected data Fetch Engine. It supports 1 line,
4 lines, 8 lines and 16 lines scan handshake with and 1 line, 3 lines and 5 lines array
handshake modes. The Store Engine signals to the Fetch Engine when data is
available for processing thus eliminating the need for software intervention through
interrupt service routines.
• Bypass mode which directly outputs the data to the downstream connected Fetch
Engine after shift operation. This is done through a valid/ready data interface.
• Support for 8x8 and 16x16 block mode and scanline mode.
• Support for 8, 16 and 32 bpp input data format.
41.9.2
Top-Level Architecture
The following figure shows the high level architecture of the block. The basic flow is as
follows:
1. Interface with driving sub-block, read in and synchronize data channels.
2. Shift data function swizzles data fields as specified.
3. Data is steared to the output channels and packed for output.
4. Data is output to memory through the AXI masters or sent to receiving sub-block
through the bypass interface.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2537

<!-- page 2538 -->

1
0
0
1
store_sync
8 bit flag 
64 bit data
64 bit
64
64
64
64
32 bit
32 bit
MUX 
72 bit
Store Engine
ch1_pack_in_sel
store_data
_pack_ch1
store_output
   _ch1(fifo)
store_data
_shift_ch0
store_delay
     _ch0
store_data
_pack_ch0
store_output
   _ch0(fifo)
ch0_delay_out_pixel[63:0]
ch0_pack_in_cel
{32'h0,[31:0]}
{32'h0,[63:32]}
AXI_W
ch0_bypass_pixel
ch1_bypass_pixel
AXI_W
store_delay
     _first
store_data
     _fill
ch0_src_pixel[31:0]
flag_in[7:0]
ch1_src_pixel[31:0]
Figure 41-29. High Level Block Diagram
The following figure shows the Store Engine supported connections. On the input side
the Store engine can take data from a process engine like the WFE-A through the normal
interface. It can output data to memory through the AXI arbitor or directly to the
connected Fetch Engine through either the bypass or handshake interfaces. The block is
configured and controlled through software programming of PIO registers.
 
Store Engine
Axi0/1_buscmd_wr_req
Axi0/1_buscmd_wr_ack
Axi0/1_buscmd_wr_addr[31:0]
Axi0/1_buscmd_wr_num_bytes[6:0]
Axi0/1_busdata_wr_beat
Axi0/1_busdata_wr_data[63:0]
Ch0/1_src_pixel_valid
Ch0/1_src_pixel[31:0]
Ch0/1_pixel_ready
AXI_W
Process Engine 0
Ch0/1_handshake_b0_ready
Ch0/1_handshake_b0_done
Ch0/1_handshake_b1_ready
Ch0/1_Handshake_b1_done
Fetch Engine
Registers & ctrol signal
Axi0/1_busdata_wr_strb[7:0]
Pxp_ctrl
Fetch Engine
Ch0/1_bypass_pixel_ready
Ch0/1_bypass_pixel
Ch0/1_bypass_valid
Flag_in[7:0]
PXP Store Engine Block Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2538
NXP Semiconductors

<!-- page 2539 -->

41.9.3
Store Engine Design
41.9.3.1
Input Data Source
1. Fixed Data Input
The Store Engine supports a fill function which writes a fixed value to a specific set
of memory locations. The data received from the input is ignored. This function is
usually used to initialize a memory buffer. The address of the buffer to fill is set in
the HW_PXP_x_STORE_FILL_DATA_CH0 register. Also, this mode can only
work through channel 0 and not channel 1.
In this mode HW_PXP_INPUT_STORE_CTRL_CH0.FILL_DATA_EN=1.The
fixed value is set in FILL_DATA_CH0 register. How many bits are valid from
HW_PXP_INPUT_STORE_FILL_DATA_CH0 register is decided by
HW_PXP_x_STORE_SHIFT_CTRL_CH0.OUTPUT_ACTIVE_BPP.
2. Normal Data Input
Store Engine supports two 32 bits wide data channels and 8 bits flag input. If there is
only one channel of data input, the channel 0 must be used not channel 1. In this
case, HW_PXP_INPUT_STORE_CTRL_CH0.COMBINE_2CHANNEL=0.
If both channels and 8 bits flag input contain valid data, then the
COMBINE_2CHANNEL bit should be set to 1. The Store Engine will then combine
the two channels of data into 64 bits of data send them with the 8 bits of flags to the
shift module. After shift, the Store Engine will choose the active bits from the 64 bit
output according to
HW_PXP_x_STORE_SHIFT_CTRL_CHx.OUTPUT_ACTIVE_BPP and then pack
them in preparation for output.
41.9.3.2
Store data shift operation
The data shift operation supports up to 8 data fields and 8 flag components to be shifted
to any position within the 64 bit word. The data fields can be any width. This function is
a way to reorder or reformat the component parts of the 64 bit word output. As data flows
through the Store Engine each data word is processed the same way according to register
configuration.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2539

<!-- page 2540 -->

The following registers are used in shift operation. The pairs of
{HW_PXP_x_STORE_D_MASKx_H_CHx,
HW_PXP_x_STORE_D_MASKx_L_CHx} make up the 64 bits of mask for each
MASKx component. There are a set of masks for each channel in each instance. The
D_SHIFT_FLAG0 ~ D_SHIFT_FLAG7 fields in the HW_PXP_x_STORE_D/
F_SHIFT_L/D_CHx registers specify which direction to shift (0: right shift 1: left shift)
each data component0 ~ component7 after the mask is applied. The D_SHIFT_WIDTH0
through D_SHIFT_WIDTH7 fields specify how many bits to right or left shift each data
component 0 through7 after the mask is applied.
The shift function works the same for the 8 bits of flag data. There are analogous
“F_SHIFT” regsiters that contain the F_MASKx, F_SHIFT_FLAGx and
F_SHIFT_WIDTHx register fields for swizzling the input flags.
The figure below shows how the shift function works.
 
0
1
mux
63 62
1
0
…
.
7
6
1
0
…
.
63 62
1
0
…
.
63 62
1
0
…
.
63 62
1
0
…
.
63
62
1
0
…
.
63 62
1
0
…
.
63 62
1
0
…
.
63
62
1
0
…
.
63
62
1
0
…
.
63 62
1
0
…
.
63 62
1
0
…
.
0
1
mux
0
1
mux
0
1
mux
63 62
1
0
…
.
7
6
1
0
…
.
7
6
1
0
…
.
7
6
1
0
…
.
7
6
1
0
…
.
7
6
1
0
…
.
7
6
1
0
…
.
7
6
1
0
…
.
7
6
1
0
…
.
7
6
1
0
…
.
63 62
1
0
…
.
63 62
1
0
…
.
{D_MASK0_H,D_MASK0_L}
&
&
src_pixel
{D_MASK7_H,D_MASK7_L}
mask_data0
mask_data7
mask_data0
mask_data7
mask_data7
&
flag_in
F_MASK0
F_MASK7
flag_in
&
…
.
mask_flag7
mask_flag7
mask_flag7
mask_flag0
mask_flag0
>>D_SHIFT_WIDTH0
>>D_SHIFT_WIDTH7
<<D_SHIFT_WIDTH0
<<D_SHIFT_WIDTH7
>>F_SHIFT_WIDTH0
<<F_SHIFT_WIDTH0
<<F_SHIFT_WIDTH7
>>F_SHIFT_WIDTH7
D_SHIFT_FLAG0
D_SHIFT_FLAG7
F_SHIFT_FLAG0
F_SHIFT_FLAG7
≥1
…
.
…
.
…
.
…
.
…
.
data_shift0
data_shift7
flag_shift0
flag_shift7
mask_flag0
…
.
…
.
data_shift
PXP Store Engine Block Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2540
NXP Semiconductors

<!-- page 2541 -->

41.9.3.3
Data Packing
After data shift, the 64 bits of data can be divided to two 32bit words depending on the
value of the HW_PXP_x_STORE_CTRL_CHx.PACK_IN_SEL bits. If
HW_PXP_x_STORE_CTRL_CH0.PACK_IN_SEL = 0, it will select active bits from all
64 bits of data. If equal to 1, it will select active bits from the lower 32 bits data.
For channel 1, if HW_PXP_x_STORE_CTRL_CH1.PACK_IN_SEL = 0, it will also
select active bits from all 64 bits data and if equal to 1, it will select active bits from the
higher 32 bits data.
Store Engine supports 8bpp, 16bpp, 32bpp and 64bpp active bits per pixel according to
OUTPUT_ACTIVE_BPP register setting. When either channel’s PACK_IN_SEL = 1
only 8bpp, 16bpp, 32bpp can be selected.
After shift and data output selection, the packing module will pack the data into a 64 bit
string and store to a FIFO before writing out to memory.
Packing style according to active bpp is showed below.
OUTPUT_ACTIVE_BPP
Active bpp from 64 shift output data
Packed data
0
8 bits
{pix7, pix6, pix5, pix4, pix3, pix2, pix1,
pix0}
1
16 bits
{pix3, pix2, pix1, pix0}
2
32 bits
{pix1, pix0}
3
64 bits
{pix0}
41.9.3.4
Data Store Format
• Scanline mode
When HW_PXP_x_STORE_CTRL_CHx.BLOCK_EN=0, the Store Engine will
store data the line by line in scanline mode. The AXI burst length is set by the
HW_PXP_x_STORE_CTRL_CHx.WR_NUM_BYTES register field. In Scanline
mode, it can support 8, 16, 32 and 64 bytes in a burst.
• Block mode
When HW_PXP_x_STORE_CTRL_CHx.BLOCK_EN=1, the Store Engine support
8x8 and 16x16 block mode according to
HW_PXP_x_STORE_CTRL_CHx.BLOCK_16 register bit. When BLOCK_16=1,
the block size is 16*16 while if BLOCK_16=0 the size is 8*8 blocks. When
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2541

<!-- page 2542 -->

BLOCK_EN=1, then
HW_PXP_x_STORE_SHIFT_CTRL_CHx.OUTPUT_ACTIVE_BPP cannot be 3,
that is, block mode can not work on a 64bpp data stream.
When the Store Engine is configured block mode, the upstream Fetch Engine should
be configured in block mode and with the same block size as well.
When the total width or total height of image is no divisible by 8 or 16, the upstream
Fetch Engine will fetch extra pixels or lines to fill out the final partial blocks. For
example, if the size is 23*23, and block mode is 8*8, Fetch Engine will fetch 24*24
data pixels and output to store engine. The Store Engine has a crop function for this.
That is, the extra pixels or lines will not be stored to memory by the Store Engine.
This is accomplished by the hardware using the AXI bus byte enables.
In block mode, the number of AXI bus write bytes is internally calculated from the
OUTPUT_ACTIVE_BPP and BLOCK_16 (block size) register fields rather than the
WR_NUM_BYTES field.
One limitation exists with block mode configuration. No YUV422 output format is
not supported. So
HW_PXP_x_STORE_SHIFT_CTRL_CHx.OUT_YUV422_1P_EN and
OUT_YUV422_2P_EN must be disabled.
41.9.3.5
Output Format Modes
• Normal mode
If HW_PXP_x_STORE_CTRL_CHx.STORE_BYPASS_EN = 0,
HW_PXP_x_STORE_CTRL_CHx.STORE_MEMORY_EN=1 and
HW_PXP_x_STORE_CTRL_CHx.HANDSHAKE_EN=0, the Store Engine is
working in normal mode.
In normal mode, the Store Engine will store the input data to memory frame by
frame. The store frame start address is set in HW_PXP_x_STORE_ADDR_x_CHx.
Two address registers exist for each channel. The second one is used for YUV422 2
plane mode.
The Store Engine will stop storing data when the frame of data is finished. Another
pxp_start signal will trigger the next frame operation. The frame size is specified by
the HW_PXP_x_STORE_SIZE_CHx registers. The values should be set up for each
channel in use. If both channels are being used, the height and width values in the
PXP Store Engine Block Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2542
NXP Semiconductors

<!-- page 2543 -->

HW_PXP_x_STORE_SIZE_CH0 and HW_PXP_x_STORE_SIZE_CH1 registers
may be different but the total number of pixels in the frame must be the same. The
only exception to this is when both channels are being used and the Store Engine is
outputing data in handshake mode. In handshake mode the width and height must be
set the same in both channel size registers.
If the data shift mode is set to YUV422 single plane or 2 plane, two pixels, 64 bits,
are read in and 32 bits are written. If the YUV data is coming from the upstream
Fetch Engine it will be in YUV444 format as {8’h0, Y0, U0, V0, 8’h0, Y1, U1, V1}.
Even though the YUV422 mode is set, the shift function must be set to shift the
components into their proper position. For instance, for 1p mode, the shift MASK,
FLAG and WIDTH parameters need to be set up on the 64 bits of pixel data to
format each 32 bits (2 pixels) to be written out as {Y0, U0, Y1, V0}. Likewise in 2p
mode, the ch0 data would be shifted to yield {Y0, Y1} with ch1 as {U0, Y0} for the
first two pixels.
• Bypass mode
If STORE_BYPASS_EN=1, STORE_MEMORY_EN=0, The Store Engine will
output the input data, after the shift function, directly to the downstream Fetch
Engine instead of storing to memory. The AXI bus is inactive in this case. The data is
output using the valid/ready external interface to the downstream connected Fetch
Engine.
In bypass mode, if HW_PXP_x_STORE_CTRL_CH0.CH_EN=1, it will output the
lower 32 bits of data. If HW_PXP_x_STORE_CTRL_CH1.CH_EN=1, it will output
the high 32 bits of data.
• Dual mode
If STORE_BYPASS_EN = 1 and
HW_PXP_x_STORE_CTRL_CHx.STORE_MEMORY_EN = 1, the Store Engine is
configured in Dual mode. That is, the Store Engine supports bypassing the data and
also storing it to memory at the same time.
• Handshake mode
The Store Engine supports a 1 line scan handshake.
The array handshake is used in cases where the Fetch Engine is in array mode. One
line handshake config indicates that the Fetch Engine is working on 1x1 array mode.
The 3 line handshake indicates the Fetch Engine work is in 3x3 array while 5 line
handshake indicates 5x5 array mode.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2543

<!-- page 2544 -->

To accomplish the buffer sharing, Store Engine and the attached Fetch Engine will
maintain buffer status using a pair of handshake signals. When a buffer is filled by
the Store Engine, it will assert the handshake_bx_ready (where x is 0 or 1) signal to
indicate to the fetch engine that the buffer has valid data. The prefetch engine will
then release the buffer by asserting the handshake_bx_done signal.
The basic protocol and timing is shown in the diagram below:
clk
……
……
handshake_bx_ready
handshake_bx_done
Unlike scanline handshake, there is only 1 buffer in memory. The buffer size is
(array_line + 1).
• 1 line array handshake
When HW_PXP_x_STORE_CTRL_CHx.ARRAY_LINE_NUM = 0, the
configuration is 1 line handshake mode. The buffer size is 2 * OUT_PITCH (2
lines). The first ready occurs when the Store Engine finishes writing 1 line.
• 3 line array handshake
When ARRAY_LINE_NUM = 1, the configuration is 3 line handshake mode.
The buffer size is 4 * OUT_PITCH. The first ready occurs when the Store
Engine finishes writing 2 lines.
• 5 line array handshake
When ARRAY_LINE_NUM=2, the configuration is 5 line handshake mode.
The buffer size is 6*OUT_PITCH. The first ready occurs when store engine
finishes writing 3 lines.
For scanline handshake with next fetch engine, it is similar to LCDIF Handshake section
without abort special process.
PXP Store Engine Block Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2544
NXP Semiconductors

<!-- page 2545 -->

41.9.3.6
Limitations
When both channels are active, they should be configured to work in the same mode. For
example, if channel 0 is configured for bypass mode then channel 1 must also be
configured the same way.
41.10
Histogram
The histogram block collects statistics about the pixel -5data passing through it. Its
primary function is to compare the value against programmed values representing the
allowed values in different bpp (bits per pixel) modes or bins. A flag value of 1 is
recorded if all the pixel values were a match for one of the values programmed for that
bit per pixel mode or bin. If there is a mismatch for at least one pixel then the update is
not completely contained within that bin and the output flag is 0. There are 5 bits
reported. One for each of 1-5 bpp. The results for each bpp bin are always reported.
These results are a necessary input to the EPDC for selecting the proper waveform for
update to the panel. The pixel value and the compare values are always 6 bits wide
although the max effective bpp is 5.
There is also a mask function that can be used to filter out update pixels and exclude
them from histogram calculations. It’s primary use-case is to collect and report collisions
of the current update being processed through the WFE-A and report to software how
many pixels collided with current live updates, if any, and the coordinates of the
minimum rectangle within the update that contains all collided pixels.
There are two identical instances of the histogram block in the system. They both can be
programmed through a system mux to take data from the outbuf sub-block from the
legacy flow and WFE.
41.10.1
Basic Operation
The basic controls for each histogram engine are contained within their
HW_PXP_HIST_x_CTRL and HW_PXP_HIST_x_MASK registers. We will use
histogram A registers for explanation purposes in the description below.
The HW_PXP_HIST_A_CTRL.ENABLE bit turns on the histogram block to process
pixels. It must be turned on and off manually. The HW_PXP_HIST_A_CTRL.CLEAR
bit must be set to clear the histogram results. The bit is self-clearing. The input data
(pixel) to the block is 72 bits wide. The comparison is done on 6 bits of pixel data. Any
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2545

<!-- page 2546 -->

contiguous 6 bits in the 72 bit string can be chosen for comparison using the
HW_PXP_HIST_A_CTRL. PIXEL_OFFSET and
HW_PXP_HIST_A_CTRL.PIXEL_WIDTH fields. The offset specifies the starting bit
position in the string and the width field specifies the width which should not be wider
than 6 bits in the current implementation. The mode values for comparison are contained
in the HW_PXP_HISTx_PARAMx register fields. Even though these fields are 6 bits
wide, 5 bits is the effective width as the histogram can check for 32 unique pixel values
in the largest mode, HIST32.
The result of which bpp modes were a match for all pixels since the output was cleared
are continuously updated in the HW_PXP_HIST_A_CTRL.STATUS field. There is one
bit for each bpp mode. All histogram bpp modes are checked simultaneously. The
HW_PXP_HIST_A_BUF_SIZE fields specify the height and width of the update area.
This allows the histogram engine to keep track of the relative coordinates of each new
pixel it receives. It assumes the pixels are fed to it in raster order, left to right and top to
bottom.
41.10.2
Mask Functionality
There is also a mask function within the histogram engine that tests a specified string of
bits from the input against values programmed into the mask register. The use-case for
this is to report collision detection back to controlling software. If the mask test passes
then the pixel is active and is processed in the engine and statistics collected. If the pixel
is not active then it is discarded and not processed – does not contribute to the output
results. Based on the outcome of this mask test, there are some additional results that are
output to register fields. They are the number of active pixels, the coordinates of the
smallest bounding box including all active pixels and an array of 64 bits where the offset
of each bit corresponds to the pixel value of processed pixel. The bit is set for each valid
pixel value processed.
The configuration of the mask function is contained in the HW_PXP_HIST_x_MASK
register. The HW_PXP_HIST_A_MASK.MASK_EN bit turns on the function. . The
HW_PXP_HIST_A_CTRL.CLEAR bit clears the results. The
HW_PXP_HIST_A_MASK.MASK_MODE field specifies the logical operation for the
test. The options are “equal”, “not equal”, “inside” or “outside.” The
HW_PXP_HIST_A_MASK.MASK_VALUE0 and
HW_PXP_HIST_A_MASK.MASK_VALUE1 are used for comparison with the
incoming value depending on the mode chosen. The starting bit of mask field in the 72
bit input data is specified by the HW_PXP_HIST_A_MASK.MASK_OFFSET register
field and the width is given by HW_PXP_HIST_A_MASK.MASK_WIDTH. The width
of the mask is a maximum of 8 bits. If the mask mode test passes for a given input then
Histogram
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2546
NXP Semiconductors

<!-- page 2547 -->

the HW_PXP_HIST_A_TOTAL_PIXEL read only value is incremented. The x and y
coordinates of the pixel are used to calculate the minimum rectangle the will enclose all
valid pixels. This information can be read from the
HW_PXP_HIST_A_ACTIVE_AREA_X and HW_PXP_HIST_A_ACTIVE_AREA_Y
registers. Also, the values of the valid pixels are recorded in the
HW_PXP_HIST_A_RAW_STAT0 and HW_PXP_HIST_A_RAW_STAT0 registers.
These registers make up 64 one bit fields where the offsets of the bit that are set are the
pixel values of the active pixels. (The values as specifed by the
HW_PXP_HIST_A_CTRL. PIXEL_OFFSET and
HW_PXP_HIST_A_CTRL.PIXEL_WIDTH fields.)
41.10.3
Collision use-case Example
In this example, the histogram engine is used to test for and report collision information
within the update. Refer to the figure below. With normal WFE-A processing, within the
72 bit output there will be a one bit collision flag that is assert to 1 if there was a collision
on that update pixel. There will also be a 6 bit field that specifies the EPDC LUT number
for that pixel in the working buffer. If there was a collsion this LUT number identifies the
unique colliding live update. To covey all this information to software using the
histogram engine, the HW_PXP_HIST_A_CTRL. PIXEL_OFFSET and
HW_PXP_HIST_A_CTRL.PIXEL_WIDTH should be set to point to the current LUT in
the input bus. The HW_PXP_HIST_A_MASK.MASK_OFFSET and
HW_PXP_HIST_A_MASK.MASK_WIDTH fields should be set to point to the collsion
bit. The HW_PXP_HIST_A_MASK.MASK_MODE should be 0 or “equal” and the
HW_PXP_HIST_A_MASK.MASK_VALUE0 should be set to 1.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2547

<!-- page 2548 -->

A
B
C
Panel
Update Area
Collided Pixels
Collision Area
(0,0)
(799,599)
(100,50)
(599,499)
(150,100)
(400,150)
(320,480)
D (300,200)
The figure above shows the processed results of our example. There is an update region,
499x449, offset within the800x600 panel display. After enabling the histogram and
processing the update, there is a collided region within the update region and 4 collided
pixels were detected. The results are as follows.
The HW_PXP_HIST_A_TOTAL_PIXEL register would equal to 4 showing that 4 pixels
were found by the mask function to have their collision bits set.
The relative collision area are would be given in the
HW_PXP_HIST_A_ACTIVE_AREA_X and Y register as MIN_X_OFFSET = 50,
MAX_X_OFFSET = 300, MIN_Y_OFFSET = 50, MAX_Y_OFFSET = 380.
If pixel A is being updated by LUT 1, pixel B and C are being updated LUT 5, and pixel
D is being updated by LUT 12, then the LUT Collision Status = 0x00001022 (bit 1, 2, 12
are set). That is HW_PXP_HIST_A_RAW_STAT0 would be equal to 0x00001022 and
HW_PXP_HIST_A_RAW_STAT1 would be 0x00000000.
41.11
PXP Memory Map/Register Definition
PXP Hardware Register Format Summary
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2548
NXP Semiconductors

<!-- page 2549 -->

PXP memory map
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
21C_C000
Control Register 0 (PXP_HW_PXP_CTRL)
32
R/W
C701_0000h
41.11.1/
2573
21C_C004
Control Register 0 (PXP_HW_PXP_CTRL_SET)
32
R/W
C701_0000h
41.11.1/
2573
21C_C008
Control Register 0 (PXP_HW_PXP_CTRL_CLR)
32
R/W
C701_0000h
41.11.1/
2573
21C_C00C
Control Register 0 (PXP_HW_PXP_CTRL_TOG)
32
R/W
C701_0000h
41.11.1/
2573
21C_C010
Status Register (PXP_HW_PXP_STAT)
32
R/W
0000_0000h
41.11.2/
2576
21C_C014
Status Register (PXP_HW_PXP_STAT_SET)
32
R/W
0000_0000h
41.11.2/
2576
21C_C018
Status Register (PXP_HW_PXP_STAT_CLR)
32
R/W
0000_0000h
41.11.2/
2576
21C_C01C
Status Register (PXP_HW_PXP_STAT_TOG)
32
R/W
0000_0000h
41.11.2/
2576
21C_C020
Output Buffer Control Register
(PXP_HW_PXP_OUT_CTRL)
32
R/W
0000_0000h
41.11.3/
2578
21C_C024
Output Buffer Control Register
(PXP_HW_PXP_OUT_CTRL_SET)
32
R/W
0000_0000h
41.11.3/
2578
21C_C028
Output Buffer Control Register
(PXP_HW_PXP_OUT_CTRL_CLR)
32
R/W
0000_0000h
41.11.3/
2578
21C_C02C
Output Buffer Control Register
(PXP_HW_PXP_OUT_CTRL_TOG)
32
R/W
0000_0000h
41.11.3/
2578
21C_C030
Output Frame Buffer Pointer (PXP_HW_PXP_OUT_BUF)
32
R/W
0000_0000h
41.11.4/
2579
21C_C040
Output Frame Buffer Pointer #2
(PXP_HW_PXP_OUT_BUF2)
32
R/W
0000_0000h
41.11.5/
2579
21C_C050
Output Buffer Pitch (PXP_HW_PXP_OUT_PITCH)
32
R/W
0000_0000h
41.11.6/
2580
21C_C060
Output Surface Lower Right Coordinate
(PXP_HW_PXP_OUT_LRC)
32
R/W
0000_0000h
41.11.7/
2580
21C_C070
Processed Surface Upper Left Coordinate
(PXP_HW_PXP_OUT_PS_ULC)
32
R/W
0000_0000h
41.11.8/
2581
21C_C080
Processed Surface Lower Right Coordinate
(PXP_HW_PXP_OUT_PS_LRC)
32
R/W
0000_0000h
41.11.9/
2582
21C_C090
Alpha Surface Upper Left Coordinate
(PXP_HW_PXP_OUT_AS_ULC)
32
R/W
0000_0000h
41.11.10/
2583
21C_C0A0
Alpha Surface Lower Right Coordinate
(PXP_HW_PXP_OUT_AS_LRC)
32
R/W
0000_0000h
41.11.11/
2583
21C_C0B0
Processed Surface (PS) Control Register
(PXP_HW_PXP_PS_CTRL)
32
R/W
0000_0000h
41.11.12/
2584
21C_C0B4
Processed Surface (PS) Control Register
(PXP_HW_PXP_PS_CTRL_SET)
32
R/W
0000_0000h
41.11.12/
2584
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2549

<!-- page 2550 -->

PXP memory map (continued)
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
21C_C0B8
Processed Surface (PS) Control Register
(PXP_HW_PXP_PS_CTRL_CLR)
32
R/W
0000_0000h
41.11.12/
2584
21C_C0BC
Processed Surface (PS) Control Register
(PXP_HW_PXP_PS_CTRL_TOG)
32
R/W
0000_0000h
41.11.12/
2584
21C_C0C0
PS Input Buffer Address (PXP_HW_PXP_PS_BUF)
32
R/W
0000_0000h
41.11.13/
2585
21C_C0D0
PS U/Cb or 2 Plane UV Input Buffer Address
(PXP_HW_PXP_PS_UBUF)
32
R/W
0000_0000h
41.11.14/
2585
21C_C0E0
PS V/Cr Input Buffer Address (PXP_HW_PXP_PS_VBUF)
32
R/W
0000_0000h
41.11.15/
2586
21C_C0F0
Processed Surface Pitch (PXP_HW_PXP_PS_PITCH)
32
R/W
0000_0000h
41.11.16/
2586
21C_C100
PS Background Color
(PXP_HW_PXP_PS_BACKGROUND_0)
32
R/W
0000_0000h
41.11.17/
2587
21C_C110
PS Scale Factor Register (PXP_HW_PXP_PS_SCALE)
32
R/W
1000_1000h
41.11.18/
2588
21C_C120
PS Scale Offset Register (PXP_HW_PXP_PS_OFFSET)
32
R/W
0000_0000h
41.11.19/
2589
21C_C130
PS Color Key Low (PXP_HW_PXP_PS_CLRKEYLOW_0)
32
R/W
00FF_FFFFh
41.11.20/
2590
21C_C140
PS Color Key High (PXP_HW_PXP_PS_CLRKEYHIGH_0)
32
R/W
0000_0000h
41.11.21/
2590
21C_C150
Alpha Surface Control (PXP_HW_PXP_AS_CTRL)
32
R/W
0000_0000h
41.11.22/
2591
21C_C160
Alpha Surface Buffer Pointer (PXP_HW_PXP_AS_BUF)
32
R/W
0000_0000h
41.11.23/
2592
21C_C170
Alpha Surface Pitch (PXP_HW_PXP_AS_PITCH)
32
R/W
0000_0000h
41.11.24/
2592
21C_C180
Overlay Color Key Low
(PXP_HW_PXP_AS_CLRKEYLOW_0)
32
R/W
00FF_FFFFh
41.11.25/
2593
21C_C190
Overlay Color Key High
(PXP_HW_PXP_AS_CLRKEYHIGH_0)
32
R/W
0000_0000h
41.11.26/
2594
21C_C1A0
Color Space Conversion Coefficient Register 0
(PXP_HW_PXP_CSC1_COEF0)
32
R/W
0400_0000h
41.11.27/
2595
21C_C1B0
Color Space Conversion Coefficient Register 1
(PXP_HW_PXP_CSC1_COEF1)
32
R/W
0123_0208h
41.11.28/
2596
21C_C1C0
Color Space Conversion Coefficient Register 2
(PXP_HW_PXP_CSC1_COEF2)
32
R/W
079B_076Ch
41.11.29/
2597
21C_C1D0
Color Space Conversion Control Register.
(PXP_HW_PXP_CSC2_CTRL)
32
R/W
0000_0001h
41.11.30/
2598
21C_C1E0
Color Space Conversion Coefficient Register 0
(PXP_HW_PXP_CSC2_COEF0)
32
R/W
0000_0000h
41.11.31/
2598
21C_C1F0
Color Space Conversion Coefficient Register 1
(PXP_HW_PXP_CSC2_COEF1)
32
R/W
0000_0000h
41.11.32/
2599
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2550
NXP Semiconductors

<!-- page 2551 -->

PXP memory map (continued)
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
21C_C200
Color Space Conversion Coefficient Register 2
(PXP_HW_PXP_CSC2_COEF2)
32
R/W
0000_0000h
41.11.33/
2600
21C_C210
Color Space Conversion Coefficient Register 3
(PXP_HW_PXP_CSC2_COEF3)
32
R/W
0000_0000h
41.11.34/
2600
21C_C220
Color Space Conversion Coefficient Register 4
(PXP_HW_PXP_CSC2_COEF4)
32
R/W
0000_0000h
41.11.35/
2601
21C_C230
Color Space Conversion Coefficient Register 5
(PXP_HW_PXP_CSC2_COEF5)
32
R/W
0000_0000h
41.11.36/
2601
21C_C240
Lookup Table Control Register.
(PXP_HW_PXP_LUT_CTRL)
32
R/W
8001_0000h
41.11.37/
2602
21C_C250
Lookup Table Control Register.
(PXP_HW_PXP_LUT_ADDR)
32
R/W
0000_0000h
41.11.38/
2604
21C_C260
Lookup Table Data Register. (PXP_HW_PXP_LUT_DATA)
32
R/W
0000_0000h
41.11.39/
2605
21C_C270
Lookup Table External Memory Address Register.
(PXP_HW_PXP_LUT_EXTMEM)
32
R/W
0000_0000h
41.11.40/
2605
21C_C280
Color Filter Array Register. (PXP_HW_PXP_CFA)
32
R/W
0000_0000h
41.11.41/
2606
21C_C290
PXP Alpha Engine A Control Register.
(PXP_HW_PXP_ALPHA_A_CTRL)
32
R/W
0000_0000h
41.11.42/
2607
21C_C2C0
PS Background Color 1
(PXP_HW_PXP_PS_BACKGROUND_1)
32
R/W
0000_0000h
41.11.43/
2608
21C_C2D0
PS Color Key Low 1 (PXP_HW_PXP_PS_CLRKEYLOW_1)
32
R/W
00FF_FFFFh
41.11.44/
2609
21C_C2E0
PS Color Key High 1
(PXP_HW_PXP_PS_CLRKEYHIGH_1)
32
R/W
0000_0000h
41.11.45/
2609
21C_C2F0
Overlay Color Key Low
(PXP_HW_PXP_AS_CLRKEYLOW_1)
32
R/W
00FF_FFFFh
41.11.46/
2610
21C_C300
Overlay Color Key High
(PXP_HW_PXP_AS_CLRKEYHIGH_1)
32
R/W
0000_0000h
41.11.47/
2611
21C_C310
Control Register 2 (PXP_HW_PXP_CTRL2)
32
R/W
0000_0000h
41.11.48/
2612
21C_C314
Control Register 2 (PXP_HW_PXP_CTRL2_SET)
32
R/W
0000_0000h
41.11.48/
2612
21C_C318
Control Register 2 (PXP_HW_PXP_CTRL2_CLR)
32
R/W
0000_0000h
41.11.48/
2612
21C_C31C
Control Register 2 (PXP_HW_PXP_CTRL2_TOG)
32
R/W
0000_0000h
41.11.48/
2612
21C_C320
PXP Power Control Register.
(PXP_HW_PXP_POWER_REG0)
32
R/W
0000_0000h
41.11.49/
2613
21C_C330
PXP Power Control Register 1.
(PXP_HW_PXP_POWER_REG1)
32
R/W
0000_0000h
41.11.50/
2614
21C_C340
PXP_HW_PXP_DATA_PATH_CTRL0
32
R/W
5104_5A20h
41.11.51/
2615
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2551

<!-- page 2552 -->

PXP memory map (continued)
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
21C_C344
PXP_HW_PXP_DATA_PATH_CTRL0_SET
32
R/W
5104_5A20h
41.11.51/
2615
21C_C348
PXP_HW_PXP_DATA_PATH_CTRL0_CLR
32
R/W
5104_5A20h
41.11.51/
2615
21C_C34C
PXP_HW_PXP_DATA_PATH_CTRL0_TOG
32
R/W
5104_5A20h
41.11.51/
2615
21C_C350
PXP_HW_PXP_DATA_PATH_CTRL1
32
R/W
0000_0000h
41.11.52/
2616
21C_C354
PXP_HW_PXP_DATA_PATH_CTRL1_SET
32
R/W
0000_0000h
41.11.52/
2616
21C_C358
PXP_HW_PXP_DATA_PATH_CTRL1_CLR
32
R/W
0000_0000h
41.11.52/
2616
21C_C35C
PXP_HW_PXP_DATA_PATH_CTRL1_TOG
32
R/W
0000_0000h
41.11.52/
2616
21C_C360
Initialize memory buffer control Register
(PXP_HW_PXP_INIT_MEM_CTRL)
32
R/W
0000_0000h
41.11.53/
2617
21C_C364
Initialize memory buffer control Register
(PXP_HW_PXP_INIT_MEM_CTRL_SET)
32
R/W
0000_0000h
41.11.53/
2617
21C_C368
Initialize memory buffer control Register
(PXP_HW_PXP_INIT_MEM_CTRL_CLR)
32
R/W
0000_0000h
41.11.53/
2617
21C_C36C
Initialize memory buffer control Register
(PXP_HW_PXP_INIT_MEM_CTRL_TOG)
32
R/W
0000_0000h
41.11.53/
2617
21C_C370
Write data Register (PXP_HW_PXP_INIT_MEM_DATA)
32
R/W
0000_0000h
41.11.54/
2618
21C_C380
Write data Register
(PXP_HW_PXP_INIT_MEM_DATA_HIGH)
32
R/W
0000_0000h
41.11.55/
2618
21C_C390
PXP IRQ Mask Register (PXP_HW_PXP_IRQ_MASK)
32
R/W
0000_0000h
41.11.56/
2619
21C_C394
PXP IRQ Mask Register (PXP_HW_PXP_IRQ_MASK_SET)
32
R/W
0000_0000h
41.11.56/
2619
21C_C398
PXP IRQ Mask Register (PXP_HW_PXP_IRQ_MASK_CLR)
32
R/W
0000_0000h
41.11.56/
2619
21C_C39C
PXP IRQ Mask Register (PXP_HW_PXP_IRQ_MASK_TOG)
32
R/W
0000_0000h
41.11.56/
2619
21C_C3A0
PXP Interrupt Register (PXP_HW_PXP_IRQ)
32
R/W
0000_0000h
41.11.57/
2620
21C_C3A4
PXP Interrupt Register (PXP_HW_PXP_IRQ_SET)
32
R/W
0000_0000h
41.11.57/
2620
21C_C3A8
PXP Interrupt Register (PXP_HW_PXP_IRQ_CLR)
32
R/W
0000_0000h
41.11.57/
2620
21C_C3AC
PXP Interrupt Register (PXP_HW_PXP_IRQ_TOG)
32
R/W
0000_0000h
41.11.57/
2620
21C_C3B0
PXP NEXT Buffer Enable select Register
(PXP_HW_PXP_NEXT_EN)
32
R/W
0000_0000h
41.11.58/
2621
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2552
NXP Semiconductors

<!-- page 2553 -->

PXP memory map (continued)
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
21C_C3B4
PXP NEXT Buffer Enable select Register
(PXP_HW_PXP_NEXT_EN_SET)
32
R/W
0000_0000h
41.11.58/
2621
21C_C3B8
PXP NEXT Buffer Enable select Register
(PXP_HW_PXP_NEXT_EN_CLR)
32
R/W
0000_0000h
41.11.58/
2621
21C_C3BC
PXP NEXT Buffer Enable select Register
(PXP_HW_PXP_NEXT_EN_TOG)
32
R/W
0000_0000h
41.11.58/
2621
21C_C400
Next Frame Pointer (PXP_HW_PXP_NEXT)
32
R/W
0000_0000h
41.11.59/
2622
21C_C410
Debug Control Register (PXP_HW_PXP_DEBUGCTRL)
32
R/W
0000_0000h
41.11.60/
2623
21C_C420
Debug Register (PXP_HW_PXP_DEBUG)
32
R/W
0000_0000h
41.11.61/
2624
21C_C430
Version Register (PXP_HW_PXP_VERSION)
32
R/W
0300_0000h
41.11.62/
2624
21C_CA00
PXP_HW_PXP_DITHER_STORE_SIZE_CH0
32
R/W
0000_0000h
41.11.63/
2625
21C_D100
Fetch engine Control for WFE B Register
(PXP_HW_PXP_WFB_FETCH_CTRL)
32
R/W
0000_0000h
41.11.64/
2625
21C_D104
Fetch engine Control for WFE B Register
(PXP_HW_PXP_WFB_FETCH_CTRL_SET)
32
R/W
0000_0000h
41.11.64/
2625
21C_D108
Fetch engine Control for WFE B Register
(PXP_HW_PXP_WFB_FETCH_CTRL_CLR)
32
R/W
0000_0000h
41.11.64/
2625
21C_D10C
Fetch engine Control for WFE B Register
(PXP_HW_PXP_WFB_FETCH_CTRL_TOG)
32
R/W
0000_0000h
41.11.64/
2625
21C_D110
PXP_HW_PXP_WFB_FETCH_BUF1_ADDR
32
R/W
0000_0000h
41.11.65/
2627
21C_D120
PXP_HW_PXP_WFB_FETCH_BUF1_PITCH
32
R/W
0000_0000h
41.11.66/
2628
21C_D130
PXP_HW_PXP_WFB_FETCH_BUF1_SIZE
32
R/W
0000_0000h
41.11.67/
2628
21C_D140
PXP_HW_PXP_WFB_FETCH_BUF2_ADDR
32
R/W
0000_0000h
41.11.68/
2629
21C_D150
PXP_HW_PXP_WFB_FETCH_BUF2_PITCH
32
R/W
0000_0000h
41.11.69/
2629
21C_D160
PXP_HW_PXP_WFB_FETCH_BUF2_SIZE
32
R/W
0000_0000h
41.11.70/
2630
21C_D170
PXP_HW_PXP_WFB_ARRAY_PIXEL0_MASK
32
R/W
2000_0000h
41.11.71/
2630
21C_D180
PXP_HW_PXP_WFB_ARRAY_PIXEL1_MASK
32
R/W
2000_0000h
41.11.72/
2632
21C_D190
PXP_HW_PXP_WFB_ARRAY_PIXEL2_MASK
32
R/W
2000_0000h
41.11.73/
2633
21C_D1A0
PXP_HW_PXP_WFB_ARRAY_PIXEL3_MASK
32
R/W
2000_0000h
41.11.74/
2634
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2553

<!-- page 2554 -->

PXP memory map (continued)
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
21C_D1B0
PXP_HW_PXP_WFB_ARRAY_PIXEL4_MASK
32
R/W
2000_0000h
41.11.75/
2636
21C_D1C0
PXP_HW_PXP_WFB_ARRAY_PIXEL5_MASK
32
R/W
2000_0000h
41.11.76/
2637
21C_D1D0
PXP_HW_PXP_WFB_ARRAY_PIXEL6_MASK
32
R/W
2000_0000h
41.11.77/
2638
21C_D1E0
PXP_HW_PXP_WFB_ARRAY_PIXEL7_MASK
32
R/W
2000_0000h
41.11.78/
2640
21C_D1F0
PXP_HW_PXP_WFB_ARRAY_FLAG0_MASK
32
R/W
2000_0000h
41.11.79/
2641
21C_D200
PXP_HW_PXP_WFB_ARRAY_FLAG1_MASK
32
R/W
2000_0000h
41.11.80/
2642
21C_D210
PXP_HW_PXP_WFB_ARRAY_FLAG2_MASK
32
R/W
2000_0000h
41.11.81/
2644
21C_D220
PXP_HW_PXP_WFB_ARRAY_FLAG3_MASK
32
R/W
2000_0000h
41.11.82/
2645
21C_D230
PXP_HW_PXP_WFB_ARRAY_FLAG4_MASK
32
R/W
2000_0000h
41.11.83/
2646
21C_D240
PXP_HW_PXP_WFB_ARRAY_FLAG5_MASK
32
R/W
2000_0000h
41.11.84/
2648
21C_D250
PXP_HW_PXP_WFB_ARRAY_FLAG6_MASK
32
R/W
2000_0000h
41.11.85/
2649
21C_D260
PXP_HW_PXP_WFB_ARRAY_FLAG7_MASK
32
R/W
2000_0000h
41.11.86/
2650
21C_D270
PXP_HW_PXP_WFB_FETCH_BUF1_CORD
32
R/W
0000_0000h
41.11.87/
2651
21C_D280
PXP_HW_PXP_WFB_FETCH_BUF2_CORD
32
R/W
0000_0000h
41.11.88/
2652
21C_D290
PXP_HW_PXP_WFB_ARRAY_FLAG8_MASK
32
R/W
2000_0000h
41.11.89/
2653
21C_D2A0
PXP_HW_PXP_WFB_ARRAY_FLAG9_MASK
32
R/W
2000_0000h
41.11.90/
2654
21C_D2B0
PXP_HW_PXP_WFB_ARRAY_FLAG10_MASK
32
R/W
2000_0000h
41.11.91/
2655
21C_D2C0
PXP_HW_PXP_WFB_ARRAY_FLAG11_MASK
32
R/W
2000_0000h
41.11.92/
2657
21C_D2D0
PXP_HW_PXP_WFB_ARRAY_FLAG12_MASK
32
R/W
2000_0000h
41.11.93/
2658
21C_D2E0
PXP_HW_PXP_WFB_ARRAY_FLAG13_MASK
32
R/W
2000_0000h
41.11.94/
2659
21C_D2F0
PXP_HW_PXP_WFB_ARRAY_FLAG14_MASK
32
R/W
2000_0000h
41.11.95/
2661
21C_D300
PXP_HW_PXP_WFB_ARRAY_FLAG15_MASK
32
R/W
2000_0000h
41.11.96/
2662
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2554
NXP Semiconductors

<!-- page 2555 -->

PXP memory map (continued)
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
21C_D310
PXP_HW_PXP_WFB_ARRAY_REG0
32
R/W
0000_0000h
41.11.97/
2663
21C_D320
PXP_HW_PXP_WFB_ARRAY_REG1
32
R/W
0000_0000h
41.11.98/
2664
21C_D330
PXP_HW_PXP_WFB_ARRAY_REG2
32
R/W
0000_0000h
41.11.99/
2665
21C_D340
Store engine Control Channel 0 Register
(PXP_HW_PXP_WFE_B_STORE_CTRL_CH0)
32
R/W
0002_0200h
41.11.100/
2666
21C_D344
Store engine Control Channel 0 Register
(PXP_HW_PXP_WFE_B_STORE_CTRL_CH0_SET)
32
R/W
0002_0200h
41.11.100/
2666
21C_D348
Store engine Control Channel 0 Register
(PXP_HW_PXP_WFE_B_STORE_CTRL_CH0_CLR)
32
R/W
0002_0200h
41.11.100/
2666
21C_D34C
Store engine Control Channel 0 Register
(PXP_HW_PXP_WFE_B_STORE_CTRL_CH0_TOG)
32
R/W
0002_0200h
41.11.100/
2666
21C_D350
Store engine Control Channel 1 Register
(PXP_HW_PXP_WFE_B_STORE_CTRL_CH1)
32
R/W
0002_0200h
41.11.101/
2668
21C_D354
Store engine Control Channel 1 Register
(PXP_HW_PXP_WFE_B_STORE_CTRL_CH1_SET)
32
R/W
0002_0200h
41.11.101/
2668
21C_D358
Store engine Control Channel 1 Register
(PXP_HW_PXP_WFE_B_STORE_CTRL_CH1_CLR)
32
R/W
0002_0200h
41.11.101/
2668
21C_D35C
Store engine Control Channel 1 Register
(PXP_HW_PXP_WFE_B_STORE_CTRL_CH1_TOG)
32
R/W
0002_0200h
41.11.101/
2668
21C_D360
Store engine status Channel 0 Register
(PXP_HW_PXP_WFE_B_STORE_STATUS_CH0)
32
R/W
0000_0000h
41.11.102/
2669
21C_D370
Store engine status Channel 1 Register
(PXP_HW_PXP_WFE_B_STORE_STATUS_CH1)
32
R/W
0000_0000h
41.11.103/
2670
21C_D380
PXP_HW_PXP_WFE_B_STORE_SIZE_CH0
32
R/W
0000_0000h
41.11.104/
2670
21C_D390
PXP_HW_PXP_WFE_B_STORE_SIZE_CH1
32
R/W
0000_0000h
41.11.105/
2671
21C_D3A0
PXP_HW_PXP_WFE_B_STORE_PITCH
32
R/W
0000_0000h
41.11.106/
2671
21C_D3B0
PXP_HW_PXP_WFE_B_STORE_SHIFT_CTRL_CH0
32
R/W
0000_0000h
41.11.107/
2672
21C_D3B4
PXP_HW_PXP_WFE_B_STORE_SHIFT_CTRL_CH0_SET
32
R/W
0000_0000h
41.11.107/
2672
21C_D3B8
PXP_HW_PXP_WFE_B_STORE_SHIFT_CTRL_CH0_CLR
32
R/W
0000_0000h
41.11.107/
2672
21C_D3BC
PXP_HW_PXP_WFE_B_STORE_SHIFT_CTRL_CH0_TOG
32
R/W
0000_0000h
41.11.107/
2672
21C_D3C0
PXP_HW_PXP_WFE_B_STORE_SHIFT_CTRL_CH1
32
R/W
0000_0000h
41.11.108/
2673
21C_D3C4
PXP_HW_PXP_WFE_B_STORE_SHIFT_CTRL_CH1_SET
32
R/W
0000_0000h
41.11.108/
2673
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2555

<!-- page 2556 -->

PXP memory map (continued)
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
21C_D3C8
PXP_HW_PXP_WFE_B_STORE_SHIFT_CTRL_CH1_CLR
32
R/W
0000_0000h
41.11.108/
2673
21C_D3CC
PXP_HW_PXP_WFE_B_STORE_SHIFT_CTRL_CH1_TOG
32
R/W
0000_0000h
41.11.108/
2673
21C_D410
PXP_HW_PXP_WFE_B_STORE_ADDR_0_CH0
32
R/W
0000_0000h
41.11.109/
2674
21C_D420
PXP_HW_PXP_WFE_B_STORE_ADDR_1_CH0
32
R/W
0000_0000h
41.11.110/
2674
21C_D430
PXP_HW_PXP_WFE_B_STORE_FILL_DATA_CH0
32
R/W
0000_0000h
41.11.111/
2675
21C_D440
PXP_HW_PXP_WFE_B_STORE_ADDR_0_CH1
32
R/W
0000_0000h
41.11.112/
2675
21C_D450
PXP_HW_PXP_WFE_B_STORE_ADDR_1_CH1
32
R/W
0000_0000h
41.11.113/
2676
21C_D460
PXP_HW_PXP_WFE_B_STORE_D_MASK0_H_CH0
32
R/W
0000_0000h
41.11.114/
2676
21C_D470
PXP_HW_PXP_WFE_B_STORE_D_MASK0_L_CH0
32
R/W
0000_0000h
41.11.115/
2677
21C_D480
PXP_HW_PXP_WFE_B_STORE_D_MASK1_H_CH0
32
R/W
0000_0000h
41.11.116/
2677
21C_D490
PXP_HW_PXP_WFE_B_STORE_D_MASK1_L_CH0
32
R/W
0000_0000h
41.11.117/
2678
21C_D4A0
PXP_HW_PXP_WFE_B_STORE_D_MASK2_H_CH0
32
R/W
0000_0000h
41.11.118/
2678
21C_D4B0
PXP_HW_PXP_WFE_B_STORE_D_MASK2_L_CH0
32
R/W
0000_0000h
41.11.119/
2679
21C_D4C0
PXP_HW_PXP_WFE_B_STORE_D_MASK3_H_CH0
32
R/W
0000_0000h
41.11.120/
2679
21C_D4D0
PXP_HW_PXP_WFE_B_STORE_D_MASK3_L_CH0
32
R/W
0000_0000h
41.11.121/
2680
21C_D4E0
PXP_HW_PXP_WFE_B_STORE_D_MASK4_H_CH0
32
R/W
0000_0000h
41.11.122/
2680
21C_D4F0
PXP_HW_PXP_WFE_B_STORE_D_MASK4_L_CH0
32
R/W
0000_0000h
41.11.123/
2681
21C_D500
PXP_HW_PXP_WFE_B_STORE_D_MASK5_H_CH0
32
R/W
0000_0000h
41.11.124/
2681
21C_D510
PXP_HW_PXP_WFE_B_STORE_D_MASK5_L_CH0
32
R/W
0000_0000h
41.11.125/
2682
21C_D520
PXP_HW_PXP_WFE_B_STORE_D_MASK6_H_CH0
32
R/W
0000_0000h
41.11.126/
2682
21C_D530
PXP_HW_PXP_WFE_B_STORE_D_MASK6_L_CH0
32
R/W
0000_0000h
41.11.127/
2683
21C_D540
PXP_HW_PXP_WFE_B_STORE_D_MASK7_H_CH0
32
R/W
0000_0000h
41.11.128/
2683
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2556
NXP Semiconductors

<!-- page 2557 -->

PXP memory map (continued)
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
21C_D550
PXP_HW_PXP_WFE_B_STORE_D_MASK7_L_CH0
32
R/W
0000_0000h
41.11.129/
2684
21C_D560
PXP_HW_PXP_WFE_B_STORE_D_SHIFT_L_CH0
32
R/W
0000_0000h
41.11.130/
2684
21C_D570
PXP_HW_PXP_WFE_B_STORE_D_SHIFT_H_CH0
32
R/W
0000_0000h
41.11.131/
2686
21C_D580
PXP_HW_PXP_WFE_B_STORE_F_SHIFT_L_CH0
32
R/W
0000_0000h
41.11.132/
2687
21C_D590
PXP_HW_PXP_WFE_B_STORE_F_SHIFT_H_CH0
32
R/W
0000_0000h
41.11.133/
2689
21C_D5A0
PXP_HW_PXP_WFE_B_STORE_F_MASK_L_CH0
32
R/W
0000_0000h
41.11.134/
2690
21C_D5B0
PXP_HW_PXP_WFE_B_STORE_F_MASK_H_CH0
32
R/W
0000_0000h
41.11.135/
2691
21C_D5D0
PXP_HW_PXP_FETCH_WFE_B_DEBUG
32
R/W
0000_0000h
41.11.136/
2691
21C_D670
Dither Control Register 0 (PXP_HW_PXP_DITHER_CTRL)
32
R/W
0151_4000h
41.11.137/
2693
21C_D674
Dither Control Register 0
(PXP_HW_PXP_DITHER_CTRL_SET)
32
R/W
0151_4000h
41.11.137/
2693
21C_D678
Dither Control Register 0
(PXP_HW_PXP_DITHER_CTRL_CLR)
32
R/W
0151_4000h
41.11.137/
2693
21C_D67C
Dither Control Register 0
(PXP_HW_PXP_DITHER_CTRL_TOG)
32
R/W
0151_4000h
41.11.137/
2693
21C_D680
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA0)
32
R/W
0000_0000h
41.11.138/
2695
21C_D684
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA0_SET)
32
R/W
0000_0000h
41.11.138/
2695
21C_D688
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA0_CLR)
32
R/W
0000_0000h
41.11.138/
2695
21C_D68C
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA0_TOG)
32
R/W
0000_0000h
41.11.138/
2695
21C_D690
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA1)
32
R/W
0000_0000h
41.11.139/
2695
21C_D694
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA1_SET)
32
R/W
0000_0000h
41.11.139/
2695
21C_D698
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA1_CLR)
32
R/W
0000_0000h
41.11.139/
2695
21C_D69C
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA1_TOG)
32
R/W
0000_0000h
41.11.139/
2695
21C_D6A0
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA2)
32
R/W
0000_0000h
41.11.140/
2696
21C_D6A4
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA2_SET)
32
R/W
0000_0000h
41.11.140/
2696
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2557

<!-- page 2558 -->

PXP memory map (continued)
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
21C_D6A8
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA2_CLR)
32
R/W
0000_0000h
41.11.140/
2696
21C_D6AC
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA2_TOG)
32
R/W
0000_0000h
41.11.140/
2696
21C_D6B0
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA3)
32
R/W
0000_0000h
41.11.141/
2696
21C_D6B4
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA3_SET)
32
R/W
0000_0000h
41.11.141/
2696
21C_D6B8
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA3_CLR)
32
R/W
0000_0000h
41.11.141/
2696
21C_D6BC
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA3_TOG)
32
R/W
0000_0000h
41.11.141/
2696
21C_DD00
PXP_HW_PXP_WFE_B_CTRL
32
R/W
0000_0000h
41.11.142/
2697
21C_DD04
PXP_HW_PXP_WFE_B_CTRL_SET
32
R/W
0000_0000h
41.11.142/
2697
21C_DD08
PXP_HW_PXP_WFE_B_CTRL_CLR
32
R/W
0000_0000h
41.11.142/
2697
21C_DD0C
PXP_HW_PXP_WFE_B_CTRL_TOG
32
R/W
0000_0000h
41.11.142/
2697
21C_DD10
PXP_HW_PXP_WFE_B_DIMENSIONS
32
R/W
0000_0000h
41.11.143/
2698
21C_DD20
PXP_HW_PXP_WFE_B_OFFSET
32
R/W
0000_0000h
41.11.144/
2698
21C_DD30
PXP_HW_PXP_WFE_B_SW_DATA_REGS
32
R/W
0000_0000h
41.11.145/
2699
21C_DD40
PXP_HW_PXP_WFE_B_SW_FLAG_REGS
32
R/W
0000_0000h
41.11.146/
2700
21C_DD50
PXP_HW_PXP_WFE_B_STAGE1_MUX0
32
R/W
0000_0000h
41.11.147/
2701
21C_DD54
PXP_HW_PXP_WFE_B_STAGE1_MUX0_SET
32
R/W
0000_0000h
41.11.147/
2701
21C_DD58
PXP_HW_PXP_WFE_B_STAGE1_MUX0_CLR
32
R/W
0000_0000h
41.11.147/
2701
21C_DD5C
PXP_HW_PXP_WFE_B_STAGE1_MUX0_TOG
32
R/W
0000_0000h
41.11.147/
2701
21C_DD60
PXP_HW_PXP_WFE_B_STAGE1_MUX1
32
R/W
0000_0000h
41.11.148/
2702
21C_DD64
PXP_HW_PXP_WFE_B_STAGE1_MUX1_SET
32
R/W
0000_0000h
41.11.148/
2702
21C_DD68
PXP_HW_PXP_WFE_B_STAGE1_MUX1_CLR
32
R/W
0000_0000h
41.11.148/
2702
21C_DD6C
PXP_HW_PXP_WFE_B_STAGE1_MUX1_TOG
32
R/W
0000_0000h
41.11.148/
2702
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2558
NXP Semiconductors

<!-- page 2559 -->

PXP memory map (continued)
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
21C_DD70
PXP_HW_PXP_WFE_B_STAGE1_MUX2
32
R/W
0000_0000h
41.11.149/
2703
21C_DD74
PXP_HW_PXP_WFE_B_STAGE1_MUX2_SET
32
R/W
0000_0000h
41.11.149/
2703
21C_DD78
PXP_HW_PXP_WFE_B_STAGE1_MUX2_CLR
32
R/W
0000_0000h
41.11.149/
2703
21C_DD7C
PXP_HW_PXP_WFE_B_STAGE1_MUX2_TOG
32
R/W
0000_0000h
41.11.149/
2703
21C_DD80
PXP_HW_PXP_WFE_B_STAGE1_MUX3
32
R/W
0000_0000h
41.11.150/
2704
21C_DD84
PXP_HW_PXP_WFE_B_STAGE1_MUX3_SET
32
R/W
0000_0000h
41.11.150/
2704
21C_DD88
PXP_HW_PXP_WFE_B_STAGE1_MUX3_CLR
32
R/W
0000_0000h
41.11.150/
2704
21C_DD8C
PXP_HW_PXP_WFE_B_STAGE1_MUX3_TOG
32
R/W
0000_0000h
41.11.150/
2704
21C_DD90
PXP_HW_PXP_WFE_B_STAGE1_MUX4
32
R/W
0000_0000h
41.11.151/
2705
21C_DD94
PXP_HW_PXP_WFE_B_STAGE1_MUX4_SET
32
R/W
0000_0000h
41.11.151/
2705
21C_DD98
PXP_HW_PXP_WFE_B_STAGE1_MUX4_CLR
32
R/W
0000_0000h
41.11.151/
2705
21C_DD9C
PXP_HW_PXP_WFE_B_STAGE1_MUX4_TOG
32
R/W
0000_0000h
41.11.151/
2705
21C_DDA0
PXP_HW_PXP_WFE_B_STAGE1_MUX5
32
R/W
0000_000Ch
41.11.152/
2706
21C_DDA4
PXP_HW_PXP_WFE_B_STAGE1_MUX5_SET
32
R/W
0000_000Ch
41.11.152/
2706
21C_DDA8
PXP_HW_PXP_WFE_B_STAGE1_MUX5_CLR
32
R/W
0000_000Ch
41.11.152/
2706
21C_DDAC
PXP_HW_PXP_WFE_B_STAGE1_MUX5_TOG
32
R/W
0000_000Ch
41.11.152/
2706
21C_DDB0
PXP_HW_PXP_WFE_B_STAGE1_MUX6
32
R/W
0000_0000h
41.11.153/
2707
21C_DDB4
PXP_HW_PXP_WFE_B_STAGE1_MUX6_SET
32
R/W
0000_0000h
41.11.153/
2707
21C_DDB8
PXP_HW_PXP_WFE_B_STAGE1_MUX6_CLR
32
R/W
0000_0000h
41.11.153/
2707
21C_DDBC
PXP_HW_PXP_WFE_B_STAGE1_MUX6_TOG
32
R/W
0000_0000h
41.11.153/
2707
21C_DDC0
PXP_HW_PXP_WFE_B_STAGE1_MUX7
32
R/W
0000_0000h
41.11.154/
2708
21C_DDC4
PXP_HW_PXP_WFE_B_STAGE1_MUX7_SET
32
R/W
0000_0000h
41.11.154/
2708
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2559

<!-- page 2560 -->

PXP memory map (continued)
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
21C_DDC8
PXP_HW_PXP_WFE_B_STAGE1_MUX7_CLR
32
R/W
0000_0000h
41.11.154/
2708
21C_DDCC
PXP_HW_PXP_WFE_B_STAGE1_MUX7_TOG
32
R/W
0000_0000h
41.11.154/
2708
21C_DDD0
PXP_HW_PXP_WFE_B_STAGE1_MUX8
32
R/W
0000_0000h
41.11.155/
2709
21C_DDD4
PXP_HW_PXP_WFE_B_STAGE1_MUX8_SET
32
R/W
0000_0000h
41.11.155/
2709
21C_DDD8
PXP_HW_PXP_WFE_B_STAGE1_MUX8_CLR
32
R/W
0000_0000h
41.11.155/
2709
21C_DDDC
PXP_HW_PXP_WFE_B_STAGE1_MUX8_TOG
32
R/W
0000_0000h
41.11.155/
2709
21C_DDE0
PXP_HW_PXP_WFE_B_STAGE2_MUX0
32
R/W
0000_0000h
41.11.156/
2709
21C_DDE4
PXP_HW_PXP_WFE_B_STAGE2_MUX0_SET
32
R/W
0000_0000h
41.11.156/
2709
21C_DDE8
PXP_HW_PXP_WFE_B_STAGE2_MUX0_CLR
32
R/W
0000_0000h
41.11.156/
2709
21C_DDEC
PXP_HW_PXP_WFE_B_STAGE2_MUX0_TOG
32
R/W
0000_0000h
41.11.156/
2709
21C_DDF0
PXP_HW_PXP_WFE_B_STAGE2_MUX1
32
R/W
0000_0000h
41.11.157/
2710
21C_DDF4
PXP_HW_PXP_WFE_B_STAGE2_MUX1_SET
32
R/W
0000_0000h
41.11.157/
2710
21C_DDF8
PXP_HW_PXP_WFE_B_STAGE2_MUX1_CLR
32
R/W
0000_0000h
41.11.157/
2710
21C_DDFC
PXP_HW_PXP_WFE_B_STAGE2_MUX1_TOG
32
R/W
0000_0000h
41.11.157/
2710
21C_DE00
PXP_HW_PXP_WFE_B_STAGE2_MUX2
32
R/W
0000_0000h
41.11.158/
2711
21C_DE04
PXP_HW_PXP_WFE_B_STAGE2_MUX2_SET
32
R/W
0000_0000h
41.11.158/
2711
21C_DE08
PXP_HW_PXP_WFE_B_STAGE2_MUX2_CLR
32
R/W
0000_0000h
41.11.158/
2711
21C_DE0C
PXP_HW_PXP_WFE_B_STAGE2_MUX2_TOG
32
R/W
0000_0000h
41.11.158/
2711
21C_DE10
PXP_HW_PXP_WFE_B_STAGE2_MUX3
32
R/W
0000_0000h
41.11.159/
2712
21C_DE14
PXP_HW_PXP_WFE_B_STAGE2_MUX3_SET
32
R/W
0000_0000h
41.11.159/
2712
21C_DE18
PXP_HW_PXP_WFE_B_STAGE2_MUX3_CLR
32
R/W
0000_0000h
41.11.159/
2712
21C_DE1C
PXP_HW_PXP_WFE_B_STAGE2_MUX3_TOG
32
R/W
0000_0000h
41.11.159/
2712
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2560
NXP Semiconductors

<!-- page 2561 -->

PXP memory map (continued)
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
21C_DE20
PXP_HW_PXP_WFE_B_STAGE2_MUX4
32
R/W
0000_0000h
41.11.160/
2713
21C_DE24
PXP_HW_PXP_WFE_B_STAGE2_MUX4_SET
32
R/W
0000_0000h
41.11.160/
2713
21C_DE28
PXP_HW_PXP_WFE_B_STAGE2_MUX4_CLR
32
R/W
0000_0000h
41.11.160/
2713
21C_DE2C
PXP_HW_PXP_WFE_B_STAGE2_MUX4_TOG
32
R/W
0000_0000h
41.11.160/
2713
21C_DE30
PXP_HW_PXP_WFE_B_STAGE2_MUX5
32
R/W
0000_0000h
41.11.161/
2714
21C_DE34
PXP_HW_PXP_WFE_B_STAGE2_MUX5_SET
32
R/W
0000_0000h
41.11.161/
2714
21C_DE38
PXP_HW_PXP_WFE_B_STAGE2_MUX5_CLR
32
R/W
0000_0000h
41.11.161/
2714
21C_DE3C
PXP_HW_PXP_WFE_B_STAGE2_MUX5_TOG
32
R/W
0000_0000h
41.11.161/
2714
21C_DE40
PXP_HW_PXP_WFE_B_STAGE2_MUX6
32
R/W
0000_0000h
41.11.162/
2715
21C_DE44
PXP_HW_PXP_WFE_B_STAGE2_MUX6_SET
32
R/W
0000_0000h
41.11.162/
2715
21C_DE48
PXP_HW_PXP_WFE_B_STAGE2_MUX6_CLR
32
R/W
0000_0000h
41.11.162/
2715
21C_DE4C
PXP_HW_PXP_WFE_B_STAGE2_MUX6_TOG
32
R/W
0000_0000h
41.11.162/
2715
21C_DE50
PXP_HW_PXP_WFE_B_STAGE2_MUX7
32
R/W
0000_0000h
41.11.163/
2716
21C_DE54
PXP_HW_PXP_WFE_B_STAGE2_MUX7_SET
32
R/W
0000_0000h
41.11.163/
2716
21C_DE58
PXP_HW_PXP_WFE_B_STAGE2_MUX7_CLR
32
R/W
0000_0000h
41.11.163/
2716
21C_DE5C
PXP_HW_PXP_WFE_B_STAGE2_MUX7_TOG
32
R/W
0000_0000h
41.11.163/
2716
21C_DE60
PXP_HW_PXP_WFE_B_STAGE2_MUX8
32
R/W
0000_0000h
41.11.164/
2717
21C_DE64
PXP_HW_PXP_WFE_B_STAGE2_MUX8_SET
32
R/W
0000_0000h
41.11.164/
2717
21C_DE68
PXP_HW_PXP_WFE_B_STAGE2_MUX8_CLR
32
R/W
0000_0000h
41.11.164/
2717
21C_DE6C
PXP_HW_PXP_WFE_B_STAGE2_MUX8_TOG
32
R/W
0000_0000h
41.11.164/
2717
21C_DE70
PXP_HW_PXP_WFE_B_STAGE2_MUX9
32
R/W
0000_0000h
41.11.165/
2718
21C_DE74
PXP_HW_PXP_WFE_B_STAGE2_MUX9_SET
32
R/W
0000_0000h
41.11.165/
2718
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2561

<!-- page 2562 -->

PXP memory map (continued)
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
21C_DE78
PXP_HW_PXP_WFE_B_STAGE2_MUX9_CLR
32
R/W
0000_0000h
41.11.165/
2718
21C_DE7C
PXP_HW_PXP_WFE_B_STAGE2_MUX9_TOG
32
R/W
0000_0000h
41.11.165/
2718
21C_DE80
PXP_HW_PXP_WFE_B_STAGE2_MUX10
32
R/W
0000_000Ch
41.11.166/
2719
21C_DE84
PXP_HW_PXP_WFE_B_STAGE2_MUX10_SET
32
R/W
0000_000Ch
41.11.166/
2719
21C_DE88
PXP_HW_PXP_WFE_B_STAGE2_MUX10_CLR
32
R/W
0000_000Ch
41.11.166/
2719
21C_DE8C
PXP_HW_PXP_WFE_B_STAGE2_MUX10_TOG
32
R/W
0000_000Ch
41.11.166/
2719
21C_DE90
PXP_HW_PXP_WFE_B_STAGE2_MUX11
32
R/W
0000_0000h
41.11.167/
2720
21C_DE94
PXP_HW_PXP_WFE_B_STAGE2_MUX11_SET
32
R/W
0000_0000h
41.11.167/
2720
21C_DE98
PXP_HW_PXP_WFE_B_STAGE2_MUX11_CLR
32
R/W
0000_0000h
41.11.167/
2720
21C_DE9C
PXP_HW_PXP_WFE_B_STAGE2_MUX11_TOG
32
R/W
0000_0000h
41.11.167/
2720
21C_DEA0
PXP_HW_PXP_WFE_B_STAGE2_MUX12
32
R/W
0000_0000h
41.11.168/
2721
21C_DEA4
PXP_HW_PXP_WFE_B_STAGE2_MUX12_SET
32
R/W
0000_0000h
41.11.168/
2721
21C_DEA8
PXP_HW_PXP_WFE_B_STAGE2_MUX12_CLR
32
R/W
0000_0000h
41.11.168/
2721
21C_DEAC
PXP_HW_PXP_WFE_B_STAGE2_MUX12_TOG
32
R/W
0000_0000h
41.11.168/
2721
21C_DEB0
PXP_HW_PXP_WFE_B_STAGE3_MUX0
32
R/W
0000_0000h
41.11.169/
2721
21C_DEB4
PXP_HW_PXP_WFE_B_STAGE3_MUX0_SET
32
R/W
0000_0000h
41.11.169/
2721
21C_DEB8
PXP_HW_PXP_WFE_B_STAGE3_MUX0_CLR
32
R/W
0000_0000h
41.11.169/
2721
21C_DEBC
PXP_HW_PXP_WFE_B_STAGE3_MUX0_TOG
32
R/W
0000_0000h
41.11.169/
2721
21C_DEC0
PXP_HW_PXP_WFE_B_STAGE3_MUX1
32
R/W
0000_0000h
41.11.170/
2722
21C_DEC4
PXP_HW_PXP_WFE_B_STAGE3_MUX1_SET
32
R/W
0000_0000h
41.11.170/
2722
21C_DEC8
PXP_HW_PXP_WFE_B_STAGE3_MUX1_CLR
32
R/W
0000_0000h
41.11.170/
2722
21C_DECC
PXP_HW_PXP_WFE_B_STAGE3_MUX1_TOG
32
R/W
0000_0000h
41.11.170/
2722
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2562
NXP Semiconductors

<!-- page 2563 -->

PXP memory map (continued)
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
21C_DED0
PXP_HW_PXP_WFE_B_STAGE3_MUX2
32
R/W
0000_0000h
41.11.171/
2723
21C_DED4
PXP_HW_PXP_WFE_B_STAGE3_MUX2_SET
32
R/W
0000_0000h
41.11.171/
2723
21C_DED8
PXP_HW_PXP_WFE_B_STAGE3_MUX2_CLR
32
R/W
0000_0000h
41.11.171/
2723
21C_DEDC
PXP_HW_PXP_WFE_B_STAGE3_MUX2_TOG
32
R/W
0000_0000h
41.11.171/
2723
21C_DEE0
PXP_HW_PXP_WFE_B_STAGE3_MUX3
32
R/W
0000_0000h
41.11.172/
2724
21C_DEE4
PXP_HW_PXP_WFE_B_STAGE3_MUX3_SET
32
R/W
0000_0000h
41.11.172/
2724
21C_DEE8
PXP_HW_PXP_WFE_B_STAGE3_MUX3_CLR
32
R/W
0000_0000h
41.11.172/
2724
21C_DEEC
PXP_HW_PXP_WFE_B_STAGE3_MUX3_TOG
32
R/W
0000_0000h
41.11.172/
2724
21C_DEF0
PXP_HW_PXP_WFE_B_STAGE3_MUX4
32
R/W
0000_0000h
41.11.173/
2725
21C_DEF4
PXP_HW_PXP_WFE_B_STAGE3_MUX4_SET
32
R/W
0000_0000h
41.11.173/
2725
21C_DEF8
PXP_HW_PXP_WFE_B_STAGE3_MUX4_CLR
32
R/W
0000_0000h
41.11.173/
2725
21C_DEFC
PXP_HW_PXP_WFE_B_STAGE3_MUX4_TOG
32
R/W
0000_0000h
41.11.173/
2725
21C_DF00
PXP_HW_PXP_WFE_B_STAGE3_MUX5
32
R/W
0000_0000h
41.11.174/
2726
21C_DF04
PXP_HW_PXP_WFE_B_STAGE3_MUX5_SET
32
R/W
0000_0000h
41.11.174/
2726
21C_DF08
PXP_HW_PXP_WFE_B_STAGE3_MUX5_CLR
32
R/W
0000_0000h
41.11.174/
2726
21C_DF0C
PXP_HW_PXP_WFE_B_STAGE3_MUX5_TOG
32
R/W
0000_0000h
41.11.174/
2726
21C_DF10
PXP_HW_PXP_WFE_B_STAGE3_MUX6
32
R/W
0000_0000h
41.11.175/
2727
21C_DF14
PXP_HW_PXP_WFE_B_STAGE3_MUX6_SET
32
R/W
0000_0000h
41.11.175/
2727
21C_DF18
PXP_HW_PXP_WFE_B_STAGE3_MUX6_CLR
32
R/W
0000_0000h
41.11.175/
2727
21C_DF1C
PXP_HW_PXP_WFE_B_STAGE3_MUX6_TOG
32
R/W
0000_0000h
41.11.175/
2727
21C_DF20
PXP_HW_PXP_WFE_B_STAGE3_MUX7
32
R/W
0000_0000h
41.11.176/
2728
21C_DF24
PXP_HW_PXP_WFE_B_STAGE3_MUX7_SET
32
R/W
0000_0000h
41.11.176/
2728
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2563

<!-- page 2564 -->

PXP memory map (continued)
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
21C_DF28
PXP_HW_PXP_WFE_B_STAGE3_MUX7_CLR
32
R/W
0000_0000h
41.11.176/
2728
21C_DF2C
PXP_HW_PXP_WFE_B_STAGE3_MUX7_TOG
32
R/W
0000_0000h
41.11.176/
2728
21C_DF30
PXP_HW_PXP_WFE_B_STAGE3_MUX8
32
R/W
0000_0000h
41.11.177/
2729
21C_DF34
PXP_HW_PXP_WFE_B_STAGE3_MUX8_SET
32
R/W
0000_0000h
41.11.177/
2729
21C_DF38
PXP_HW_PXP_WFE_B_STAGE3_MUX8_CLR
32
R/W
0000_0000h
41.11.177/
2729
21C_DF3C
PXP_HW_PXP_WFE_B_STAGE3_MUX8_TOG
32
R/W
0000_0000h
41.11.177/
2729
21C_DF40
PXP_HW_PXP_WFE_B_STAGE3_MUX9
32
R/W
0000_0000h
41.11.178/
2730
21C_DF44
PXP_HW_PXP_WFE_B_STAGE3_MUX9_SET
32
R/W
0000_0000h
41.11.178/
2730
21C_DF48
PXP_HW_PXP_WFE_B_STAGE3_MUX9_CLR
32
R/W
0000_0000h
41.11.178/
2730
21C_DF4C
PXP_HW_PXP_WFE_B_STAGE3_MUX9_TOG
32
R/W
0000_0000h
41.11.178/
2730
21C_DF50
PXP_HW_PXP_WFE_B_STAGE3_MUX10
32
R/W
0000_0000h
41.11.179/
2731
21C_DF54
PXP_HW_PXP_WFE_B_STAGE3_MUX10_SET
32
R/W
0000_0000h
41.11.179/
2731
21C_DF58
PXP_HW_PXP_WFE_B_STAGE3_MUX10_CLR
32
R/W
0000_0000h
41.11.179/
2731
21C_DF5C
PXP_HW_PXP_WFE_B_STAGE3_MUX10_TOG
32
R/W
0000_0000h
41.11.179/
2731
21C_DF60
PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_0
32
R/W
0000_0000h
41.11.180/
2732
21C_DF70
PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_1
32
R/W
0000_0000h
41.11.181/
2732
21C_DF80
PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_2
32
R/W
0000_0000h
41.11.182/
2733
21C_DF90
PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_3
32
R/W
0000_0000h
41.11.183/
2734
21C_DFA0
PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_4
32
R/W
0000_0000h
41.11.184/
2734
21C_DFB0
PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_5
32
R/W
0000_0000h
41.11.185/
2735
21C_DFC0
PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_6
32
R/W
0000_0000h
41.11.186/
2736
21C_DFD0
PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_7
32
R/W
0000_0000h
41.11.187/
2736
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2564
NXP Semiconductors

<!-- page 2565 -->

PXP memory map (continued)
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
21C_DFE0
PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_0
32
R/W
0000_0000h
41.11.188/
2737
21C_DFF0
PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_1
32
R/W
0000_0000h
41.11.189/
2738
21C_E000
PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_2
32
R/W
0000_0000h
41.11.190/
2738
21C_E010
PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_3
32
R/W
0000_0000h
41.11.191/
2739
21C_E020
PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_4
32
R/W
0000_0000h
41.11.192/
2740
21C_E030
PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_5
32
R/W
0000_0000h
41.11.193/
2740
21C_E040
PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_6
32
R/W
0000_0000h
41.11.194/
2741
21C_E050
PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_7
32
R/W
0000_0000h
41.11.195/
2742
21C_E060
PXP_HW_PXP_WFE_B_STAGE1_5X8_MASKS_0
32
R/W
0000_0000h
41.11.196/
2742
21C_E070
PXP_HW_PXP_WFE_B_STG1_5X1_OUT0
32
R/W
0000_0000h
41.11.197/
2743
21C_E080
PXP_HW_PXP_WFE_B_STG1_5X1_MASKS
32
R/W
0000_0000h
41.11.198/
2745
21C_E090
PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_0
32
R/W
0000_0000h
41.11.199/
2746
21C_E0A0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_1
32
R/W
0000_0000h
41.11.200/
2748
21C_E0B0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_2
32
R/W
0000_0000h
41.11.201/
2750
21C_E0C0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_3
32
R/W
0000_0000h
41.11.202/
2752
21C_E0D0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_4
32
R/W
0000_0000h
41.11.203/
2754
21C_E0E0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_5
32
R/W
0000_0000h
41.11.204/
2756
21C_E0F0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_6
32
R/W
0000_0000h
41.11.205/
2758
21C_E100
PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_7
32
R/W
0000_0000h
41.11.206/
2760
21C_E110
PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_0
32
R/W
0000_0000h
41.11.207/
2762
21C_E120
PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_1
32
R/W
0000_0000h
41.11.208/
2764
21C_E130
PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_2
32
R/W
0000_0000h
41.11.209/
2766
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2565

<!-- page 2566 -->

PXP memory map (continued)
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
21C_E140
PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_3
32
R/W
0000_0000h
41.11.210/
2768
21C_E150
PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_4
32
R/W
0000_0000h
41.11.211/
2770
21C_E160
PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_5
32
R/W
0000_0000h
41.11.212/
2772
21C_E170
PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_6
32
R/W
0000_0000h
41.11.213/
2774
21C_E180
PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_7
32
R/W
0000_0000h
41.11.214/
2776
21C_E190
PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_0
32
R/W
0000_0000h
41.11.215/
2778
21C_E1A0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_1
32
R/W
0000_0000h
41.11.216/
2780
21C_E1B0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_2
32
R/W
0000_0000h
41.11.217/
2782
21C_E1C0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_3
32
R/W
0000_0000h
41.11.218/
2784
21C_E1D0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_4
32
R/W
0000_0000h
41.11.219/
2786
21C_E1E0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_5
32
R/W
0000_0000h
41.11.220/
2788
21C_E1F0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_6
32
R/W
0000_0000h
41.11.221/
2790
21C_E200
PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_7
32
R/W
0000_0000h
41.11.222/
2792
21C_E210
PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_0
32
R/W
0000_0000h
41.11.223/
2794
21C_E220
PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_1
32
R/W
0000_0000h
41.11.224/
2796
21C_E230
PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_2
32
R/W
0000_0000h
41.11.225/
2798
21C_E240
PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_3
32
R/W
0000_0000h
41.11.226/
2800
21C_E250
PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_4
32
R/W
0000_0000h
41.11.227/
2802
21C_E260
PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_5
32
R/W
0000_0000h
41.11.228/
2804
21C_E270
PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_6
32
R/W
0000_0000h
41.11.229/
2806
21C_E280
PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_7
32
R/W
0000_0000h
41.11.230/
2808
21C_E290
PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_0
32
R/W
0000_0000h
41.11.231/
2810
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2566
NXP Semiconductors

<!-- page 2567 -->

PXP memory map (continued)
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
21C_E2A0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_1
32
R/W
0000_0000h
41.11.232/
2812
21C_E2B0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_2
32
R/W
0000_0000h
41.11.233/
2814
21C_E2C0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_3
32
R/W
0000_0000h
41.11.234/
2816
21C_E2D0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_4
32
R/W
0000_0000h
41.11.235/
2818
21C_E2E0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_5
32
R/W
0000_0000h
41.11.236/
2820
21C_E2F0
PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_6
32
R/W
0000_0000h
41.11.237/
2822
21C_E300
PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_7
32
R/W
0000_0000h
41.11.238/
2824
21C_E310
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_0
32
R/W
0000_0000h
41.11.239/
2826
21C_E320
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_1
32
R/W
0000_0000h
41.11.240/
2827
21C_E330
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_2
32
R/W
0000_0000h
41.11.241/
2828
21C_E340
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_3
32
R/W
0000_0000h
41.11.242/
2829
21C_E350
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_4
32
R/W
0000_0000h
41.11.243/
2830
21C_E360
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_5
32
R/W
0000_0000h
41.11.244/
2831
21C_E370
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_6
32
R/W
0000_0000h
41.11.245/
2832
21C_E380
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_7
32
R/W
0000_0000h
41.11.246/
2833
21C_E390
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_0
32
R/W
0000_0000h
41.11.247/
2834
21C_E3A0
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_1
32
R/W
0000_0000h
41.11.248/
2835
21C_E3B0
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_2
32
R/W
0000_0000h
41.11.249/
2836
21C_E3C0
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_3
32
R/W
0000_0000h
41.11.250/
2837
21C_E3D0
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_4
32
R/W
0000_0000h
41.11.251/
2838
21C_E3E0
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_5
32
R/W
0000_0000h
41.11.252/
2839
21C_E3F0
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_6
32
R/W
0000_0000h
41.11.253/
2840
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2567

<!-- page 2568 -->

PXP memory map (continued)
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
21C_E400
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_7
32
R/W
0000_0000h
41.11.254/
2841
21C_E410
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_0
32
R/W
0000_0000h
41.11.255/
2842
21C_E420
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_1
32
R/W
0000_0000h
41.11.256/
2843
21C_E430
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_2
32
R/W
0000_0000h
41.11.257/
2844
21C_E440
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_3
32
R/W
0000_0000h
41.11.258/
2845
21C_E450
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_4
32
R/W
0000_0000h
41.11.259/
2846
21C_E460
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_5
32
R/W
0000_0000h
41.11.260/
2847
21C_E470
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_6
32
R/W
0000_0000h
41.11.261/
2848
21C_E480
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_7
32
R/W
0000_0000h
41.11.262/
2849
21C_E490
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_0
32
R/W
0000_0000h
41.11.263/
2850
21C_E4A0
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_1
32
R/W
0000_0000h
41.11.264/
2851
21C_E4B0
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_2
32
R/W
0000_0000h
41.11.265/
2852
21C_E4C0
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_3
32
R/W
0000_0000h
41.11.266/
2853
21C_E4E0
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_4
32
R/W
0000_0000h
41.11.267/
2854
21C_E4F0
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_5
32
R/W
0000_0000h
41.11.268/
2855
21C_E500
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_6
32
R/W
0000_0000h
41.11.269/
2856
21C_E510
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_7
32
R/W
0000_0000h
41.11.270/
2857
21C_E520
PXP_HW_PXP_WFE_B_STAGE2_5X6_MASKS_0
32
R/W
0000_0000h
41.11.271/
2858
21C_E530
PXP_HW_PXP_WFE_B_STAGE2_5X6_ADDR_0
32
R/W
0000_0000h
41.11.272/
2859
21C_E540
PXP_HW_PXP_WFE_B_STG2_5X1_OUT0
32
R/W
0000_0000h
41.11.273/
2860
21C_E550
PXP_HW_PXP_WFE_B_STG2_5X1_OUT1
32
R/W
0000_0000h
41.11.274/
2862
21C_E560
PXP_HW_PXP_WFE_B_STG2_5X1_OUT2
32
R/W
0000_0000h
41.11.275/
2864
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2568
NXP Semiconductors

<!-- page 2569 -->

PXP memory map (continued)
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
21C_E570
PXP_HW_PXP_WFE_B_STG2_5X1_OUT3
32
R/W
0000_0000h
41.11.276/
2866
21C_E580
PXP_HW_PXP_WFE_B_STG2_5X1_MASKS
32
R/W
0000_0000h
41.11.277/
2868
21C_E590
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_0
32
R/W
0000_0000h
41.11.278/
2869
21C_E5A0
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_1
32
R/W
0000_0000h
41.11.279/
2871
21C_E5B0
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_2
32
R/W
0000_0000h
41.11.280/
2873
21C_E5C0
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_3
32
R/W
0000_0000h
41.11.281/
2875
21C_E5D0
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_4
32
R/W
0000_0000h
41.11.282/
2877
21C_E5E0
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_5
32
R/W
0000_0000h
41.11.283/
2879
21C_E5F0
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_6
32
R/W
0000_0000h
41.11.284/
2881
21C_E600
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_7
32
R/W
0000_0000h
41.11.285/
2883
21C_E610
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_0
32
R/W
0000_0000h
41.11.286/
2885
21C_E620
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_1
32
R/W
0000_0000h
41.11.287/
2887
21C_E630
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_2
32
R/W
0000_0000h
41.11.288/
2889
21C_E640
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_3
32
R/W
0000_0000h
41.11.289/
2891
21C_E650
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_4
32
R/W
0000_0000h
41.11.290/
2893
21C_E660
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_5
32
R/W
0000_0000h
41.11.291/
2895
21C_E670
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_6
32
R/W
0000_0000h
41.11.292/
2897
21C_E680
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_7
32
R/W
0000_0000h
41.11.293/
2899
21C_E690
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_0
32
R/W
0000_0000h
41.11.294/
2901
21C_E6A0
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_1
32
R/W
0000_0000h
41.11.295/
2903
21C_E6B0
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_2
32
R/W
0000_0000h
41.11.296/
2905
21C_E6C0
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_3
32
R/W
0000_0000h
41.11.297/
2907
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2569

<!-- page 2570 -->

PXP memory map (continued)
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
21C_E6D0
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_4
32
R/W
0000_0000h
41.11.298/
2909
21C_E6E0
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_5
32
R/W
0000_0000h
41.11.299/
2911
21C_E6F0
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_6
32
R/W
0000_0000h
41.11.300/
2913
21C_E700
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_7
32
R/W
0000_0000h
41.11.301/
2915
21C_E710
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_0
32
R/W
0000_0000h
41.11.302/
2917
21C_E720
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_1
32
R/W
0000_0000h
41.11.303/
2919
21C_E730
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_2
32
R/W
0000_0000h
41.11.304/
2921
21C_E740
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_3
32
R/W
0000_0000h
41.11.305/
2923
21C_E750
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_4
32
R/W
0000_0000h
41.11.306/
2925
21C_E760
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_5
32
R/W
0000_0000h
41.11.307/
2927
21C_E770
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_6
32
R/W
0000_0000h
41.11.308/
2929
21C_E780
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_7
32
R/W
0000_0000h
41.11.309/
2931
21C_E790
PXP_HW_PXP_WFE_B_STG3_F8X1_MASKS
32
R/W
0000_0000h
41.11.310/
2933
21C_E8A0
PXP_HW_PXP_ALU_B_CTRL
32
R/W
0000_1000h
41.11.311/
2934
21C_E8A4
PXP_HW_PXP_ALU_B_CTRL_SET
32
R/W
0000_1000h
41.11.311/
2934
21C_E8A8
PXP_HW_PXP_ALU_B_CTRL_CLR
32
R/W
0000_1000h
41.11.311/
2934
21C_E8AC
PXP_HW_PXP_ALU_B_CTRL_TOG
32
R/W
0000_1000h
41.11.311/
2934
21C_E8B0
PXP_HW_PXP_ALU_B_BUF_SIZE
32
R/W
0000_0000h
41.11.312/
2935
21C_E8C0
PXP_HW_PXP_ALU_B_INST_ENTRY
32
R/W
0000_0000h
41.11.313/
2936
21C_E8D0
PXP_HW_PXP_ALU_B_PARAM
32
R/W
0000_0000h
41.11.314/
2936
21C_E8E0
PXP_HW_PXP_ALU_B_CONFIG
32
R/W
0000_0000h
41.11.315/
2937
21C_E8F0
PXP_HW_PXP_ALU_B_LUT_CONFIG
32
R/W
0000_0000h
41.11.316/
2937
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2570
NXP Semiconductors

<!-- page 2571 -->

PXP memory map (continued)
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
21C_E8F4
PXP_HW_PXP_ALU_B_LUT_CONFIG_SET
32
R/W
0000_0000h
41.11.316/
2937
21C_E8F8
PXP_HW_PXP_ALU_B_LUT_CONFIG_CLR
32
R/W
0000_0000h
41.11.316/
2937
21C_E8FC
PXP_HW_PXP_ALU_B_LUT_CONFIG_TOG
32
R/W
0000_0000h
41.11.316/
2937
21C_E900
PXP_HW_PXP_ALU_B_LUT_DATA0
32
R/W
0000_0000h
41.11.317/
2938
21C_E910
PXP_HW_PXP_ALU_B_LUT_DATA1
32
R/W
0000_0000h
41.11.318/
2938
21C_E920
PXP_HW_PXP_ALU_B_DBG
32
R/W
0000_0000h
41.11.319/
2939
21C_EA00
Histogram Control Register.
(PXP_HW_PXP_HIST_A_CTRL)
32
R/W
0500_1F00h
41.11.320/
2940
21C_EA10
Histogram Pixel Mask Register.
(PXP_HW_PXP_HIST_A_MASK)
32
R/W
0000_0000h
41.11.321/
2941
21C_EA20
Histogram Pixel Buffer Size Register.
(PXP_HW_PXP_HIST_A_BUF_SIZE)
32
R/W
0000_0000h
41.11.322/
2942
21C_EA30
Total Number of Pixels Used by Histogram Engine.
(PXP_HW_PXP_HIST_A_TOTAL_PIXEL)
32
R/W
0000_0000h
41.11.323/
2942
21C_EA40
The X Coordinate Offset for Active Area.
(PXP_HW_PXP_HIST_A_ACTIVE_AREA_X)
32
R/W
0000_0000h
41.11.324/
2943
21C_EA50
The Y Coordinate Offset for Active Area.
(PXP_HW_PXP_HIST_A_ACTIVE_AREA_Y)
32
R/W
0000_0000h
41.11.325/
2943
21C_EA60
Histogram Result Based on RAW Pixel Value.
(PXP_HW_PXP_HIST_A_RAW_STAT0)
32
R/W
0000_0000h
41.11.326/
2944
21C_EA70
Histogram Result Based on RAW Pixel Value.
(PXP_HW_PXP_HIST_A_RAW_STAT1)
32
R/W
0000_0000h
41.11.327/
2944
21C_EA80
Histogram Control Register.
(PXP_HW_PXP_HIST_B_CTRL)
32
R/W
0500_1F00h
41.11.328/
2945
21C_EA90
Histogram Pixel Mask Register.
(PXP_HW_PXP_HIST_B_MASK)
32
R/W
0000_0000h
41.11.329/
2946
21C_EAA0
Histogram Pixel Buffer Size Register.
(PXP_HW_PXP_HIST_B_BUF_SIZE)
32
R/W
0000_0000h
41.11.330/
2947
21C_EAB0
Total Number of Pixels Used by Histogram Engine.
(PXP_HW_PXP_HIST_B_TOTAL_PIXEL)
32
R/W
0000_0000h
41.11.331/
2948
21C_EAC0
The X Coordinate Offset for Active Area.
(PXP_HW_PXP_HIST_B_ACTIVE_AREA_X)
32
R/W
0000_0000h
41.11.332/
2948
21C_EAD0
The Y Coordinate Offset for Active Area.
(PXP_HW_PXP_HIST_B_ACTIVE_AREA_Y)
32
R/W
0000_0000h
41.11.333/
2949
21C_EAE0
Histogram Result Based on RAW Pixel Value.
(PXP_HW_PXP_HIST_B_RAW_STAT0)
32
R/W
0000_0000h
41.11.334/
2949
21C_EAF0
Histogram Result Based on RAW Pixel Value.
(PXP_HW_PXP_HIST_B_RAW_STAT1)
32
R/W
0000_0000h
41.11.335/
2950
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2571

<!-- page 2572 -->

PXP memory map (continued)
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
21C_EB00
2-level Histogram Parameter Register.
(PXP_HW_PXP_HIST2_PARAM)
32
R/W
0000_0F00h
41.11.336/
2950
21C_EB10
4-level Histogram Parameter Register.
(PXP_HW_PXP_HIST4_PARAM)
32
R/W
0F0A_0500h
41.11.337/
2951
21C_EB20
8-level Histogram Parameter 0 Register.
(PXP_HW_PXP_HIST8_PARAM0)
32
R/W
0604_0200h
41.11.338/
2951
21C_EB30
8-level Histogram Parameter 1 Register.
(PXP_HW_PXP_HIST8_PARAM1)
32
R/W
0F0D_0B09h
41.11.339/
2952
21C_EB40
16-level Histogram Parameter 0 Register.
(PXP_HW_PXP_HIST16_PARAM0)
32
R/W
0302_0100h
41.11.340/
2953
21C_EB50
16-level Histogram Parameter 1 Register.
(PXP_HW_PXP_HIST16_PARAM1)
32
R/W
0706_0504h
41.11.341/
2954
21C_EB60
16-level Histogram Parameter 2 Register.
(PXP_HW_PXP_HIST16_PARAM2)
32
R/W
0B0A_0908h
41.11.342/
2954
21C_EB70
16-level Histogram Parameter 3 Register.
(PXP_HW_PXP_HIST16_PARAM3)
32
R/W
0F0E_0D0Ch
41.11.343/
2955
21C_EB80
32-level Histogram Parameter 0 Register.
(PXP_HW_PXP_HIST32_PARAM0)
32
R/W
0302_0100h
41.11.344/
2956
21C_EB90
32-level Histogram Parameter 1 Register.
(PXP_HW_PXP_HIST32_PARAM1)
32
R/W
0706_0504h
41.11.345/
2957
21C_EBA0
32-level Histogram Parameter 2 Register.
(PXP_HW_PXP_HIST32_PARAM2)
32
R/W
0B0A_0908h
41.11.346/
2957
21C_EBB0
32-level Histogram Parameter 3 Register.
(PXP_HW_PXP_HIST32_PARAM3)
32
R/W
0F0E_0D0Ch
41.11.347/
2958
21C_EBC0
32-level Histogram Parameter 0 Register.
(PXP_HW_PXP_HIST32_PARAM4)
32
R/W
0302_0100h
41.11.348/
2959
21C_EBD0
32-level Histogram Parameter 1 Register.
(PXP_HW_PXP_HIST32_PARAM5)
32
R/W
0706_0504h
41.11.349/
2960
21C_EBE0
32-level Histogram Parameter 2 Register.
(PXP_HW_PXP_HIST32_PARAM6)
32
R/W
0B0A_0908h
41.11.350/
2960
21C_EBF0
32-level Histogram Parameter 3 Register.
(PXP_HW_PXP_HIST32_PARAM7)
32
R/W
0F0E_0D0Ch
41.11.351/
2961
21C_ECF0
PXP_HW_PXP_HANDSHAKE_READY_MUX0
32
R/W
7654_3210h
41.11.352/
2962
21C_ED10
PXP_HW_PXP_HANDSHAKE_DONE_MUX0
32
R/W
7654_3210h
41.11.353/
2962
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2572
NXP Semiconductors

<!-- page 2573 -->

41.11.1
Control Register 0 (PXP_HW_PXP_CTRLn)
The Control register contains the primary controls for the PXP block.
Address: 21C_C000h base + 0h offset + (4d × i), where i=0d to 3d
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
0
EN_REPEAT
ENABLE_ROTATE1
ENABLE_ROTATE0
ENABLE_LUT
ENABLE_CSC2
BLOCK_SIZE
0
ENABLE_WFE_B
0
ENABLE_DITHER
ENABLE_PS_AS_
OUT
W
Reset
1
1
0
0
0
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
VFLIP1
HFLIP1
ROTATE1
VFLIP0
HFLIP0
ROTATE0
0
HANDSHAKE_
ABORT_SKIP
ENABLE_LCD0_
HANDSHAKE
LUT_DMA_IRQ_
ENABLE
NEXT_IRQ_ENABLE
IRQ_ENABLE
ENABLE
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
PXP_HW_PXP_CTRLn field descriptions
Field
Description
31
SFTRST
Set this bit to zero to enable normal PXP operation. Set this bit to one (default) to disable clocking with the
PXP and hold it in its reset (lowest power) state. This bit can be turned on and then off to reset the PXP
block to its default state.
30
CLKGATE
This bit must be set to zero for normal operation. When set to one it gates off the clocks to the block.
29
Reserved
This read-only field is reserved and always has the value 0.
28
EN_REPEAT
Enable the PXP to run continuously. When this bit is set, the PXP will repeat based on the current
configuration register settings. If this bit is not set, the PXP will complete the process and enter the idle
state ready to accept the next frame to be processed. This bit should be set when the LCDIF handshake
mode is enabled so that the next frame is automatically generated for the next screen refresh cycle. If it
not set and the handshake mode is enabled, the CPU will have to initiate the PXP for the next refresh
cycle. When the PXP NEXT feature is used, it has priority over the REPEAT mode, in that the new register
settings are fetched first, and then the next PXP operation will continue.
27
ENABLE_
ROTATE1
Enable the ROTATE1 engine in the PXP primary processing flow.
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2573

<!-- page 2574 -->

PXP_HW_PXP_CTRLn field descriptions (continued)
Field
Description
26
ENABLE_
ROTATE0
Enable the ROTATE0 engine in the PXP primary processing flow.
25
ENABLE_LUT
Enable the LUT engine in the PXP primary processing flow.
24
ENABLE_CSC2
Enable the CSC2 engine in the PXP primary processing flow.
23
BLOCK_SIZE
Select the block size to process through the Rotate block.
22–20
Reserved
This read-only field is reserved and always has the value 0.
19
ENABLE_WFE_B
Enable the WFE-B engine in the PXP primary processing flow.
18
Reserved
This read-only field is reserved and always has the value 0.
17
ENABLE_
DITHER
Enable the Dithering engine in the PXP primary processing flow.
16
ENABLE_PS_
AS_OUT
Enable the PS engine, AS engine, OUTBUF in the PXP primary processing flow.
15
VFLIP1
Indicates that the input should be flipped vertically (effect applied before rotation).
14
HFLIP1
Indicates that the input should be flipped horizontally (effect applied before rotation).
13–12
ROTATE1
Indicates the clockwise rotation to be applied at the input buffer. The rotation effect is defined as occurring
after the FLIP_X and FLIP_Y permutation.
11
VFLIP0
Indicates that the output buffer should be flipped vertically (effect applied before rotation).
10
HFLIP0
Indicates that the output buffer should be flipped horizontally (effect applied before rotation).
9–8
ROTATE0
Indicates the clockwise rotation to be applied at the output buffer. The rotation effect is defined as
occurring after the FLIP_X and FLIP_Y permutation.
7–6
Reserved
This read-only field is reserved and always has the value 0.
5
HANDSHAKE_
ABORT_SKIP
When skip is enable, even the abort asserted, pxp will not assert the ready directly but wait for whole
block line complete.
4
ENABLE_LCD0_
HANDSHAKE
Enable handshake with LCD0 controller. When this is set, the PXP will not process an entire framebuffer,
but will instead process rows of NxN blocks in a double-buffer handshake with the LCDIF. This enables
the use of the onboard SRAM for a partial frame buffer.
3
LUT_DMA_IRQ_
ENABLE
LUT DMA interrupt enable. When set, the PXP will issue an interrupt when the LUT DMA has finished
transferring data.
2
NEXT_IRQ_
ENABLE
Next command interrupt enable. When set, the PXP will issue an interrupt when a queued command
initiated by a write to the PXP_NEXT register has been loaded into the PXP's registers. This interrupt also
indicates that a new command may now be queued.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2574
NXP Semiconductors

<!-- page 2575 -->

PXP_HW_PXP_CTRLn field descriptions (continued)
Field
Description
1
IRQ_ENABLE
Interrupt enable. NOTE: When using the HW_PXP_NEXT functionality to reprogram the PXP, the new
value of this bit will be used and may therefore enable or disable an interrupt unintentionally.
0
ENABLE
Enables PXP operation with specified parameters. The ENABLE bit will remain set while the PXP is active
and will be cleared once the current operation completes. Software should use the IRQ bit in the
HW_PXP_STAT when polling for PXP completion.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2575

<!-- page 2576 -->

41.11.2
Status Register (PXP_HW_PXP_STATn)
This register provides PXP interrupt status and the current X/Y block coordinate that is
being processed.
Address: 21C_C000h base + 10h offset + (4d × i), where i=0d to 3d
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
BLOCKX
BLOCKY
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
AXI_ERROR_ID_1
0
AXI_READ_ERROR_1
AXI_WRITE_ERROR_1
LUT_DMA_LOAD_DONE_IRQ
AXI_ERROR_ID_0
NEXT_IRQ
AXI_READ_ERROR_0
AXI_WRITE_ERROR_0
IRQ0
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
PXP_HW_PXP_STATn field descriptions
Field
Description
31–24
BLOCKX
Indicates the X coordinate of the block currently being rendered.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2576
NXP Semiconductors

<!-- page 2577 -->

PXP_HW_PXP_STATn field descriptions (continued)
Field
Description
23–16
BLOCKY
Indicates the X coordinate of the block currently being rendered.
15–12
AXI_ERROR_ID_
1
Indicates the AXI1 ID of the failing bus operation.
11
Reserved
This read-only field is reserved and always has the value 0.
10
AXI_READ_
ERROR_1
Indicates PXP encountered an AXI read error and processing has been terminated.
9
AXI_WRITE_
ERROR_1
Indicates PXP encountered an AXI write error and processing has been terminated.
8
LUT_DMA_
LOAD_DONE_
IRQ
Indicates that the LUT DMA transfer has completed.
7–4
AXI_ERROR_ID_
0
Indicates the AXI0 ID of the failing bus operation.
3
NEXT_IRQ
Indicates that a command issued with the "Next Command" functionality has been issued and that a new
command may be initiated with a write to the PXP_NEXT register.
2
AXI_READ_
ERROR_0
Indicates PXP encountered an AXI read error and processing has been terminated.
1
AXI_WRITE_
ERROR_0
Indicates PXP encountered an AXI write error and processing has been terminated.
0
IRQ0
Indicates current PXP interrupt status. The IRQ is routed through the pxp_irq when the IRQ_ENABLE bit
in the control register is set.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2577

<!-- page 2578 -->

41.11.3
Output Buffer Control Register
(PXP_HW_PXP_OUT_CTRLn)
Control register to determine OUT buffer processing.
Address: 21C_C000h base + 20h offset + (4d × i), where i=0d to 3d
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
ALPHA
ALPHA_OUTPUT
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
INTERLACED_
OUTPUT
0
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
0
0
0
0
PXP_HW_PXP_OUT_CTRLn field descriptions
Field
Description
31–24
ALPHA
When generating an output buffer with an alpha component, the value in this field will be used when
enabled to override the alpha passed through the pixel data pipeline.
23
ALPHA_
OUTPUT
Indicates that alpha component in output buffer pixels should be overwritten by REG_OUT_CTRL[ALPHA]
register. If 0, retain their alpha value from the computed alpha for that pixel.
22–10
Reserved
This read-only field is reserved and always has the value 0.
9–8
INTERLACED_
OUTPUT
Determines how the PXP writes it's output data. Output interlacing should not be used in conjunction with
input interlacing. Splitting frames into fields is most efficient using output interlacing. 2-plane output
formats AND interlaced output is NOT supported.
7–5
Reserved
This read-only field is reserved and always has the value 0.
FORMAT
Output framebuffer format. The UV byte lanes are synonymous with CbCr byte lanes for YUV output pixel
formats. For example, the YUV2P420 format should be selected when the output is YCbCr 2-plane 420
output format.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2578
NXP Semiconductors

<!-- page 2579 -->

41.11.4
Output Frame Buffer Pointer (PXP_HW_PXP_OUT_BUF)
This register is used by the logic to point to the current output location for the output
frame buffer.
Address: 21C_C000h base + 30h offset = 21C_C030h
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
PXP_HW_PXP_OUT_BUF field descriptions
Field
Description
ADDR
Current address pointer for the output frame buffer. The address can have any byte alignment. 64B
alignment is recommended for optimal performance.
41.11.5
Output Frame Buffer Pointer #2
(PXP_HW_PXP_OUT_BUF2)
This register is used by the logic to point to the current output location for the field 1 or
UV output frame buffer.
Address: 21C_C000h base + 40h offset = 21C_C040h
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
PXP_HW_PXP_OUT_BUF2 field descriptions
Field
Description
ADDR
Current address pointer for the output frame buffer. The address can have any byte alignment. 64B
alignment is recommended for optimal performance.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2579

<!-- page 2580 -->

41.11.6
Output Buffer Pitch (PXP_HW_PXP_OUT_PITCH)
Any byte value will indicate the vertical pitch. This value will be used in output pixel
address calculations.
Address: 21C_C000h base + 50h offset = 21C_C050h
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
PITCH
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
PXP_HW_PXP_OUT_PITCH field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
PITCH
Indicates the number of bytes in memory between two vertically adjacent pixels.
41.11.7
Output Surface Lower Right Coordinate
(PXP_HW_PXP_OUT_LRC)
This register sets the size of the output frame buffer in pixels, not blocks. The frame
buffer need not be a multiple of NxN pixels. Partial blocks will be written for output
frame buffer sizes that are not divisable by N pixels in either dimension.
Address: 21C_C000h base + 60h offset = 21C_C060h
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
X
0
Y
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
PXP_HW_PXP_OUT_LRC field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–16
X
Indicates number of horizontal PIXELS in the output surface (non-rotated). The output buffer pixel width
minus 1 should be programmed. The image size is not required to be a multiple of 8 pixels. The PXP will
clip the pixel output at this boundary.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2580
NXP Semiconductors

<!-- page 2581 -->

PXP_HW_PXP_OUT_LRC field descriptions (continued)
Field
Description
15–14
Reserved
This read-only field is reserved and always has the value 0.
Y
Indicates the number of vertical PIXELS in the output surface (non-rotated). The output buffer pixel height
minus 1 should be programmed. The image size is not required to be a multiple of 8 pixels. The PXP will
clip the pixel output at this boundary.
41.11.8
Processed Surface Upper Left Coordinate
(PXP_HW_PXP_OUT_PS_ULC)
This register contains the upper left coordinate of the Processed Surface in the output
frame buffer (in pixels). Values that are within the REG_OUT_LRC[X,Y] extents are
valid. The lowest valid value for these fields is 0,0. If the value of the
REG_OUT_PS_ULC is greater than the REG_OUT_LRC, then no PS pixels will be
fetched from memory, but only REG_PS_BACKGROUND pixels will be processed by
the PS engine. Pixel locations that are greater than or equal to the PS upper left
coordinates, less than or equal to the PS lower right coordinates, and within the
REG_OUT_LRC extents will use the PS to render pixels into the output buffer.
Address: 21C_C000h base + 70h offset = 21C_C070h
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
X
0
Y
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
PXP_HW_PXP_OUT_PS_ULC field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–16
X
This field indicates the upper left X-coordinate (in pixels) of the processed surface (PS) in the output
buffer.
15–14
Reserved
This read-only field is reserved and always has the value 0.
Y
This field indicates the upper left Y-coordinate (in pixels) of the processed surface in the output buffer.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2581

<!-- page 2582 -->

41.11.9
Processed Surface Lower Right Coordinate
(PXP_HW_PXP_OUT_PS_LRC)
This register contains the lower right coordinate of the Processed Surface in the output
frame buffer (in pixels). Values that are within the REG_OUT_LRC[X,Y] extents are
valid. The lowest valid value for these fields is 0,0. Pixel locations that are greater than or
equal to the PS upper left coordinates, less than or equal to the PS lower right
coordinates, and within the REG_OUT_LRC extents will use the PS to render pixels into
the output buffer.
Address: 21C_C000h base + 80h offset = 21C_C080h
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
X
0
Y
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
PXP_HW_PXP_OUT_PS_LRC field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–16
X
This field indicates the lower right X-coordinate (in pixels) of the processed surface (PS) in the output
frame buffer.
15–14
Reserved
This read-only field is reserved and always has the value 0.
Y
This field indicates the lower right Y-coordinate (in pixels) of the processed surface in the output frame
buffer.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2582
NXP Semiconductors

<!-- page 2583 -->

41.11.10
Alpha Surface Upper Left Coordinate
(PXP_HW_PXP_OUT_AS_ULC)
This register contains the upper left coordinate of AS in the output frame buffer (in
pixels). Values that are within the REG_OUT_LRC[X,Y] extents are valid. The lowest
valid value for these fields is 0,0. Pixel locations that are greater than or equal to the
upper left coordinates will use the AS to render pixels in the output buffer.
Address: 21C_C000h base + 90h offset = 21C_C090h
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
X
0
Y
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
PXP_HW_PXP_OUT_AS_ULC field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–16
X
This field indicates the upper left X-coordinate (in pixels) of the alpha surface (AS) in the output frame
buffer.
15–14
Reserved
This read-only field is reserved and always has the value 0.
Y
This field indicates the upper left Y-coordinate (in pixels) of the alpha surface in the output frame buffer.
41.11.11
Alpha Surface Lower Right Coordinate
(PXP_HW_PXP_OUT_AS_LRC)
This register contains the lower right coordinate of AS in the output frame buffer (in
pixels). Values that are within the REG_OUT_LRC[X,Y] extents are valid. The lowest
valid value for these fields is 0,0. Pixel locations that are less than or equal to the lower
right coordinates will use the AS to render pixels in the output buffer.
Address: 21C_C000h base + A0h offset = 21C_C0A0h
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
X
0
Y
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2583

<!-- page 2584 -->

PXP_HW_PXP_OUT_AS_LRC field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–16
X
This field indicates the lower right X-coordinate (in pixels) of the alpha surface (AS) in the output frame
buffer.
15–14
Reserved
This read-only field is reserved and always has the value 0.
Y
This field indicates the lower right Y-coordinate (in pixels) of the alpha surface in the output frame buffer.
41.11.12
Processed Surface (PS) Control Register
(PXP_HW_PXP_PS_CTRLn)
Control register to determine PS buffer processing.
Address: 21C_C000h base + B0h offset + (4d × i), where i=0d to 3d
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
DECX
DECY
0
WB_SWAP
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
0
0
0
0
PXP_HW_PXP_PS_CTRLn field descriptions
Field
Description
31–12
Reserved
This read-only field is reserved and always has the value 0.
11–10
DECX
Horizontal pre decimation filter control.
9–8
DECY
Verticle pre decimation filter control.
7
Reserved
This read-only field is reserved and always has the value 0.
6
WB_SWAP
Swap bytes in words. For each 16 bit word, the two bytes will be swapped.
FORMAT
PS buffer format. To select between YUV and YCbCr formats, see bit 31 of the CSC1_COEF0 register.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2584
NXP Semiconductors

<!-- page 2585 -->

41.11.13
PS Input Buffer Address (PXP_HW_PXP_PS_BUF)
This register contains the pointer to the Luma/RGB buffer. If the application requires an
offset into the PS buffer, then this address can be set so that the desired offset is achieved.
Any byte address is valid. For best performance, 64B alignment is recommended.
Address: 21C_C000h base + C0h offset = 21C_C0C0h
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
PXP_HW_PXP_PS_BUF field descriptions
Field
Description
ADDR
Address pointer for the PS RGB or Y (luma) input buffer.
41.11.14
PS U/Cb or 2 Plane UV Input Buffer Address
(PXP_HW_PXP_PS_UBUF)
This register contains the pointer to the Chroma U/Cb or 2 plane UV buffer. This register
is unused when processing 1-plane buffer formats. If the application requires an offset
into the PS buffer, then this address can be set so that the desired offset is achieved. Any
byte address is valid. For best performance, 64B alignment is recommended.
Address: 21C_C000h base + D0h offset = 21C_C0D0h
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
PXP_HW_PXP_PS_UBUF field descriptions
Field
Description
ADDR
Address pointer for the PS U/Cb or 2 plane UV Chroma input buffer.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2585

<!-- page 2586 -->

41.11.15
PS V/Cr Input Buffer Address
(PXP_HW_PXP_PS_VBUF)
This register contains the pointer to the Chroma V/Cr buffer. For Y8/Y4 modes, the low
16 bits are used as the monochrome U and V values in the data path. Bits [15:8] represent
the U data byte, and bits ]7:0] represent the V data byte. Other than with Y8/Y4 input
buffer formats, this register is unused when processing 1 or 2-plane buffer formats. If the
application requires an offset into the PS buffer, then this address can be set so that the
desired offset is achieved. Any byte address is valid. For best performance, 64B
alignment is recommended.
Address: 21C_C000h base + E0h offset = 21C_C0E0h
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
PXP_HW_PXP_PS_VBUF field descriptions
Field
Description
ADDR
Address pointer for the PS V/Cr Chroma input buffer.
41.11.16
Processed Surface Pitch (PXP_HW_PXP_PS_PITCH)
Any byte value will indicate the vertical pitch of the PS source frame buffer. This value
will be used in PS pixel address calculations. This value has no relation to the UL and LR
registers. It specifies how many bytes are between two vertically adjacent pixels in the
input PS surface. For multi-plane formats, the Y buffer pitch should be programmed. For
2-plane YUV422, the UV pitch is the same as the Y pitch. For 3-plane YUV422, the U
and V pitch is 1/2 the Y pitch. For 2-plane YUV420, the UV pitch is 1/2 the Y pitch. For
3-plane YUV420, the U and V pitch is 1/4 the Y pitch. All source buffers should comply
with these U and V resolution reductions with respect to their Y source buffers.
Address: 21C_C000h base + F0h offset = 21C_C0F0h
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
PITCH
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2586
NXP Semiconductors

<!-- page 2587 -->

PXP_HW_PXP_PS_PITCH field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
PITCH
Indicates the number of bytes in memory between two vertically adjacent pixels.
41.11.17
PS Background Color
(PXP_HW_PXP_PS_BACKGROUND_0)
This register contains a pixel value to be used for any PS pixels that fall outside the PS
extents. This is effectively a background or letterbox color. The CSC1 control and
datapath pixel format should be considered when selecting the background color.
Address: 21C_C000h base + 100h offset = 21C_C100h
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
COLOR
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
PXP_HW_PXP_PS_BACKGROUND_0 field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
COLOR
Background color (in 24bpp format) for any pixels not within the buffer range specified by the PS ULC/
LRC.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2587

<!-- page 2588 -->

41.11.18
PS Scale Factor Register (PXP_HW_PXP_PS_SCALE)
The maximum down scaling factor is 1/2 such that the output image in either axis is 1/2
the size of the source. The maximum up scaling factor is 2^12 for either axis. The
reciprocal of the scale factor should be loaded into this register. To reduce the PS buffer
by a factor of two in the output frame buffer, a value of 10.0000_0000_0000 should be
loaded into this register. To scale up by a factor of 4, the value of 1/4, or
00.0100_0000_0000, should be loaded into this register. To scale up by 8/5, the value of
00.1010_0000_0000 should be loaded.
Address: 21C_C000h base + 110h offset = 21C_C110h
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
YSCALE
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
XSCALE
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
0
0
0
0
0
0
PXP_HW_PXP_PS_SCALE field descriptions
Field
Description
31
Reserved
This read-only field is reserved and always has the value 0.
30–16
YSCALE
This is a two bit integer and 12 bit fractional representation (##.####_####_####) of the Y scaling factor
for the PS source buffer. The maximum value programmed should be 2 since scaling down by a factor
greater than 2 is not supported with the bilinear filter. Decimation and the bilinear filter should be used
together to achieve scaling by more than a factor of 2.
15
Reserved
This read-only field is reserved and always has the value 0.
XSCALE
This is a two bit integer and 12 bit fractional representation (##.####_####_####) of the X scaling factor
for the PS source buffer. The maximum value programmed should be 2 since scaling down by a factor
greater than 2 is not supported with the bilinear filter. Decimation and the bilinear filter should be used
together to achieve scaling by more than a factor of 2.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2588
NXP Semiconductors

<!-- page 2589 -->

41.11.19
PS Scale Offset Register (PXP_HW_PXP_PS_OFFSET)
The X and Y offset provides the ability to access the source image with a per sub-pixel
granularity. This provides the capability to use all source pixels to effect the output PS
image. The fixed offset values can be used for sub-pixel adjustments in the bilinear
scaling filter. For example, when scaling an image down by a factor of 2, an initial offset
of 0x0 would result in sub-sampling every other pixel. If a fixed offset of 0x800 (1/2), all
pixels are used in scaling the final output pixel value. In this case, the first output pixel
would be the sum of (1/2*P0) + (1/2*P1). This fixed offset is applied after the decimation
filter stage, and before the bilinear filter stage.
Address: 21C_C000h base + 120h offset = 21C_C120h
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
YOFFSET
0
XOFFSET
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
PXP_HW_PXP_PS_OFFSET field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27–16
YOFFSET
This is a 12 bit fractional representation (0.####_####_####) of the Y scaling offset. This represents a
fixed pixel offset which gets added to the scaled address to determine source data for the scaling engine.
15–12
Reserved
This read-only field is reserved and always has the value 0.
XOFFSET
This is a 12 bit fractional representation (0.####_####_####) of the X scaling offset. This represents a
fixed pixel offset which gets added to the scaled address to determine source data for the scaling engine.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2589

<!-- page 2590 -->

41.11.20
PS Color Key Low (PXP_HW_PXP_PS_CLRKEYLOW_0)
When processing an image, if the PXP finds a pixel in the PS buffer with a color that falls
in the range between REG_PS_CLRKEYLOW and REG_PS_CLRKEYHIGH, it will
insert the pixel from the AS channel. If the current AS pixel is letterboxed or if the AS
also matches its colorkey range, the REG_PS_BACKGROUND color is passed down the
pixel pipeline.
Address: 21C_C000h base + 130h offset = 21C_C130h
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
PXP_HW_PXP_PS_CLRKEYLOW_0 field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
PIXEL
Low range of color key applied to PS buffer. To disable PS colorkeying, set the low colorkey to 0xFFFFFF
and the high colorkey to 0x000000.
41.11.21
PS Color Key High
(PXP_HW_PXP_PS_CLRKEYHIGH_0)
When processing an image, if the PXP finds a pixel in the PS buffer with a color that falls
in the range between REG_PS_CLRKEYLOW and REG_PS_CLRKEYHIGH, it will
insert the pixel from the AS channel. If the current AS pixel is letterboxed or if the AS
also matches its colorkey range, the REG_PS_BACKGROUND color is passed down the
pixel pipeline.
Address: 21C_C000h base + 140h offset = 21C_C140h
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2590
NXP Semiconductors

<!-- page 2591 -->

PXP_HW_PXP_PS_CLRKEYHIGH_0 field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
PIXEL
High range of color key applied to PS buffer. To disable PS colorkeying, set the low colorkey to 0xFFFFFF
and the high colorkey to 0x000000.
41.11.22
Alpha Surface Control (PXP_HW_PXP_AS_CTRL)
Control register to determine AS buffer processing.
Address: 21C_C000h base + 150h offset = 21C_C150h
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
ALPHA1_
INVERT
ALPHA0_
INVERT
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
ENABLE_
COLORKEY
ALPHA_
CTRL
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
PXP_HW_PXP_AS_CTRL field descriptions
Field
Description
31–22
Reserved
This read-only field is reserved and always has the value 0.
21
ALPHA1_
INVERT
Setting this bit to logic 0 will not alter the alpha1 value. A logic 1 will invert the alpha1 value and apply (1-
alpha) for image composition.
20
ALPHA0_
INVERT
Setting this bit to logic 0 will not alter the alpha0 value. A logic 1 will invert the alpha0 value and apply (1-
alpha) for image composition.
19–16
ROP
Indicates a raster operation to perform when enabled. Raster operations are enabled through the
ALPHA_CTRL field.
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2591

<!-- page 2592 -->

PXP_HW_PXP_AS_CTRL field descriptions (continued)
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
3
ENABLE_
COLORKEY
Indicates that colorkey functionality is enabled for this alpha surface. Pixels found in the alpha surface
colorkey range will be displayed as transparent (the PS pixel will be used).
2–1
ALPHA_CTRL
Determines how the alpha value is constructed for this alpha surface. Indicates that the value in the
ALPHA field should be used instead of the alpha values present in the input pixels.
0
Reserved
This read-only field is reserved and always has the value 0.
41.11.23
Alpha Surface Buffer Pointer (PXP_HW_PXP_AS_BUF)
This register is used to indicate the base address of the AS buffer.
Address: 21C_C000h base + 160h offset = 21C_C160h
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
PXP_HW_PXP_AS_BUF field descriptions
Field
Description
ADDR
Address pointer for the alpha surface 0 buffer.
41.11.24
Alpha Surface Pitch (PXP_HW_PXP_AS_PITCH)
Any byte value will indicate the vertical pitch. This value will be used in AS pixel
address calculations. This value has no relation to the UL and LR registers. It specifies
how many bytes are between two vertically adjacent pixels in the input AS surface.
Address: 21C_C000h base + 170h offset = 21C_C170h
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
PITCH
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2592
NXP Semiconductors

<!-- page 2593 -->

PXP_HW_PXP_AS_PITCH field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
PITCH
Indicates the number of bytes in memory between two vertically adjacent pixels.
41.11.25
Overlay Color Key Low
(PXP_HW_PXP_AS_CLRKEYLOW_0)
When processing an image, the if the PXP finds a pixel in the current overlay image with
a color that falls in the range from the ASCOLORKEYLOW to ASCOLORKEYHIGH
range, it will use the PS pixel value for that location. If no PS image is present or if the
PS image also matches its colorkey range, the PS background color is used. Colorkey
operations are higher priority than alpha or ROP operations.
Address: 21C_C000h base + 180h offset = 21C_C180h
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
PXP_HW_PXP_AS_CLRKEYLOW_0 field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
PIXEL
Low range of RGB color key applied to AS buffer. Each overlay has an independent colorkey enable.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2593

<!-- page 2594 -->

41.11.26
Overlay Color Key High
(PXP_HW_PXP_AS_CLRKEYHIGH_0)
When processing an image, the if the PXP finds a pixel in the current overlay image with
a color that falls in the range from the ASCOLORKEYLOW to ASCOLORKEYHIGH
range, it will use the PS pixel value for that location. If no PS image is present or if the
PS image also matches its colorkey range, the PS background color is used. Colorkey
operations are higher priority than alpha or ROP operations.
Address: 21C_C000h base + 190h offset = 21C_C190h
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
PXP_HW_PXP_AS_CLRKEYHIGH_0 field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
PIXEL
High range of RGB color key applied to AS buffer. Each overlay has an independent colorkey enable.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2594
NXP Semiconductors

<!-- page 2595 -->

41.11.27
Color Space Conversion Coefficient Register 0
(PXP_HW_PXP_CSC1_COEF0)
The Coefficient 0 register contains coefficients used in the color space conversion
algorithm. The Y and UV offsets are added to the source buffer to normalize them before
the conversion. C0 is the coefficient that is used to multiply the luma component of the
data for all three RGB components.
Address: 21C_C000h base + 1A0h offset = 21C_C1A0h
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
YCBCR_
MODE
BYPASS
0
C0
UV_OFFSET
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
UV_OFFSET
Y_OFFSET
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
PXP_HW_PXP_CSC1_COEF0 field descriptions
Field
Description
31
YCBCR_MODE
Set to 1 when performing YCbCr conversion to RGB. Set to 0 when converting YUV to RGB data. This bit
changes the behavior of the scaler when performing U/V scaling.
30
BYPASS
Bypass the CSC unit in the scaling engine. When set to logic 1, bypass is enabled and the output pixels
will be in the YUV/YCbCr color space. When set to logic 0, the CSC unit is enabled and the pixels will be
converted based on the programmed coefficients.
29
Reserved
This read-only field is reserved and always has the value 0.
28–18
C0
Two's compliment Y multiplier coefficient. YUV=0x100 (1.000) YCbCr=0x12A (1.164)
17–9
UV_OFFSET
Two's compliment phase offset implicit for CbCr data. Generally used for YCbCr to RGB conversion.
YCbCr=0x180, YUV=0x000 (typically -128 or 0x180 to indicate normalized -0.5 to 0.5 range)
Y_OFFSET
Two's compliment amplitude offset implicit in the Y data. For YUV, this is typically 0 and for YCbCr, this is
typically -16 (0x1F0)
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2595

<!-- page 2596 -->

41.11.28
Color Space Conversion Coefficient Register 1
(PXP_HW_PXP_CSC1_COEF1)
The Coefficient 1 register contains coefficients used in the color space conversion
algorithm. C1 is the coefficient that is used to multiply the chroma (Cr/V) component of
the data for the red component. C4 is the coefficient that is used to multiply the chroma
(Cb/U) component of the data for the blue component. Both values should be coded as a
two's compliment fixed point number with 8 bits right of the decimal.
Address: 21C_C000h base + 1B0h offset = 21C_C1B0h
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
C1
0
C4
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
1
0
0
0
1
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
1
0
0
0
PXP_HW_PXP_CSC1_COEF1 field descriptions
Field
Description
31–27
Reserved
This read-only field is reserved and always has the value 0.
26–16
C1
Two's compliment Red V/Cr multiplier coefficient. YUV=0x123 (1.140) YCbCr=0x198 (1.596)
15–11
Reserved
This read-only field is reserved and always has the value 0.
C4
Two's compliment Blue U/Cb multiplier coefficient. YUV=0x208 (2.032) YCbCr=0x204 (2.017)
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2596
NXP Semiconductors

<!-- page 2597 -->

41.11.29
Color Space Conversion Coefficient Register 2
(PXP_HW_PXP_CSC1_COEF2)
The Coefficient 2 register contains coefficients used in the color space conversion
algorithm. C2 is the coefficient that is used to multiply the chroma (Cr/V) component of
the data for the green component. C3 is the coefficient that is used to multiply the chroma
(Cb/U) component of the data for the green component. Both values should be coded as a
two's compliment fixed point number with 8 bits right of the decimal.
Address: 21C_C000h base + 1C0h offset = 21C_C1C0h
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
C2
0
C3
W
Reset 0
0
0
0
0
1
1
1
1
0
0
1
1
0
1
1
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
1
0
1
1
0
0
PXP_HW_PXP_CSC1_COEF2 field descriptions
Field
Description
31–27
Reserved
This read-only field is reserved and always has the value 0.
26–16
C2
Two's compliment Green V/Cr multiplier coefficient. YUV=0x76B (-0.581) YCbCr=0x730 (-0.813)
15–11
Reserved
This read-only field is reserved and always has the value 0.
C3
Two's compliment Green U/Cb multiplier coefficient. YUV=0x79C (-0.394) YCbCr=0x79C (-0.392)
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2597

<!-- page 2598 -->

41.11.30
Color Space Conversion Control Register.
(PXP_HW_PXP_CSC2_CTRL)
The CSC control register will configure the CSC module to perform color space
conversion between the RGB/YUV/YCbCr color spaces.
Address: 21C_C000h base + 1D0h offset = 21C_C1D0h
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
CSC_MODE
BYPASS
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
PXP_HW_PXP_CSC2_CTRL field descriptions
Field
Description
31–3
Reserved
This read-only field is reserved and always has the value 0.
2–1
CSC_MODE
This field controls how the CSC unit operates on pixels when the CSC is not bypassed.
0
BYPASS
This bit controls whether the pixels entering the CSC2 unit get converted or not. When BYPASS is set, no
operations occur on the pixels. When BYPASS is cleared, the selected CSC operation takes place.
41.11.31
Color Space Conversion Coefficient Register 0
(PXP_HW_PXP_CSC2_COEF0)
Address: 21C_C000h base + 1E0h offset = 21C_C1E0h
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
A2
0
A1
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2598
NXP Semiconductors

<!-- page 2599 -->

PXP_HW_PXP_CSC2_COEF0 field descriptions
Field
Description
31–27
Reserved
This read-only field is reserved and always has the value 0.
26–16
A2
Two's compliment coefficient offset. This coefficient has a sign bit, 2 bits integer, and 8 bits of fraction as
###.####_####.
15–11
Reserved
This read-only field is reserved and always has the value 0.
A1
Two's compliment coefficient offset. This coefficient has a sign bit, 2 bits integer, and 8 bits of fraction as
###.####_####.
41.11.32
Color Space Conversion Coefficient Register 1
(PXP_HW_PXP_CSC2_COEF1)
Address: 21C_C000h base + 1F0h offset = 21C_C1F0h
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
B1
0
A3
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
PXP_HW_PXP_CSC2_COEF1 field descriptions
Field
Description
31–27
Reserved
This read-only field is reserved and always has the value 0.
26–16
B1
Two's compliment coefficient offset. This coefficient has a sign bit, 2 bits integer, and 8 bits of fraction as
###.####_####.
15–11
Reserved
This read-only field is reserved and always has the value 0.
A3
Two's compliment coefficient offset. This coefficient has a sign bit, 2 bits integer, and 8 bits of fraction as
###.####_####.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2599

<!-- page 2600 -->

41.11.33
Color Space Conversion Coefficient Register 2
(PXP_HW_PXP_CSC2_COEF2)
Address: 21C_C000h base + 200h offset = 21C_C200h
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
B3
0
B2
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
PXP_HW_PXP_CSC2_COEF2 field descriptions
Field
Description
31–27
Reserved
This read-only field is reserved and always has the value 0.
26–16
B3
Two's compliment coefficient offset. This coefficient has a sign bit, 2 bits integer, and 8 bits of fraction as
###.####_####.
15–11
Reserved
This read-only field is reserved and always has the value 0.
B2
Two's compliment coefficient offset. This coefficient has a sign bit, 2 bits integer, and 8 bits of fraction as
###.####_####.
41.11.34
Color Space Conversion Coefficient Register 3
(PXP_HW_PXP_CSC2_COEF3)
Address: 21C_C000h base + 210h offset = 21C_C210h
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
C2
0
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
PXP_HW_PXP_CSC2_COEF3 field descriptions
Field
Description
31–27
Reserved
This read-only field is reserved and always has the value 0.
26–16
C2
Two's compliment coefficient offset. This coefficient has a sign bit, 2 bits integer, and 8 bits of fraction as
###.####_####.
15–11
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2600
NXP Semiconductors

<!-- page 2601 -->

PXP_HW_PXP_CSC2_COEF3 field descriptions (continued)
Field
Description
C1
Two's compliment coefficient offset. This coefficient has a sign bit, 2 bits integer, and 8 bits of fraction as
###.####_####.
41.11.35
Color Space Conversion Coefficient Register 4
(PXP_HW_PXP_CSC2_COEF4)
Address: 21C_C000h base + 220h offset = 21C_C220h
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
D1
0
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
PXP_HW_PXP_CSC2_COEF4 field descriptions
Field
Description
31–25
Reserved
This read-only field is reserved and always has the value 0.
24–16
D1
Two's compliment coefficient integer offset to be added.
15–11
Reserved
This read-only field is reserved and always has the value 0.
C3
Two's compliment coefficient offset. This coefficient has a sign bit, 2 bits integer, and 8 bits of fraction as
###.####_####.
41.11.36
Color Space Conversion Coefficient Register 5
(PXP_HW_PXP_CSC2_COEF5)
Address: 21C_C000h base + 230h offset = 21C_C230h
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
D3
0
D2
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2601

<!-- page 2602 -->

PXP_HW_PXP_CSC2_COEF5 field descriptions
Field
Description
31–25
Reserved
This read-only field is reserved and always has the value 0.
24–16
D3
Two's compliment coefficient integer offset to be added.
15–9
Reserved
This read-only field is reserved and always has the value 0.
D2
Two's compliment D1 coefficient integer offset to be added.
41.11.37
Lookup Table Control Register.
(PXP_HW_PXP_LUT_CTRL)
The Y8 LUT input mode will take the high order data path byte and transform it using the
LUT memory. This is an 8-bit to 8-bit transformation. The two low order bytes bypass
the LUT and are not transformed, but bypassed without modification. This option can be
used for monochrome gamma correction. The Direct Lookup mode will use the high
nibble of each data byte and truncate the low nibble to generate the lookup address, i.e.
R[7:0]G[7:0]B[7:0] -> R[7:4]G[7:4]B[7:4]. 4K pixels (12-bit address) with 2 bytes per
pixel is supported in this mode. Cached Lookup mode will use the high order bits,
R[7:3],G[7:2],B[7:3] or RGB565, to address the cached LUT memory. 64KB LUT tables,
using 16KB of internal LUT memory, can be indirectly transformed to 16-bit output
pixels (as in RGBW4444/RGB565). This is used for 16bpp gamma correction or EPD
color panel support. Cache misses are internally managed by the PXP LUT Cache
controller.
Address: 21C_C000h base + 240h offset = 21C_C240h
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
BYPASS
0
LOOKUP_
MODE
0
OUT_MODE
W
Reset
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
0
SEL_
8KB
LRU_
UPD
INVALID
0
DMA_START
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2602
NXP Semiconductors

<!-- page 2603 -->

PXP_HW_PXP_LUT_CTRL field descriptions
Field
Description
31
BYPASS
Setting this bit will bypass the LUT memory resource completely. No pixel transfermations will occur at this
stage of the PXP pixel rpocessing pipeline.
30–26
Reserved
This read-only field is reserved and always has the value 0.
25–24
LOOKUP_MODE
Configure the input address for the 16KB LUT memory. The address into the LUT uses different parts of
the pixel data path bytes. The data path is defined as three bytes, conceptually as RGB/YUV/YCbCr[23:0].
Also referred to as R/Y[7:0],G/U[7:0],B/V[7:0]
23–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OUT_MODE
Select the output mode of operation for the LUT resource. There are four bytes [3-0] in the data path at the
output of the LUT resource. Byte lane 3 is always bypassed and usually contains an alpha value. The LUT
can be programmed to transform bytes 2,1,0 according to the options available in this field.
15–11
Reserved
This read-only field is reserved and always has the value 0.
10
SEL_8KB
Selects which 8KB bank of memory to use for direct 12bpp lookup modes. Logic 0 indicates first 8KB,
logic 1 indicates second 8KB. Two direct LUT arrays can be stored and one can be selected for a given
PXP operation.
9
LRU_UPD
Least Recently Used Policy Update Control: 1=> block LRU update for hit after miss. 0=> update LRU for
all hits including hit after miss.
8
INVALID
Invalidate the cache LRU and valid bits. This bit will automatically reset when set to a logic 1.
7–1
Reserved
This read-only field is reserved and always has the value 0.
0
DMA_START
Setting this bit will result in the DMA operation to load the PXP LUT memory based on
REG_LUT_ADDR_NUM_BYTES, REG_LUT_ADDR_ADDR, and REG_LUT_MEM_ADDR. This bit will
automatically reset when set to a logic 1. Note: The LOOKUP_MODE must not be set to CACHE_RGB565
when starting and performing DMA transfers.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2603

<!-- page 2604 -->

41.11.38
Lookup Table Control Register.
(PXP_HW_PXP_LUT_ADDR)
The Y8 LUT input mode will take the high order data path byte and transform it using the
LUT memory. This is an 8-bit to 8-bit transformation. The two low order bytes bypass
the LUT and are not transformed, but bypassed without modification. This option can be
used for monochrome gamma correction. The Direct Lookup mode will use the high
nibble of each data byte and truncate the low nibble to generate the lookup address, i.e.
R[7:0]G[7:0]B[7:0] -> R[7:4]G[7:4]B[7:4]. 4K pixels (12-bit address) with 2 bytes per
pixel is supported in this mode. Cached Lookup mode will use the high order bits,
R[7:3],G[7:2],B[7:3] or RGB565, to address the cached LUT memory. 64KB LUT tables,
using 16KB of internal LUT memory, can be indirectly transformed to 16-bit output
pixels (as in RGBW4444/RGB565). This is used for 16bpp gamma correction or EPD
color panel support. Cache misses are internally managed by the PXP LUT Cache
controller.
Address: 21C_C000h base + 250h offset = 21C_C250h
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
NUM_BYTES
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
ADDR
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
PXP_HW_PXP_LUT_ADDR field descriptions
Field
Description
31
Reserved
This read-only field is reserved and always has the value 0.
30–16
NUM_BYTES
Indicates the number of bytes to load via a DMA operation. This field must be divisable by 8 and the least
significant 3 bits must be 0. The value 8 indicates load 8 bytes from the external address indicated by
REG_LUT_MEM_ADDR to the LUT memory location indicated by REG_LUT_CTRL_ADDR.
15–14
Reserved
This read-only field is reserved and always has the value 0.
ADDR
LUT indexed address pointer. This address into the LUT memory is always four byte aligned for PIO
access, and eight byte aligned for DMA access. The least two significant bits are not used to drive the LUT
memory array. For PIO LUT access, when the LUT data register is written, the contents of the LUT at the
address specified by this address field will be loaded with a 32-bit DWORD. This address pointer will be
incremented after the LUT data is written. This will provide recursive writes to the LUT data register to
initialize the entire LUT array with recursive writes to the LUT data register. For DMA access, this register
indicates the LUT memory address of the 8 byte QWORD to be loaded. When using the NUM_BYTES
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2604
NXP Semiconductors

<!-- page 2605 -->

PXP_HW_PXP_LUT_ADDR field descriptions (continued)
Field
Description
field to load more than 8 bytes, the register should be programmed with the first LUT memory location to
be filled and each load of the LUT memory will increment this address field until NUM_BYTES has been
loaded.
41.11.39
Lookup Table Data Register.
(PXP_HW_PXP_LUT_DATA)
Address: 21C_C000h base + 260h offset = 21C_C260h
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
PXP_HW_PXP_LUT_DATA field descriptions
Field
Description
DATA
Writing this field will load 4 bytes, aligned to four byte boundaries, of data indexed by the ADDR field of the
REG_LUT_CTRL register.
41.11.40
Lookup Table External Memory Address Register.
(PXP_HW_PXP_LUT_EXTMEM)
For DMA LUT memory loads, this is the base address from which data will be sourced to
store into the LUT memory array. For Cached LUT memory pixel transformations, this
register will store the base address of the full 64K pixel LUT translation table.
Address: 21C_C000h base + 270h offset = 21C_C270h
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
PXP_HW_PXP_LUT_EXTMEM field descriptions
Field
Description
ADDR
This register contains the external memory address used for LUT memory operation.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2605

<!-- page 2606 -->

41.11.41
Color Filter Array Register. (PXP_HW_PXP_CFA)
There are sixteen 2 bit values in this register each mapping a selected component to the
output pixel. The two bit values are defined as 0=>R, 1=>G, 2=>B, and 3=>W. The first
byte represents the repetitive pattern of RGBW pixels in the CFA for the first line
segment of each processed PXP block. The second byte represents the pattern in the
second line segment of the block, and so on. The first byte repeats two times for 8x8
macro block mode, and repeats four times for 16x16 block mode.
Address: 21C_C000h base + 280h offset = 21C_C280h
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
PXP_HW_PXP_CFA field descriptions
Field
Description
DATA
This register contains the Color Filter Array pattern for decimation of RGBW4444 16 bit pixels to individual
R, G, B, W values. The pattern represents a replicated 4x4 color filter array for the entire output frame
buffer.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2606
NXP Semiconductors

<!-- page 2607 -->

41.11.42
PXP Alpha Engine A Control Register.
(PXP_HW_PXP_ALPHA_A_CTRL)
Address: 21C_C000h base + 290h offset = 21C_C290h
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
S1_GLOBAL_ALPHA
S0_GLOBAL_ALPHA
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
S1_COLOR_MODE
S1_ALPHA_MODE
S1_
GLOBAL_
ALPHA_
MODE
S1_S0_
FACTOR_
MODE
0
S0_COLOR_MODE
S0_ALPHA_MODE
S0_
GLOBAL_
ALPHA_
MODE
S0_S1_
FACTOR_
MODE
POTER_DUFF_
ENABLE
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
PXP_HW_PXP_ALPHA_A_CTRL field descriptions
Field
Description
31–24
S1_GLOBAL_
ALPHA
s1 global alpha
23–16
S0_GLOBAL_
ALPHA
s0 global alpha
15–14
Reserved
This read-only field is reserved and always has the value 0.
13
S1_COLOR_
MODE
s1 color mode
12
S1_ALPHA_
MODE
s1 alpha mode
11–10
S1_GLOBAL_
ALPHA_MODE
s1 global alpha mode
9–8
S1_S0_
FACTOR_MODE
s1 to s0 factor mode
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2607

<!-- page 2608 -->

PXP_HW_PXP_ALPHA_A_CTRL field descriptions (continued)
Field
Description
7
Reserved
This read-only field is reserved and always has the value 0.
6
S0_COLOR_
MODE
s0 color mode
5
S0_ALPHA_
MODE
s0 alpha mode
4–3
S0_GLOBAL_
ALPHA_MODE
s0 global alpha mode
2–1
S0_S1_
FACTOR_MODE
s0 to s1 factor mode
0
POTER_DUFF_
ENABLE
poter_duff enable
41.11.43
PS Background Color 1
(PXP_HW_PXP_PS_BACKGROUND_1)
This register contains a pixel value to be used for any PS pixels that fall outside the PS
extents. This is effectively a background or letterbox color. The CSC1 control and
datapath pixel format should be considered when selecting the background color.
Address: 21C_C000h base + 2C0h offset = 21C_C2C0h
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
COLOR
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
PXP_HW_PXP_PS_BACKGROUND_1 field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
COLOR
Background color (in 24bpp format) for any pixels not within the buffer range specified by the PS ULC/
LRC.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2608
NXP Semiconductors

<!-- page 2609 -->

41.11.44
PS Color Key Low 1
(PXP_HW_PXP_PS_CLRKEYLOW_1)
When processing an image, if the PXP finds a pixel in the PS buffer with a color that falls
in the range between REG_PS_CLRKEYLOW and REG_PS_CLRKEYHIGH, it will
insert the pixel from the AS channel. If the current AS pixel is letterboxed or if the AS
also matches its colorkey range, the REG_PS_BACKGROUND color is passed down the
pixel pipeline.
Address: 21C_C000h base + 2D0h offset = 21C_C2D0h
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
PXP_HW_PXP_PS_CLRKEYLOW_1 field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
PIXEL
Low range of color key applied to PS buffer. To disable PS colorkeying, set the low colorkey to 0xFFFFFF
and the high colorkey to 0x000000.
41.11.45
PS Color Key High 1
(PXP_HW_PXP_PS_CLRKEYHIGH_1)
When processing an image, if the PXP finds a pixel in the PS buffer with a color that falls
in the range between REG_PS_CLRKEYLOW and REG_PS_CLRKEYHIGH, it will
insert the pixel from the AS channel. If the current AS pixel is letterboxed or if the AS
also matches its colorkey range, the REG_PS_BACKGROUND color is passed down the
pixel pipeline.
Address: 21C_C000h base + 2E0h offset = 21C_C2E0h
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2609

<!-- page 2610 -->

PXP_HW_PXP_PS_CLRKEYHIGH_1 field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
PIXEL
High range of color key applied to PS buffer. To disable PS colorkeying, set the low colorkey to 0xFFFFFF
and the high colorkey to 0x000000.
41.11.46
Overlay Color Key Low
(PXP_HW_PXP_AS_CLRKEYLOW_1)
When processing an image, the if the PXP finds a pixel in the current overlay image with
a color that falls in the range from the ASCOLORKEYLOW to ASCOLORKEYHIGH
range, it will use the PS pixel value for that location. If no PS image is present or if the
PS image also matches its colorkey range, the PS background color is used. Colorkey
operations are higher priority than alpha or ROP operations.
Address: 21C_C000h base + 2F0h offset = 21C_C2F0h
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
PXP_HW_PXP_AS_CLRKEYLOW_1 field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
PIXEL
Low range of RGB color key applied to AS buffer. Each overlay has an independent colorkey enable.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2610
NXP Semiconductors

<!-- page 2611 -->

41.11.47
Overlay Color Key High
(PXP_HW_PXP_AS_CLRKEYHIGH_1)
When processing an image, the if the PXP finds a pixel in the current overlay image with
a color that falls in the range from the ASCOLORKEYLOW to ASCOLORKEYHIGH
range, it will use the PS pixel value for that location. If no PS image is present or if the
PS image also matches its colorkey range, the PS background color is used. Colorkey
operations are higher priority than alpha or ROP operations.
Address: 21C_C000h base + 300h offset = 21C_C300h
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
PXP_HW_PXP_AS_CLRKEYHIGH_1 field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
PIXEL
High range of RGB color key applied to AS buffer. Each overlay has an independent colorkey enable.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2611

<!-- page 2612 -->

41.11.48
Control Register 2 (PXP_HW_PXP_CTRL2n)
The Control register contains the controls for the secondary data flow in PXP block.
Address: 21C_C000h base + 310h offset + (4d × i), where i=0d to 3d
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
ENABLE_
ROTATE1
ENABLE_
ROTATE0
ENABLE_LUT
ENABLE_CSC2
BLOCK_SIZE
0
ENABLE_WFE_B
0
ENABLE_
DITHER
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
VFLIP1
HFLIP1
ROTATE1
VFLIP0
HFLIP0
ROTATE0
0
ENABLE
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
PXP_HW_PXP_CTRL2n field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27
ENABLE_
ROTATE1
Enable the ROTATE1 engine in the PXP secondary processing flow.
26
ENABLE_
ROTATE0
Enable the ROTATE0 engine in the PXP secondary processing flow.
25
ENABLE_LUT
Enable the LUT engine in the PXP secondary processing flow.
24
ENABLE_CSC2
Enable the CSC2 engine in the PXP secondary processing flow.
23
BLOCK_SIZE
Select the block size to process through the Rotate block.
22–20
Reserved
This read-only field is reserved and always has the value 0.
19
ENABLE_WFE_
B
Enable the WFE-B engine in the PXP secondary processing flow.
18
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2612
NXP Semiconductors

<!-- page 2613 -->

PXP_HW_PXP_CTRL2n field descriptions (continued)
Field
Description
17
ENABLE_
DITHER
Enable the Dithering engine in the PXP secondary processing flow.
16
Reserved
This read-only field is reserved and always has the value 0.
15
VFLIP1
Indicates that the input should be flipped vertically (effect applied before rotation).
14
HFLIP1
Indicates that the input should be flipped horizontally (effect applied before rotation).
13–12
ROTATE1
Indicates the clockwise rotation to be applied at the input buffer. The rotation effect is defined as occurring
after the FLIP_X and FLIP_Y permutation.
11
VFLIP0
Indicates that the output buffer should be flipped vertically (effect applied before rotation).
10
HFLIP0
Indicates that the output buffer should be flipped horizontally (effect applied before rotation).
9–8
ROTATE0
Indicates the clockwise rotation to be applied at the output buffer. The rotation effect is defined as
occurring after the FLIP_X and FLIP_Y permutation.
7–1
Reserved
This read-only field is reserved and always has the value 0.
0
ENABLE
Enables PXP secondary data processing flow with specified parameters. The ENABLE bit will remain set
while the PXP is active and will be cleared once the current operation completes. Software should use the
IRQ bit in the HW_PXP_STAT when polling for PXP completion.
41.11.49
PXP Power Control Register.
(PXP_HW_PXP_POWER_REG0)
Address: 21C_C000h base + 320h offset = 21C_C320h
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
CTRL
ROT0_
MEM_
LP_
STATE
LUT_LP_
STATE_
WAY1_
BANKN
LUT_LP_
STATE_
WAY0_
BANKN
LUT_LP_
STATE_
WAY0_
BANK0
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
PXP_HW_PXP_POWER_REG0 field descriptions
Field
Description
31–12
CTRL
This register contains power control for the PXP.
11–9
ROT0_MEM_LP_
STATE
Select the low power state of the ROT 0 memory.
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2613

<!-- page 2614 -->

PXP_HW_PXP_POWER_REG0 field descriptions (continued)
Field
Description
8–6
LUT_LP_
STATE_WAY1_
BANKN
Select the low power state of the LUT's WAY0-BANK0,1,2,3 memory.
5–3
LUT_LP_
STATE_WAY0_
BANKN
Select the low power state of the LUT's WAY0-BANK1,2,3 memory.
LUT_LP_
STATE_WAY0_
BANK0
Select the low power state of the LUT's WAY0-BANK0 memory.
41.11.50
PXP Power Control Register 1.
(PXP_HW_PXP_POWER_REG1)
Address: 21C_C000h base + 330h offset = 21C_C330h
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
ALU_B_MEM_LP_
STATE
ALU_A_MEM_LP_
STATE
DITH2_LUT_
MEM_LP_
STATE
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
DITH
2_
LUT_
MEM
_LP_
STAT
E
DITH1_LUT_MEM_
LP_STATE
DITH0_ERR1_
MEM_LP_STATE
DITH0_ERR0_
MEM_LP_STATE
DITH0_LUT_MEM_
LP_STATE
ROT1_MEM_LP_
STATE
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
PXP_HW_PXP_POWER_REG1 field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
23–21
ALU_B_MEM_
LP_STATE
Select the low power state of the ALU B memory.
20–18
ALU_A_MEM_
LP_STATE
Select the low power state of the ALU A memory.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2614
NXP Semiconductors

<!-- page 2615 -->

PXP_HW_PXP_POWER_REG1 field descriptions (continued)
Field
Description
17–15
DITH2_LUT_
MEM_LP_STATE
Select the low power state of the dither2 LUT memory.
14–12
DITH1_LUT_
MEM_LP_STATE
Select the low power state of the dither1 LUT memory.
11–9
DITH0_ERR1_
MEM_LP_STATE
Select the low power state of the dither0 ERR1 memory.
8–6
DITH0_ERR0_
MEM_LP_STATE
Select the low power state of the dither0 ERR0 memory.
5–3
DITH0_LUT_
MEM_LP_STATE
Select the low power state of the dither0 LUT memory.
ROT1_MEM_LP_
STATE
Select the low power state of the ROT 1 memory.
41.11.51
This register helps decide the data path gthrough the
PXP. (PXP_HW_PXP_DATA_PATH_CTRL0n)
The Control register contains the control bits for the data path through the PXP.
Address: 21C_C000h base + 340h offset + (4d × i), where i=0d to 3d
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
MUX14_SEL
0
MUX12_SEL
MUX11_SEL
0
MUX9_SEL
MUX8_SEL
W
Reset
0
1
0
1
0
0
0
1
0
0
0
0
0
1
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
0
0
MUX3_SEL
0
MUX1_SEL
MUX0_SEL
W
Reset
0
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
0
0
0
0
0
PXP_HW_PXP_DATA_PATH_CTRL0n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
MUX14_SEL
This field chooses the data path through MUX 14.
27–26
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2615

<!-- page 2616 -->

PXP_HW_PXP_DATA_PATH_CTRL0n field descriptions (continued)
Field
Description
25–24
MUX12_SEL
This field chooses the data path through MUX 13.
23–22
MUX11_SEL
This field chooses the data path through MUX 11.
21–20
Reserved
This read-only field is reserved and always has the value 0.
19–18
MUX9_SEL
This field chooses the data path through MUX 9.
17–16
MUX8_SEL
This field chooses the data path through MUX 8.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–12
Reserved
This read-only field is reserved and always has the value 0.
11–10
Reserved
This read-only field is reserved and always has the value 0.
9–8
Reserved
This read-only field is reserved and always has the value 0.
7–6
MUX3_SEL
This field chooses the data path through MUX 3.
5–4
Reserved
This read-only field is reserved and always has the value 0.
3–2
MUX1_SEL
This field chooses the data path through MUX 1.
MUX0_SEL
This mux chooses the data that will go through the WFEB engine.
41.11.52
This register helps decide the data path gthrough the
PXP. (PXP_HW_PXP_DATA_PATH_CTRL1n)
The Control register contains the control bits for the data path through the PXP.
Address: 21C_C000h base + 350h offset + (4d × i), where i=0d to 3d
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
MUX17_SEL
MUX16_SEL
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2616
NXP Semiconductors

<!-- page 2617 -->

PXP_HW_PXP_DATA_PATH_CTRL1n field descriptions
Field
Description
31–4
Reserved
This read-only field is reserved and always has the value 0.
3–2
MUX17_SEL
This field chooses the data path through MUX 17.
MUX16_SEL
This mux chooses the data path through MUX 16.
41.11.53
Initialize memory buffer control Register
(PXP_HW_PXP_INIT_MEM_CTRLn)
This register controls IRQ the intializing of internal pxp rams.
Address: 21C_C000h base + 360h offset + (4d × i), where i=0d to 3d
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
START
SELECT
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
ADDR
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
PXP_HW_PXP_INIT_MEM_CTRLn field descriptions
Field
Description
31
START
Enable writing to the memory.
30–27
SELECT
Select which memory to write.
26–16
Reserved
This read-only field is reserved and always has the value 0.
ADDR
Base address to start writing. The control logic will increment the address value internally each time the
data register is written.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2617

<!-- page 2618 -->

41.11.54
Write data Register (PXP_HW_PXP_INIT_MEM_DATA)
This register holds the data word to intialize internal pxp rams.
Address: 21C_C000h base + 370h offset = 21C_C370h
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
PXP_HW_PXP_INIT_MEM_DATA field descriptions
Field
Description
DATA
Data value to be written to the memory. A write to this register kicks off a write cycle to the memory
selected.
41.11.55
Write data Register
(PXP_HW_PXP_INIT_MEM_DATA_HIGH)
This register holds the upper data word to intialize internal pxp fetch rams.
Address: 21C_C000h base + 380h offset = 21C_C380h
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
PXP_HW_PXP_INIT_MEM_DATA_HIGH field descriptions
Field
Description
DATA
Data value to be written to the most significant 32 bits of the fetch memories. this register must be written
before the HW_PXP_INIT_MEM_DATA as that register triggers the write cycle to memory.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2618
NXP Semiconductors

<!-- page 2619 -->

41.11.56
PXP IRQ Mask Register (PXP_HW_PXP_IRQ_MASKn)
This register controls IRQ masks for all PXP interrupts
Address: 21C_C000h base + 390h offset + (4d × i), where i=0d to 3d
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
WFE_B_STORE_
IRQ_EN
0
WFE_B_CH1_
STORE_IRQ_EN
WFE_B_CH0_
STORE_IRQ_EN
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
PXP_HW_PXP_IRQ_MASKn field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15
WFE_B_
STORE_IRQ_EN
Enable WFE B store engine interrupt detection.
14–12
Reserved
This read-only field is reserved and always has the value 0.
11
WFE_B_CH1_
STORE_IRQ_EN
Enable WFE B ch1 store engine interrupt detection.
10
WFE_B_CH0_
STORE_IRQ_EN
Enable WFE B ch0 store engine interrupt detection.
Reserved
This read-only field is reserved and always has the value 0.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2619

<!-- page 2620 -->

41.11.57
PXP Interrupt Register (PXP_HW_PXP_IRQn)
This register houses the interrupt bits for the Prefetch and Store Engines
Address: 21C_C000h base + 3A0h offset + (4d × i), where i=0d to 3d
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
WFE_B_STORE_
IRQ
0
WFE_B_CH1_
STORE_IRQ
WFE_B_CH0_
STORE_IRQ
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
PXP_HW_PXP_IRQn field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15
WFE_B_
STORE_IRQ
WFE B store engine Interrupt
14–12
Reserved
This read-only field is reserved and always has the value 0.
11
WFE_B_CH1_
STORE_IRQ
WFE B ch1 store engine Interrupt
10
WFE_B_CH0_
STORE_IRQ
WFE B ch0 store engine Interrupt
Reserved
This read-only field is reserved and always has the value 0.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2620
NXP Semiconductors

<!-- page 2621 -->

41.11.58
PXP NEXT Buffer Enable select Register
(PXP_HW_PXP_NEXT_ENn)
This register controls the PXP Next buffer Enable.
Address: 21C_C000h base + 3B0h offset + (4d × i), where i=0d to 3d
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
WFEB
LEGACY
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
PXP_HW_PXP_NEXT_ENn field descriptions
Field
Description
31–2
Reserved
This read-only field is reserved and always has the value 0.
1
WFEB
Enable WFE B Next Buffer function.The WFEB and the LEGACY bit can't be set to 1 at same time.
0
LEGACY
Enable Legacy Next Buffer function. The WFEB_B and the LEGACY bit can't be set to 1 at same time.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2621

<!-- page 2622 -->

41.11.59
Next Frame Pointer (PXP_HW_PXP_NEXT)
To enable this functionality, software must write this register while the PXP is processing
the current data frame (if the PXP is currently idle, this will also initiate an immediate
load of registers from the pointer). The process of writing this register (WRITE
operation) will set a semaphore in hardware to notify the control logic that a register
reload operation must be performed when the current frame processing is complete. At
the end of a frame, the PXP will fetch the register settings from this location, signal an
interrupt to software, then proceed with rendering the next frame of data. Software may
cancel the reload operation by issuing a CLEAR operation to this register. SET and
TOGGLE operations should not be used when addressing this register. All registers will
be reloaded with the exception of the following: STAT, CSCCOEFn, NEXT, VERSION.
All other registers will be loaded in the order they appear in the register map. Once the
pointer's contents have been loaded into the PXP's registers, the NEXT_IRQ interrupt
will be issued (see the PXP_STATUS register).
Address: 21C_C000h base + 400h offset = 21C_C400h
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
POINTER
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
POINTER
0
ENABLED
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2622
NXP Semiconductors

<!-- page 2623 -->

PXP_HW_PXP_NEXT field descriptions
Field
Description
31–2
POINTER
A pointer to a data structure containing register values to be used when processing the next frame. The
pointer must be 32-bit aligned and should reside in on-chip or off-chip memory.
1
Reserved
This read-only field is reserved and always has the value 0.
0
ENABLED
Indicates that the "next frame" functionality has been enabled. This bit reflects the status of the hardware
semaphore indicating that a reload operation is pending at the end of the current frame.
41.11.60
Debug Control Register (PXP_HW_PXP_DEBUGCTRL)
This register controls the PXP Debug features. This register is not intended for customer
use.
Address: 21C_C000h base + 410h offset = 21C_C410h
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
LUT_CLR_
STAT_CNT
SELECT
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
PXP_HW_PXP_DEBUGCTRL field descriptions
Field
Description
31–12
Reserved
This read-only field is reserved and always has the value 0.
11–8
LUT_CLR_
STAT_CNT
Clear LUT status counters.
SELECT
Index into one of the PXP debug registers. The data for the selected register will be returned
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2623

<!-- page 2624 -->

41.11.61
Debug Register (PXP_HW_PXP_DEBUG)
The debug control register will select the desired debug field to be read through this
register offset. This register is not intended for customer use.
Address: 21C_C000h base + 420h offset = 21C_C420h
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
PXP_HW_PXP_DEBUG field descriptions
Field
Description
DATA
Debug data
41.11.62
Version Register (PXP_HW_PXP_VERSION)
This register indicates the RTL version in use. This register is not intended for customer
use.
Address: 21C_C000h base + 430h offset = 21C_C430h
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
MAJOR
MINOR
STEP
W
Reset 0
0
0
0
0
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
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
PXP_HW_PXP_VERSION field descriptions
Field
Description
31–24
MAJOR
Fixed read-only value reflecting the MAJOR field of the RTL version.
23–16
MINOR
Fixed read-only value reflecting the MINOR field of the RTL version.
STEP
Fixed read-only value reflecting the stepping of the RTL version.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2624
NXP Semiconductors

<!-- page 2625 -->

41.11.63
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_DITHER_STORE_SIZE_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + A00h offset = 21C_CA00h
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
OUT_HEIGHT
OUT_WIDTH
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
PXP_HW_PXP_DITHER_STORE_SIZE_CH0 field descriptions
Field
Description
31–16
OUT_HEIGHT
actual output height -1
OUT_WIDTH
actual output width -1
41.11.64
Fetch engine Control for WFE B Register
(PXP_HW_PXP_WFB_FETCH_CTRLn)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1100h offset + (4d × i), where i=0d to 3d
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
BUF2_DONE_
IRQ_EN
BUF1_DONE_
IRQ_EN
BUF2_DONE_
IRQ
BUF1_DONE_
IRQ
0
BF2_LINE_
MODE
BF2_BYTES_PP
BF1_LINE_
MODE
BF1_BYTES_PP
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
BF2_BORDER_
MODE
BF2_BURST_
LEN
BF2_BYPASS_
MODE
BF2_HSK_
MODE
BF2_SRAM_IF
BF2_EN
0
BF1_BORDER_
MODE
BF1_BURST_
LEN
BF1_BYPASS_
MODE
BF1_HSK_
MODE
BF1_SRAM_IF
BF1_EN
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2625

<!-- page 2626 -->

PXP_HW_PXP_WFB_FETCH_CTRLn field descriptions
Field
Description
31
BUF2_DONE_
IRQ_EN
This bit is set to enable buffer2 fetch done interrupt.
30
BUF1_DONE_
IRQ_EN
This bit is set to enable buffer1 fetch done interrupt.
29
BUF2_DONE_
IRQ
This bit is set to indicate that buffer2 fetch done interrupt, this bit is cleared by writing a one to its SCT
clear address
28
BUF1_DONE_
IRQ
This bit is set to indicate that buffer1 fetch done interrupt, this bit is cleared by writing a one to its SCT
clear address
27–24
Reserved
This read-only field is reserved and always has the value 0.
23–22
BF2_LINE_
MODE
Indiacates the number of lines to be fetched
21–20
BF2_BYTES_PP
This indicate how many bytes in each pixel for the buffer
19–18
BF1_LINE_
MODE
Indiacates the number of lines to be fetched
17–16
BF1_BYTES_PP
This indicate how many bytes in each pixel for the buffer
15–14
Reserved
This read-only field is reserved and always has the value 0.
13
BF2_BORDER_
MODE
Indicate buffer2 border pixels select
12
BF2_BURST_
LEN
Indicate buffer2 AXI burst length
11
BF2_BYPASS_
MODE
Indicate buffer2 use bypass pixels or not
10
BF2_HSK_
MODE
Mode of operation
9
BF2_SRAM_IF
Fetch Source
8
BF2_EN
BF2 enable bit.
7–6
Reserved
This read-only field is reserved and always has the value 0.
5
BF1_BORDER_
MODE
Indicate buffer1 border pixels select
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2626
NXP Semiconductors

<!-- page 2627 -->

PXP_HW_PXP_WFB_FETCH_CTRLn field descriptions (continued)
Field
Description
4
BF1_BURST_
LEN
Indicate buffer1 AXI burst length
3
BF1_BYPASS_
MODE
Indicate buffer1 use bypass pixels or not
2
BF1_HSK_
MODE
Mode of operation
1
BF1_SRAM_IF
Fetch Source
0
BF1_EN
BF1 enable bit.
41.11.65
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_FETCH_BUF1_ADDR)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1110h offset = 21C_D110h
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
BUF_ADDR
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
PXP_HW_PXP_WFB_FETCH_BUF1_ADDR field descriptions
Field
Description
BUF_ADDR
This indicate the base address for wfb buffer1 fetch
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2627

<!-- page 2628 -->

41.11.66
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_FETCH_BUF1_PITCH)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1120h offset = 21C_D120h
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
PITCH
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
PXP_HW_PXP_WFB_FETCH_BUF1_PITCH field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
PITCH
This indicate the number of bytes in memory between two vertically adjacent pixels.
41.11.67
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_FETCH_BUF1_SIZE)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1130h offset = 21C_D130h
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
BUF_HEIGHT
BUF_WIDTH
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
PXP_HW_PXP_WFB_FETCH_BUF1_SIZE field descriptions
Field
Description
31–16
BUF_HEIGHT
This indicate the buffer height in pixels.
BUF_WIDTH
This indicate the buffer width in pixels.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2628
NXP Semiconductors

<!-- page 2629 -->

41.11.68
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_FETCH_BUF2_ADDR)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1140h offset = 21C_D140h
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
BUF_ADDR
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
PXP_HW_PXP_WFB_FETCH_BUF2_ADDR field descriptions
Field
Description
BUF_ADDR
This indicate the base address for wfb buffer2 fetch
41.11.69
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_FETCH_BUF2_PITCH)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1150h offset = 21C_D150h
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
PITCH
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
PXP_HW_PXP_WFB_FETCH_BUF2_PITCH field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
PITCH
This indicate the number of bytes in memory between two vertically adjacent pixels.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2629

<!-- page 2630 -->

41.11.70
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_FETCH_BUF2_SIZE)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1160h offset = 21C_D160h
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
BUF_HEIGHT
BUF_WIDTH
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
PXP_HW_PXP_WFB_FETCH_BUF2_SIZE field descriptions
Field
Description
31–16
BUF_HEIGHT
This indicates the buffer height in pixels.
BUF_WIDTH
This indicates the buffer width in pixels.
41.11.71
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_PIXEL0_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1170h offset = 21C_D170h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2630
NXP Semiconductors

<!-- page 2631 -->

PXP_HW_PXP_WFB_ARRAY_PIXEL0_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2631

<!-- page 2632 -->

41.11.72
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_PIXEL1_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1180h offset = 21C_D180h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_PIXEL1_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2632
NXP Semiconductors

<!-- page 2633 -->

PXP_HW_PXP_WFB_ARRAY_PIXEL1_MASK field descriptions (continued)
Field
Description
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.73
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_PIXEL2_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1190h offset = 21C_D190h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_PIXEL2_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2633

<!-- page 2634 -->

PXP_HW_PXP_WFB_ARRAY_PIXEL2_MASK field descriptions (continued)
Field
Description
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.74
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_PIXEL3_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 11A0h offset = 21C_D1A0h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2634
NXP Semiconductors

<!-- page 2635 -->

PXP_HW_PXP_WFB_ARRAY_PIXEL3_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2635

<!-- page 2636 -->

41.11.75
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_PIXEL4_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 11B0h offset = 21C_D1B0h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_PIXEL4_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2636
NXP Semiconductors

<!-- page 2637 -->

PXP_HW_PXP_WFB_ARRAY_PIXEL4_MASK field descriptions (continued)
Field
Description
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.76
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_PIXEL5_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 11C0h offset = 21C_D1C0h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_PIXEL5_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2637

<!-- page 2638 -->

PXP_HW_PXP_WFB_ARRAY_PIXEL5_MASK field descriptions (continued)
Field
Description
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.77
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_PIXEL6_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 11D0h offset = 21C_D1D0h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2638
NXP Semiconductors

<!-- page 2639 -->

PXP_HW_PXP_WFB_ARRAY_PIXEL6_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2639

<!-- page 2640 -->

41.11.78
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_PIXEL7_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 11E0h offset = 21C_D1E0h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_PIXEL7_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2640
NXP Semiconductors

<!-- page 2641 -->

PXP_HW_PXP_WFB_ARRAY_PIXEL7_MASK field descriptions (continued)
Field
Description
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.79
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG0_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 11F0h offset = 21C_D1F0h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_FLAG0_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2641

<!-- page 2642 -->

PXP_HW_PXP_WFB_ARRAY_FLAG0_MASK field descriptions (continued)
Field
Description
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.80
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG1_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1200h offset = 21C_D200h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2642
NXP Semiconductors

<!-- page 2643 -->

PXP_HW_PXP_WFB_ARRAY_FLAG1_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2643

<!-- page 2644 -->

41.11.81
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG2_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1210h offset = 21C_D210h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_FLAG2_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2644
NXP Semiconductors

<!-- page 2645 -->

PXP_HW_PXP_WFB_ARRAY_FLAG2_MASK field descriptions (continued)
Field
Description
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.82
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG3_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1220h offset = 21C_D220h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_FLAG3_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2645

<!-- page 2646 -->

PXP_HW_PXP_WFB_ARRAY_FLAG3_MASK field descriptions (continued)
Field
Description
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.83
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG4_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1230h offset = 21C_D230h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2646
NXP Semiconductors

<!-- page 2647 -->

PXP_HW_PXP_WFB_ARRAY_FLAG4_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2647

<!-- page 2648 -->

41.11.84
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG5_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1240h offset = 21C_D240h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_FLAG5_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2648
NXP Semiconductors

<!-- page 2649 -->

PXP_HW_PXP_WFB_ARRAY_FLAG5_MASK field descriptions (continued)
Field
Description
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.85
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG6_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1250h offset = 21C_D250h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_FLAG6_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2649

<!-- page 2650 -->

PXP_HW_PXP_WFB_ARRAY_FLAG6_MASK field descriptions (continued)
Field
Description
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.86
This register defines the control bits for the pxp wfb
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG7_MASK)
This register defines the control bits for the pxp wfb fetch sub-block.
Address: 21C_C000h base + 1260h offset = 21C_D260h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2650
NXP Semiconductors

<!-- page 2651 -->

PXP_HW_PXP_WFB_ARRAY_FLAG7_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.87
This register defines the control bits for the pxp wfa
fetch sub-block.
(PXP_HW_PXP_WFB_FETCH_BUF1_CORD)
This register defines the control bits for the pxp wfa fetch sub-block.
Address: 21C_C000h base + 1270h offset = 21C_D270h
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
YCORD
0
XCORD
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2651

<!-- page 2652 -->

PXP_HW_PXP_WFB_FETCH_BUF1_CORD field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–16
YCORD
This indicate Y co-ordinate in pixels.
15–14
Reserved
This read-only field is reserved and always has the value 0.
XCORD
This indicate X co-ordinate in pixels.
41.11.88
This register defines the control bits for the pxp wfa
fetch sub-block.
(PXP_HW_PXP_WFB_FETCH_BUF2_CORD)
This register defines the control bits for the pxp wfa fetch sub-block.
Address: 21C_C000h base + 1280h offset = 21C_D280h
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
YCORD
0
XCORD
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
PXP_HW_PXP_WFB_FETCH_BUF2_CORD field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–16
YCORD
This indicate Y co-ordinate in pixels.
15–14
Reserved
This read-only field is reserved and always has the value 0.
XCORD
This indicate X co-ordinate in pixels.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2652
NXP Semiconductors

<!-- page 2653 -->

41.11.89
This register defines the control bits for the pxp wfa
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG8_MASK)
This register defines the control bits for the pxp wfa fetch sub-block.
Address: 21C_C000h base + 1290h offset = 21C_D290h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_FLAG8_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2653

<!-- page 2654 -->

PXP_HW_PXP_WFB_ARRAY_FLAG8_MASK field descriptions (continued)
Field
Description
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.90
This register defines the control bits for the pxp wfa
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG9_MASK)
This register defines the control bits for the pxp wfa fetch sub-block.
Address: 21C_C000h base + 12A0h offset = 21C_D2A0h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_FLAG9_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2654
NXP Semiconductors

<!-- page 2655 -->

PXP_HW_PXP_WFB_ARRAY_FLAG9_MASK field descriptions (continued)
Field
Description
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.91
This register defines the control bits for the pxp wfa
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG10_MASK)
This register defines the control bits for the pxp wfa fetch sub-block.
Address: 21C_C000h base + 12B0h offset = 21C_D2B0h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2655

<!-- page 2656 -->

PXP_HW_PXP_WFB_ARRAY_FLAG10_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2656
NXP Semiconductors

<!-- page 2657 -->

41.11.92
This register defines the control bits for the pxp wfa
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG11_MASK)
This register defines the control bits for the pxp wfa fetch sub-block.
Address: 21C_C000h base + 12C0h offset = 21C_D2C0h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_FLAG11_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2657

<!-- page 2658 -->

PXP_HW_PXP_WFB_ARRAY_FLAG11_MASK field descriptions (continued)
Field
Description
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.93
This register defines the control bits for the pxp wfa
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG12_MASK)
This register defines the control bits for the pxp wfa fetch sub-block.
Address: 21C_C000h base + 12D0h offset = 21C_D2D0h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_FLAG12_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2658
NXP Semiconductors

<!-- page 2659 -->

PXP_HW_PXP_WFB_ARRAY_FLAG12_MASK field descriptions (continued)
Field
Description
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.94
This register defines the control bits for the pxp wfa
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG13_MASK)
This register defines the control bits for the pxp wfa fetch sub-block.
Address: 21C_C000h base + 12E0h offset = 21C_D2E0h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2659

<!-- page 2660 -->

PXP_HW_PXP_WFB_ARRAY_FLAG13_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2660
NXP Semiconductors

<!-- page 2661 -->

41.11.95
This register defines the control bits for the pxp wfa
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG14_MASK)
This register defines the control bits for the pxp wfa fetch sub-block.
Address: 21C_C000h base + 12F0h offset = 21C_D2F0h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_FLAG14_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2661

<!-- page 2662 -->

PXP_HW_PXP_WFB_ARRAY_FLAG14_MASK field descriptions (continued)
Field
Description
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.96
This register defines the control bits for the pxp wfa
fetch sub-block.
(PXP_HW_PXP_WFB_ARRAY_FLAG15_MASK)
This register defines the control bits for the pxp wfa fetch sub-block.
Address: 21C_C000h base + 1300h offset = 21C_D300h
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
BUF_SEL
0
SIGN_Y
SIGN_X
0
OFFSET_Y
0
OFFSET_X
W
Reset
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
H_OFS
0
L_OFS
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
PXP_HW_PXP_WFB_ARRAY_FLAG15_MASK field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–28
BUF_SEL
Select between Buffer 1 and 2
27–26
Reserved
This read-only field is reserved and always has the value 0.
25
SIGN_Y
Offset sign
24
SIGN_X
Offset sign
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2662
NXP Semiconductors

<!-- page 2663 -->

PXP_HW_PXP_WFB_ARRAY_FLAG15_MASK field descriptions (continued)
Field
Description
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–20
OFFSET_Y
This indicates the Y offset position for the pixel.
19–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
OFFSET_X
This indicates the X offset position for the pixel.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
H_OFS
This indicates the right bit position on the original pixel
7–5
Reserved
This read-only field is reserved and always has the value 0.
L_OFS
This indicates the left bit position on the original pixel
41.11.97
This register defines software define pixels for wfb
fetch sub-block. (PXP_HW_PXP_WFB_ARRAY_REG0)
This register defines software define pixels for wfb fetch sub-block.
Address: 21C_C000h base + 1310h offset = 21C_D310h
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
SW_PIXLE3
SW_PIXLE2
SW_PIXLE1
SW_PIXLE0
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
PXP_HW_PXP_WFB_ARRAY_REG0 field descriptions
Field
Description
31–24
SW_PIXLE3
Software define pixel3
23–16
SW_PIXLE2
Software define pixel2
15–8
SW_PIXLE1
Software define pixel1
SW_PIXLE0
Software define pixel0
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2663

<!-- page 2664 -->

41.11.98
This register defines software define pixels for wfb
fetch sub-block. (PXP_HW_PXP_WFB_ARRAY_REG1)
This register defines software define pixels for wfb fetch sub-block.
Address: 21C_C000h base + 1320h offset = 21C_D320h
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
SW_PIXLE7
SW_PIXLE6
SW_PIXLE5
SW_PIXLE4
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
PXP_HW_PXP_WFB_ARRAY_REG1 field descriptions
Field
Description
31–24
SW_PIXLE7
Software define pixel7
23–16
SW_PIXLE6
Software define pixel6
15–8
SW_PIXLE5
Software define pixel5
SW_PIXLE4
Software define pixel4
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2664
NXP Semiconductors

<!-- page 2665 -->

41.11.99
This register defines software define pixels for wfb
fetch sub-block. (PXP_HW_PXP_WFB_ARRAY_REG2)
This register defines software define flags for wfb fetch sub-block.
Address: 21C_C000h base + 1330h offset = 21C_D330h
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
SW_FLAG15
SW_FLAG14
SW_FLAG13
SW_FLAG12
SW_FLAG11
SW_FLAG10
SW_FLAG9
SW_FLAG8
SW_FLAG7
SW_FLAG6
SW_FLAG5
SW_FLAG4
SW_FLAG3
SW_FLAG2
SW_FLAG1
SW_FLAG0
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
PXP_HW_PXP_WFB_ARRAY_REG2 field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15
SW_FLAG15
Software define flag15
14
SW_FLAG14
Software define flag14
13
SW_FLAG13
Software define flag13
12
SW_FLAG12
Software define flag12
11
SW_FLAG11
Software define flag11
10
SW_FLAG10
Software define flag10
9
SW_FLAG9
Software define flag9
8
SW_FLAG8
Software define flag8
7
SW_FLAG7
Software define flag7
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2665

<!-- page 2666 -->

PXP_HW_PXP_WFB_ARRAY_REG2 field descriptions (continued)
Field
Description
6
SW_FLAG6
Software define flag6
5
SW_FLAG5
Software define flag5
4
SW_FLAG4
Software define flag4
3
SW_FLAG3
Software define flag3
2
SW_FLAG2
Software define flag2
1
SW_FLAG1
Software define flag1
0
SW_FLAG0
Software define flag0
41.11.100
Store engine Control Channel 0 Register
(PXP_HW_PXP_WFE_B_STORE_CTRL_CH0n)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1340h offset + (4d × i), where i=0d to 3d
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
ARBIT_EN
0
COMBINE_
2CHANNEL
0
WR_NUM_
BYTES
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
0
FILL_DATA_EN
PACK_IN_SEL
STORE_
MEMORY_EN
STORE_BYPASS_
EN
0
ARRAY_
LINE_NUM
ARRAY_EN
HANDSHAKE_EN
BLOCK_16
BLOCK_EN
CH_EN
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
0
0
0
0
0
0
0
0
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2666
NXP Semiconductors

<!-- page 2667 -->

PXP_HW_PXP_WFE_B_STORE_CTRL_CH0n field descriptions
Field
Description
31
ARBIT_EN
Arbitration Enable
30–25
Reserved
This read-only field is reserved and always has the value 0.
24
COMBINE_
2CHANNEL
Combine 2 channel Enable
23–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
WR_NUM_
BYTES
Bytes in a write burst
15–12
Reserved
This read-only field is reserved and always has the value 0.
11
FILL_DATA_EN
enable bit for fill data
10
PACK_IN_SEL
pack_in_sel
9
STORE_
MEMORY_EN
store memory enable
8
STORE_
BYPASS_EN
enable bit for store bypass
7
Reserved
This read-only field is reserved and always has the value 0.
6–5
ARRAY_LINE_
NUM
Selects Array Size
4
ARRAY_EN
Array Enable
3
HANDSHAKE_
EN
Enable bit for handshake with the store engine.
2
BLOCK_16
Determines the block sixe.
1
BLOCK_EN
Choses the store mode.
0
CH_EN
Channel enable.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2667

<!-- page 2668 -->

41.11.101
Store engine Control Channel 1 Register
(PXP_HW_PXP_WFE_B_STORE_CTRL_CH1n)
The Control register contains the control bits for the pxp prefetch_engine sub-block.
Address: 21C_C000h base + 1350h offset + (4d × i), where i=0d to 3d
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
WR_NUM_
BYTES
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
0
PACK_IN_SEL
STORE_
MEMORY_EN
STORE_
BYPASS_EN
0
ARRAY_
LINE_NUM
ARRAY_EN
HANDSHAKE_
EN
BLOCK_16
BLOCK_EN
CH_EN
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
0
0
0
0
0
0
0
0
PXP_HW_PXP_WFE_B_STORE_CTRL_CH1n field descriptions
Field
Description
31–18
Reserved
This read-only field is reserved and always has the value 0.
17–16
WR_NUM_
BYTES
Bytes in a write burst
15–11
Reserved
This read-only field is reserved and always has the value 0.
10
PACK_IN_SEL
pack_in_sel
9
STORE_
MEMORY_EN
store memory enable
8
STORE_
BYPASS_EN
enable bit for store bypass
7
Reserved
This read-only field is reserved and always has the value 0.
6–5
ARRAY_LINE_
NUM
Selects Array Size
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2668
NXP Semiconductors

<!-- page 2669 -->

PXP_HW_PXP_WFE_B_STORE_CTRL_CH1n field descriptions (continued)
Field
Description
4
ARRAY_EN
Array Enable
3
HANDSHAKE_
EN
Enable bit for handshake with the fetch engine.
2
BLOCK_16
Determines the block sixe.
1
BLOCK_EN
Choses the store mode.
0
CH_EN
Channel enable.
41.11.102
Store engine status Channel 0 Register
(PXP_HW_PXP_WFE_B_STORE_STATUS_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1360h offset = 21C_D360h
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
STORE_BLOCK_Y
STORE_BLOCK_X
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
PXP_HW_PXP_WFE_B_STORE_STATUS_CH0 field descriptions
Field
Description
31–16
STORE_
BLOCK_Y
When in scan mode, this field indicates the current Y coordinate of the frame. In block mode, it indicates
the Y coordinate of the block currently being rendered.
STORE_
BLOCK_X
When in scan mode, this field is always 0. In block mode, it indicates the X coordinate of the block
currently being rendered.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2669

<!-- page 2670 -->

41.11.103
Store engine status Channel 1 Register
(PXP_HW_PXP_WFE_B_STORE_STATUS_CH1)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1370h offset = 21C_D370h
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
STORE_BLOCK_Y
STORE_BLOCK_X
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
PXP_HW_PXP_WFE_B_STORE_STATUS_CH1 field descriptions
Field
Description
31–16
STORE_
BLOCK_Y
When in scan mode, this field indicates the current Y coordinate of the frame. In block mode, it indicates
the Y coordinate of the block currently being rendered.
STORE_
BLOCK_X
When in scan mode, this field is always 0. In block mode, it indicates the X coordinate of the block
currently being rendered.
41.11.104
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_SIZE_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1380h offset = 21C_D380h
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
OUT_HEIGHT
OUT_WIDTH
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
PXP_HW_PXP_WFE_B_STORE_SIZE_CH0 field descriptions
Field
Description
31–16
OUT_HEIGHT
actual output height -1
OUT_WIDTH
actual output width -1
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2670
NXP Semiconductors

<!-- page 2671 -->

41.11.105
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_SIZE_CH1)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1390h offset = 21C_D390h
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
OUT_HEIGHT
OUT_WIDTH
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
PXP_HW_PXP_WFE_B_STORE_SIZE_CH1 field descriptions
Field
Description
31–16
OUT_HEIGHT
actual output height -1
OUT_WIDTH
actual output width -1
41.11.106
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_PITCH)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 13A0h offset = 21C_D3A0h
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
CH1_OUT_PITCH
CH0_OUT_PITCH
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
PXP_HW_PXP_WFE_B_STORE_PITCH field descriptions
Field
Description
31–16
CH1_OUT_
PITCH
This field indicates the channel 1 input pitch
CH0_OUT_
PITCH
This field indicates the channel 0 input pitch
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2671

<!-- page 2672 -->

41.11.107
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_SHIFT_CTRL_CH0n)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 13B0h offset + (4d × i), where i=0d to 3d
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
SHIFT_BYPASS
0
OUT_YUV422_
2P_EN
OUT_YUV422_
1P_EN
OUTPUT_
ACTIVE_
BPP
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
PXP_HW_PXP_WFE_B_STORE_SHIFT_CTRL_CH0n field descriptions
Field
Description
31–8
Reserved
This read-only field is reserved and always has the value 0.
7
SHIFT_BYPASS
CH0 shift bypass
6
Reserved
This read-only field is reserved and always has the value 0.
5
OUT_YUV422_
2P_EN
Enable for YUV422 2 plane
4
OUT_YUV422_
1P_EN
Enable for YUV422 1 plane
3–2
OUTPUT_
ACTIVE_BPP
Output Active BPP
Reserved
This read-only field is reserved and always has the value 0.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2672
NXP Semiconductors

<!-- page 2673 -->

41.11.108
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_SHIFT_CTRL_CH1n)
The Control register contains the control bits for the pxp prefetch_engine sub-block.
Address: 21C_C000h base + 13C0h offset + (4d × i), where i=0d to 3d
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
OUT_YUV422_
2P_EN
OUT_YUV422_
1P_EN
OUTPUT_
ACTIVE_
BPP
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
PXP_HW_PXP_WFE_B_STORE_SHIFT_CTRL_CH1n field descriptions
Field
Description
31–6
Reserved
This read-only field is reserved and always has the value 0.
5
OUT_YUV422_
2P_EN
Enable for YUV422 2 plane
4
OUT_YUV422_
1P_EN
Enable for YUV422 1 plane
3–2
OUTPUT_
ACTIVE_BPP
Output Active BPP
Reserved
This read-only field is reserved and always has the value 0.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2673

<!-- page 2674 -->

41.11.109
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_ADDR_0_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1410h offset = 21C_D410h
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
OUT_BASE_ADDR0
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
PXP_HW_PXP_WFE_B_STORE_ADDR_0_CH0 field descriptions
Field
Description
OUT_BASE_
ADDR0
input base address0. For 2 channel, indicated the channel0 base address. For 1 channel and YUV422 2
plane, indicate the Y base address
41.11.110
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_ADDR_1_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1420h offset = 21C_D420h
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
OUT_BASE_ADDR1
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
PXP_HW_PXP_WFE_B_STORE_ADDR_1_CH0 field descriptions
Field
Description
OUT_BASE_
ADDR1
input base address1. For 2 channel, indicated the channel1 base address. For 1 channel and YUV422 2
plane, indicate the Y base address
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2674
NXP Semiconductors

<!-- page 2675 -->

41.11.111
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_FILL_DATA_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1430h offset = 21C_D430h
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
FILL_DATA_CH0
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
PXP_HW_PXP_WFE_B_STORE_FILL_DATA_CH0 field descriptions
Field
Description
FILL_DATA_CH0 when using fill_data mode,store engine channel0 will store the fill_data value defined here.
41.11.112
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_ADDR_0_CH1)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1440h offset = 21C_D440h
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
OUT_BASE_ADDR0
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
PXP_HW_PXP_WFE_B_STORE_ADDR_0_CH1 field descriptions
Field
Description
OUT_BASE_
ADDR0
input base address0. For 2 channel, indicated the channel0 base address. For 1 channel and YUV422 2
plane, indicate the Y base address
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2675

<!-- page 2676 -->

41.11.113
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_ADDR_1_CH1)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1450h offset = 21C_D450h
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
OUT_BASE_ADDR1
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
PXP_HW_PXP_WFE_B_STORE_ADDR_1_CH1 field descriptions
Field
Description
OUT_BASE_
ADDR1
input base address1. For 2 channel, indicated the channel1 base address. For 1 channel and YUV422 2
plane, indicate the Y base address
41.11.114
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK0_H_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1460h offset = 21C_D460h
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
D_MASK0_H_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK0_H_CH0 field descriptions
Field
Description
D_MASK0_H_
CH0
data mask0 high byte
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2676
NXP Semiconductors

<!-- page 2677 -->

41.11.115
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK0_L_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1470h offset = 21C_D470h
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
D_MASK0_L_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK0_L_CH0 field descriptions
Field
Description
D_MASK0_L_
CH0
data mask0 low byte
41.11.116
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK1_H_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1480h offset = 21C_D480h
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
D_MASK1_H_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK1_H_CH0 field descriptions
Field
Description
D_MASK1_H_
CH0
data mask1 high byte
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2677

<!-- page 2678 -->

41.11.117
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK1_L_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1490h offset = 21C_D490h
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
D_MASK1_L_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK1_L_CH0 field descriptions
Field
Description
D_MASK1_L_
CH0
data mask1 low byte
41.11.118
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK2_H_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 14A0h offset = 21C_D4A0h
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
D_MASK2_H_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK2_H_CH0 field descriptions
Field
Description
D_MASK2_H_
CH0
data mask2 high byte
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2678
NXP Semiconductors

<!-- page 2679 -->

41.11.119
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK2_L_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 14B0h offset = 21C_D4B0h
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
D_MASK2_L_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK2_L_CH0 field descriptions
Field
Description
D_MASK2_L_
CH0
data mask2 low byte
41.11.120
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK3_H_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 14C0h offset = 21C_D4C0h
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
D_MASK3_H_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK3_H_CH0 field descriptions
Field
Description
D_MASK3_H_
CH0
data mask3 high byte
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2679

<!-- page 2680 -->

41.11.121
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK3_L_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 14D0h offset = 21C_D4D0h
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
D_MASK3_L_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK3_L_CH0 field descriptions
Field
Description
D_MASK3_L_
CH0
data mask3 low byte
41.11.122
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK4_H_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 14E0h offset = 21C_D4E0h
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
D_MASK4_H_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK4_H_CH0 field descriptions
Field
Description
D_MASK4_H_
CH0
data mask4 high byte
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2680
NXP Semiconductors

<!-- page 2681 -->

41.11.123
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK4_L_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 14F0h offset = 21C_D4F0h
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
D_MASK4_L_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK4_L_CH0 field descriptions
Field
Description
D_MASK4_L_
CH0
data mask4 low byte
41.11.124
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK5_H_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1500h offset = 21C_D500h
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
D_MASK5_H_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK5_H_CH0 field descriptions
Field
Description
D_MASK5_H_
CH0
data mask5 high byte
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2681

<!-- page 2682 -->

41.11.125
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK5_L_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1510h offset = 21C_D510h
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
D_MASK5_L_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK5_L_CH0 field descriptions
Field
Description
D_MASK5_L_
CH0
data mask5 low byte
41.11.126
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK6_H_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1520h offset = 21C_D520h
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
D_MASK6_H_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK6_H_CH0 field descriptions
Field
Description
D_MASK6_H_
CH0
data mask6 high byte
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2682
NXP Semiconductors

<!-- page 2683 -->

41.11.127
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK6_L_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1530h offset = 21C_D530h
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
D_MASK6_L_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK6_L_CH0 field descriptions
Field
Description
D_MASK6_L_
CH0
data mask6 low byte
41.11.128
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK7_H_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1540h offset = 21C_D540h
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
D_MASK7_H_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK7_H_CH0 field descriptions
Field
Description
D_MASK7_H_
CH0
data mask7 high byte
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2683

<!-- page 2684 -->

41.11.129
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_MASK7_L_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1550h offset = 21C_D550h
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
D_MASK7_L_CH0
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
PXP_HW_PXP_WFE_B_STORE_D_MASK7_L_CH0 field descriptions
Field
Description
D_MASK7_L_
CH0
data mask7 low byte
41.11.130
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_SHIFT_L_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1560h offset = 21C_D560h
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
D_SHIFT_FLAG3
0
D_SHIFT_WIDTH3
D_SHIFT_FLAG2
0
D_SHIFT_WIDTH2
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
D_SHIFT_FLAG1
0
D_SHIFT_WIDTH1
D_SHIFT_FLAG0
0
D_SHIFT_WIDTH0
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2684
NXP Semiconductors

<!-- page 2685 -->

PXP_HW_PXP_WFE_B_STORE_D_SHIFT_L_CH0 field descriptions
Field
Description
31
D_SHIFT_FLAG3
data shift flag 3
30
Reserved
This read-only field is reserved and always has the value 0.
29–24
D_SHIFT_
WIDTH3
data shift width 3
23
D_SHIFT_FLAG2
data shift flag 2
22
Reserved
This read-only field is reserved and always has the value 0.
21–16
D_SHIFT_
WIDTH2
data shift width 2
15
D_SHIFT_FLAG1
data shift flag 1
14
Reserved
This read-only field is reserved and always has the value 0.
13–8
D_SHIFT_
WIDTH1
data shift width 1
7
D_SHIFT_FLAG0
data shift flag 0
6
Reserved
This read-only field is reserved and always has the value 0.
D_SHIFT_
WIDTH0
data shift width 0
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2685

<!-- page 2686 -->

41.11.131
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_D_SHIFT_H_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1570h offset = 21C_D570h
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
D_SHIFT_FLAG7
0
D_SHIFT_WIDTH7
D_SHIFT_FLAG6
0
D_SHIFT_WIDTH6
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
D_SHIFT_FLAG5
0
D_SHIFT_WIDTH5
D_SHIFT_FLAG4
0
D_SHIFT_WIDTH4
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
PXP_HW_PXP_WFE_B_STORE_D_SHIFT_H_CH0 field descriptions
Field
Description
31
D_SHIFT_FLAG7
data shift flag 7
30
Reserved
This read-only field is reserved and always has the value 0.
29–24
D_SHIFT_
WIDTH7
data shift width 3
23
D_SHIFT_FLAG6
data shift flag 6
22
Reserved
This read-only field is reserved and always has the value 0.
21–16
D_SHIFT_
WIDTH6
data shift width 6
15
D_SHIFT_FLAG5
data shift flag 5
14
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2686
NXP Semiconductors

<!-- page 2687 -->

PXP_HW_PXP_WFE_B_STORE_D_SHIFT_H_CH0 field descriptions (continued)
Field
Description
13–8
D_SHIFT_
WIDTH5
data shift width 5
7
D_SHIFT_FLAG4
data shift flag 4
6
Reserved
This read-only field is reserved and always has the value 0.
D_SHIFT_
WIDTH4
data shift width 4
41.11.132
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_F_SHIFT_L_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1580h offset = 21C_D580h
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
F_SHIFT_
FLAG3
F_SHIFT_WIDTH3
0
F_SHIFT_
FLAG2
F_SHIFT_WIDTH2
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
F_SHIFT_
FLAG1
F_SHIFT_WIDTH1
0
F_SHIFT_
FLAG0
F_SHIFT_WIDTH0
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
PXP_HW_PXP_WFE_B_STORE_F_SHIFT_L_CH0 field descriptions
Field
Description
31
Reserved
This read-only field is reserved and always has the value 0.
30
F_SHIFT_FLAG3
flag shift flag3
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2687

<!-- page 2688 -->

PXP_HW_PXP_WFE_B_STORE_F_SHIFT_L_CH0 field descriptions (continued)
Field
Description
29–24
F_SHIFT_
WIDTH3
flag shift width 3
23
Reserved
This read-only field is reserved and always has the value 0.
22
F_SHIFT_FLAG2
flag shift flag2
21–16
F_SHIFT_
WIDTH2
flag shift width 2
15
Reserved
This read-only field is reserved and always has the value 0.
14
F_SHIFT_FLAG1
flag shift flag1
13–8
F_SHIFT_
WIDTH1
flag shift width 1
7
Reserved
This read-only field is reserved and always has the value 0.
6
F_SHIFT_FLAG0
flag shift flag0
F_SHIFT_
WIDTH0
flag shift width 0
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2688
NXP Semiconductors

<!-- page 2689 -->

41.11.133
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_F_SHIFT_H_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 1590h offset = 21C_D590h
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
F_SHIFT_
FLAG7
F_SHIFT_WIDTH7
0
F_SHIFT_
FLAG6
F_SHIFT_WIDTH6
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
F_SHIFT_
FLAG5
F_SHIFT_WIDTH5
0
F_SHIFT_
FLAG4
F_SHIFT_WIDTH4
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
PXP_HW_PXP_WFE_B_STORE_F_SHIFT_H_CH0 field descriptions
Field
Description
31
Reserved
This read-only field is reserved and always has the value 0.
30
F_SHIFT_FLAG7
flag shift flag7
29–24
F_SHIFT_
WIDTH7
flag shift width 7
23
Reserved
This read-only field is reserved and always has the value 0.
22
F_SHIFT_FLAG6
flag shift flag6
21–16
F_SHIFT_
WIDTH6
flag shift width 5
15
Reserved
This read-only field is reserved and always has the value 0.
14
F_SHIFT_FLAG5
flag shift flag5
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2689

<!-- page 2690 -->

PXP_HW_PXP_WFE_B_STORE_F_SHIFT_H_CH0 field descriptions (continued)
Field
Description
13–8
F_SHIFT_
WIDTH5
flag shift width 5
7
Reserved
This read-only field is reserved and always has the value 0.
6
F_SHIFT_FLAG4
flag shift flag4
F_SHIFT_
WIDTH4
flag shift width 4
41.11.134
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_F_MASK_L_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 15A0h offset = 21C_D5A0h
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
F_MASK3
F_MASK2
F_MASK1
F_MASK0
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
PXP_HW_PXP_WFE_B_STORE_F_MASK_L_CH0 field descriptions
Field
Description
31–24
F_MASK3
flag mask3
23–16
F_MASK2
flag mask2
15–8
F_MASK1
flag mask1
F_MASK0
flag mask0
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2690
NXP Semiconductors

<!-- page 2691 -->

41.11.135
This register defines the control bits for the pxp
store_engine sub-block.
(PXP_HW_PXP_WFE_B_STORE_F_MASK_H_CH0)
The Control register contains the control bits for the pxp store_engine sub-block.
Address: 21C_C000h base + 15B0h offset = 21C_D5B0h
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
F_MASK7
F_MASK6
F_MASK5
F_MASK4
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
PXP_HW_PXP_WFE_B_STORE_F_MASK_H_CH0 field descriptions
Field
Description
31–24
F_MASK7
flag mask7
23–16
F_MASK6
flag mask6
15–8
F_MASK5
flag mask5
F_MASK4
flag mask4
41.11.136
This register holds the debug bits for the prefetch
engine for WFE B.
(PXP_HW_PXP_FETCH_WFE_B_DEBUG)
The Control register contains the debug information for the pxp array fetch block.
Address: 21C_C000h base + 15D0h offset = 21C_D5D0h
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
BUF_
SEL
ITEM_SEL
DEBUG_VALUE
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
DEBUG_VALUE
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2691

<!-- page 2692 -->

PXP_HW_PXP_FETCH_WFE_B_DEBUG field descriptions
Field
Description
31–29
Reserved
This read-only field is reserved and always has the value 0.
28
BUF_SEL
Index into WFE A BUFFER.
27–24
ITEM_SEL
Index into one of the PXP debug registers. The data for the selected register will be returned
DEBUG_VALUE Debug information for array fetch.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2692
NXP Semiconductors

<!-- page 2693 -->

41.11.137
Dither Control Register 0
(PXP_HW_PXP_DITHER_CTRLn)
The Control register contains the primary controls for the PXP block.
Address: 21C_C000h base + 1670h offset + (4d × i), where i=0d to 3d
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
BUSY0
BUSY1
BUSY2
0
ORDERED_ROUND_MODE
FINAL_LUT_ENABLE
IDX_
MATRIX2_
SIZE
IDX_
MATRIX1_
SIZE
IDX_
MATRIX0_
SIZE
LUT_MODE
W
Reset
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
1
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
LUT_MODE
NUM_QUANT_BIT
DITHER_MODE2
DITHER_MODE1
DITHER_MODE0
ENABLE2
ENABLE1
ENABLE0
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2693

<!-- page 2694 -->

PXP_HW_PXP_DITHER_CTRLn field descriptions
Field
Description
31
BUSY0
When set indicates if the dither engine 0 is busy -- started but not finished processing all of the pixels in
the current frame.
30
BUSY1
When set indicates if the dither engine 1 is busy -- started but not finished processing all of the pixels in
the current frame.
29
BUSY2
When set indicates if the dither engine 2 is busy -- started but not finished processing all of the pixels in
the current frame.
28–25
Reserved
This read-only field is reserved and always has the value 0.
24
ORDERED_
ROUND_MODE
For test purposes. In ordered mode only, this field specifies to use rounding or truncation when calculating
the ouptput pixel.
23
FINAL_LUT_
ENABLE
Enables a final stage register based LUT at the last stage before output. the lookup transform values
come from register bits, not internal memory. Therefore they must be setup by the user by writing to the
registers before processing.
22–21
IDX_MATRIX2_
SIZE
For Dither Engine 2. Specify dimension (assumed square) of the index matrix in the LUT memory so
proper indexing can occur.
20–19
IDX_MATRIX1_
SIZE
For Dither Engine 1. Specify dimension (assumed square) of the index matrix in the LUT memory so
proper indexing can occur.
18–17
IDX_MATRIX0_
SIZE
For Dither Engine 0. Specify dimension (assumed square) of the index matrix in the LUT memory so
proper indexing can occur.
16–15
LUT_MODE
Specify to use memory lut to transform pixel. Lookup pre or post dithering cannot be used with Ordered
dithering. This field only has reference to the internal memory based LUT function. There is a final stage
LUT that is enabled through the FINAL_LUT_ENABLE field in this register. This final stage LUT can be
enabled in any dither mode or LUT mode.
14–12
NUM_QUANT_
BIT
Number of bits to quantize down to. From 8 to (0-7).
11–9
DITHER_MODE2
Dither mode.
8–6
DITHER_MODE1
Dither mode.
5–3
DITHER_MODE0
Dither mode.
2
ENABLE2
Enables the dither engine 2
1
ENABLE1
Enables the dither engine 1
0
ENABLE0
Enables the dither engine 0
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2694
NXP Semiconductors

<!-- page 2695 -->

41.11.138
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA0n)
This register contains lookup data values for the final stage register based dither LUT.
Address: 21C_C000h base + 1680h offset + (4d × i), where i=0d to 3d
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
DATA3
DATA2
DATA1
DATA0
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
PXP_HW_PXP_DITHER_FINAL_LUT_DATA0n field descriptions
Field
Description
31–24
DATA3
Final stage LUT data value.
23–16
DATA2
Final stage LUT data value.
15–8
DATA1
Final stage LUT data value.
DATA0
Final stage LUT data value.
41.11.139
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA1n)
This register contains lookup data values for the final stage register based dither LUT.
Address: 21C_C000h base + 1690h offset + (4d × i), where i=0d to 3d
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
DATA7
DATA6
DATA5
DATA4
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
PXP_HW_PXP_DITHER_FINAL_LUT_DATA1n field descriptions
Field
Description
31–24
DATA7
Final stage LUT data value.
23–16
DATA6
Final stage LUT data value.
15–8
DATA5
Final stage LUT data value.
DATA4
Final stage LUT data value.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2695

<!-- page 2696 -->

41.11.140
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA2n)
This register contains lookup data values for the final stage register based dither LUT.
Address: 21C_C000h base + 16A0h offset + (4d × i), where i=0d to 3d
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
DATA11
DATA10
DATA9
DATA8
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
PXP_HW_PXP_DITHER_FINAL_LUT_DATA2n field descriptions
Field
Description
31–24
DATA11
Final stage LUT data value.
23–16
DATA10
Final stage LUT data value.
15–8
DATA9
Final stage LUT data value.
DATA8
Final stage LUT data value.
41.11.141
Final stage lookup value Register
(PXP_HW_PXP_DITHER_FINAL_LUT_DATA3n)
This register contains lookup data values for the final stage register based dither LUT.
Address: 21C_C000h base + 16B0h offset + (4d × i), where i=0d to 3d
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
DATA15
DATA14
DATA13
DATA12
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
PXP_HW_PXP_DITHER_FINAL_LUT_DATA3n field descriptions
Field
Description
31–24
DATA15
Final stage LUT data value.
23–16
DATA14
Final stage LUT data value.
15–8
DATA13
Final stage LUT data value.
DATA12
Final stage LUT data value.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2696
NXP Semiconductors

<!-- page 2697 -->

41.11.142
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_CTRLn)
The Control register contains the control bits for the pxp wfe sub-block.
Address: 21C_C000h base + 1D00h offset + (4d × i), where i=0d to 3d
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
DONE
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
SW_RESET
0
ENABLE
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
PXP_HW_PXP_WFE_B_CTRLn field descriptions
Field
Description
31
DONE
This field indicates that the WFE B has completed processing the update memory region.
30–3
Reserved
This read-only field is reserved and always has the value 0.
2
SW_RESET
Reset WFE B state. This is a active high reset value.
1
Reserved
This read-only field is reserved and always has the value 0.
0
ENABLE
Enables the WFE B Block
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2697

<!-- page 2698 -->

41.11.143
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_DIMENSIONS)
The Control register contains the control bits for the pxp wfe sub-block.
Address: 21C_C000h base + 1D10h offset = 21C_DD10h
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
HEIGHT
0
WIDTH
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
PXP_HW_PXP_WFE_B_DIMENSIONS field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27–16
HEIGHT
This field defines the height in pixels of the update region.
15–12
Reserved
This read-only field is reserved and always has the value 0.
WIDTH
This bit defines the width in pixels of the update region.
41.11.144
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_OFFSET)
The Control register contains the control bits for the pxp wfe sub-block.
Address: 21C_C000h base + 1D20h offset = 21C_DD20h
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
Y_OFFSET
0
X_OFFSET
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
PXP_HW_PXP_WFE_B_OFFSET field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27–16
Y_OFFSET
This field defines the distance from the frame origin to the update region origin in the Y direction.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2698
NXP Semiconductors

<!-- page 2699 -->

PXP_HW_PXP_WFE_B_OFFSET field descriptions (continued)
Field
Description
15–12
Reserved
This read-only field is reserved and always has the value 0.
X_OFFSET
This field defines the distance from the frame origin to the update region origin in the X direction.
41.11.145
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_SW_DATA_REGS)
The Control register contains the control bits for the pxp wfe sub-block.
Address: 21C_C000h base + 1D30h offset = 21C_DD30h
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
VAL3
VAL2
VAL1
VAL0
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
PXP_HW_PXP_WFE_B_SW_DATA_REGS field descriptions
Field
Description
31–24
VAL3
This is a SW register that holds a programmable data value.
23–16
VAL2
This is a SW register that holds a programmable data value.
15–8
VAL1
This is a SW register that holds a programmable data value.
VAL0
This is a SW register that holds a programmable data value.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2699

<!-- page 2700 -->

41.11.146
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_SW_FLAG_REGS)
The Control register contains the control bits for the pxp wfe sub-block.
Address: 21C_C000h base + 1D40h offset = 21C_DD40h
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
VAL3
VAL2
VAL1
VAL0
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
PXP_HW_PXP_WFE_B_SW_FLAG_REGS field descriptions
Field
Description
31–4
Reserved
This read-only field is reserved and always has the value 0.
3
VAL3
This is a SW register that holds a programmable flag value.
2
VAL2
This is a SW register that holds a programmable flag value.
1
VAL1
This is a SW register that holds a programmable flag value.
0
VAL0
This is a SW register that holds a programmable flag value.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2700
NXP Semiconductors

<!-- page 2701 -->

41.11.147
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE1_MUX0n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1D50h offset + (4d × i), where i=0d to 3d
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
MUX3
0
MUX2
0
MUX1
0
MUX0
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
PXP_HW_PXP_WFE_B_STAGE1_MUX0n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX3
Input 4 data select bits for 5x8 LUT 0.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX2
Input 3 data select bits for 5x8 LUT 0.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX1
Input 2 data select bits for 5x8 LUT 0.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX0
Input 1 data select bits for 5x8 LUT 0.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2701

<!-- page 2702 -->

41.11.148
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE1_MUX1n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1D60h offset + (4d × i), where i=0d to 3d
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
MUX7
0
MUX6
0
MUX5
0
MUX4
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
PXP_HW_PXP_WFE_B_STAGE1_MUX1n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX7
Input 3 data select bits for 5x8 LUT 1.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX6
Input 2 data select bits for 5x8 LUT 1.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX5
Input 1 data select bits for 5x8 LUT 1.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX4
Input 5 data select bits for 5x8 LUT 0.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2702
NXP Semiconductors

<!-- page 2703 -->

41.11.149
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE1_MUX2n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1D70h offset + (4d × i), where i=0d to 3d
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
MUX11
0
MUX10
0
MUX9
0
MUX8
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
PXP_HW_PXP_WFE_B_STAGE1_MUX2n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX11
Input 2 data select bits for 5x1 LUT 0.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX10
Input 1 data select bits for 5x1 LUT 0.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX9
Input 5 data select bits for 5x8 LUT 1.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX8
Input 4 data select bits for 5x8 LUT 1.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2703

<!-- page 2704 -->

41.11.150
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE1_MUX3n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1D80h offset + (4d × i), where i=0d to 3d
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
MUX15
0
MUX14
0
MUX13
0
MUX12
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
PXP_HW_PXP_WFE_B_STAGE1_MUX3n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX15
Data select bits for D8x1 LUT 0.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX14
Input 5 data select bits for 5x1 LUT 0.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX13
Input 4 data select bits for 5x1 LUT 0.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX12
Input 3 data select bits for 5x1 LUT 0.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2704
NXP Semiconductors

<!-- page 2705 -->

41.11.151
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE1_MUX4n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1D90h offset + (4d × i), where i=0d to 3d
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
MUX19
0
MUX18
0
MUX17
0
MUX16
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
PXP_HW_PXP_WFE_B_STAGE1_MUX4n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX19
Data select bits for D8x1 LUT 4.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX18
Data select bits for D8x1 LUT 3.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX17
Data select bits for D8x1 LUT 2.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX16
Data select bits for D8x1 LUT 1.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2705

<!-- page 2706 -->

41.11.152
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE1_MUX5n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1DA0h offset + (4d × i), where i=0d to 3d
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
MUX23
0
MUX22
0
MUX21
0
MUX20
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
1
1
0
0
PXP_HW_PXP_WFE_B_STAGE1_MUX5n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX23
Input data select bits for Comparator 0.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX22
Input data select bits for ALU 0.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX21
Input data select bits for ALU 0.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX20
Instruction select bits for ALU 0.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2706
NXP Semiconductors

<!-- page 2707 -->

41.11.153
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE1_MUX6n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1DB0h offset + (4d × i), where i=0d to 3d
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
MUX27
0
MUX26
0
MUX25
0
MUX24
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
PXP_HW_PXP_WFE_B_STAGE1_MUX6n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX27
Input data select bits for Comparator 2.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX26
Input data select bits for Comparator 1.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX25
Input data select bits for Comparator 1.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX24
Input data select bits for Comparator 0.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2707

<!-- page 2708 -->

41.11.154
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE1_MUX7n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1DC0h offset + (4d × i), where i=0d to 3d
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
MUX31
0
MUX30
0
MUX29
0
MUX28
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
PXP_HW_PXP_WFE_B_STAGE1_MUX7n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX31
Input data select bits for Comparator 4.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX30
Input data select bits for Comparator 3.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX29
Input data select bits for Comparator 3.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX28
Input data select bits for Comparator 2.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2708
NXP Semiconductors

<!-- page 2709 -->

41.11.155
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE1_MUX8n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1DD0h offset + (4d × i), where i=0d to 3d
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
MUX32
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
PXP_HW_PXP_WFE_B_STAGE1_MUX8n field descriptions
Field
Description
31–6
Reserved
This read-only field is reserved and always has the value 0.
MUX32
Input data select bits for Comparator 4.
41.11.156
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE2_MUX0n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1DE0h offset + (4d × i), where i=0d to 3d
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
MUX3
0
MUX2
0
MUX1
0
MUX0
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2709

<!-- page 2710 -->

PXP_HW_PXP_WFE_B_STAGE2_MUX0n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX3
Input 4 data select bits for 5x6 LUT 0.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX2
Input 3 data select bits for 5x6 LUT 0.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX1
Input 2 data select bits for 5x6 LUT 0.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX0
Input 1 data select bits for 5x6 LUT 0.
41.11.157
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE2_MUX1n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1DF0h offset + (4d × i), where i=0d to 3d
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
MUX7
0
MUX6
0
MUX5
0
MUX4
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
PXP_HW_PXP_WFE_B_STAGE2_MUX1n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX7
Input 3 data select bits for 5x6 LUT 1.
23–22
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2710
NXP Semiconductors

<!-- page 2711 -->

PXP_HW_PXP_WFE_B_STAGE2_MUX1n field descriptions (continued)
Field
Description
21–16
MUX6
Input 2 data select bits for 5x6 LUT 1.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX5
Input 1 data select bits for 5x6 LUT 1.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX4
Input 5 data select bits for 5x6 LUT 0.
41.11.158
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE2_MUX2n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1E00h offset + (4d × i), where i=0d to 3d
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
MUX11
0
MUX10
0
MUX9
0
MUX8
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
PXP_HW_PXP_WFE_B_STAGE2_MUX2n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX11
Input 2 data select bits for 5x6 LUT 2.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX10
Input 1 data select bits for 5x6 LUT 2.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX9
Input 5 data select bits for 5x6 LUT 1.
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2711

<!-- page 2712 -->

PXP_HW_PXP_WFE_B_STAGE2_MUX2n field descriptions (continued)
Field
Description
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX8
Input 4 data select bits for 5x6 LUT 1.
41.11.159
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE2_MUX3n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1E10h offset + (4d × i), where i=0d to 3d
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
MUX15
0
MUX14
0
MUX13
0
MUX12
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
PXP_HW_PXP_WFE_B_STAGE2_MUX3n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX15
Input 1 data select bits for 5x6 LUT 3.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX14
Input 5 data select bits for 5x6 LUT 2.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX13
Input 4 data select bits for 5x6 LUT 2.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX12
Input 3 data select bits for 5x6 LUT 2.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2712
NXP Semiconductors

<!-- page 2713 -->

41.11.160
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE2_MUX4n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1E20h offset + (4d × i), where i=0d to 3d
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
MUX19
0
MUX18
0
MUX17
0
MUX16
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
PXP_HW_PXP_WFE_B_STAGE2_MUX4n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX19
Input 5 data select bits for 5x1 LUT 3.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX18
Input 4 data select bits for 5x6 LUT 3.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX17
Input 3 data select bits for 5x6 LUT 3.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX16
Input 2 data select bits for 5x6 LUT 3.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2713

<!-- page 2714 -->

41.11.161
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE2_MUX5n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1E30h offset + (4d × i), where i=0d to 3d
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
MUX23
0
MUX22
0
MUX21
0
MUX20
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
PXP_HW_PXP_WFE_B_STAGE2_MUX5n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX23
Input 4 data select bits for 5x1 LUT 0.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX22
Input 3 data select bits for 5x1 LUT 0.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX21
Input 2 data select bits for 5x1 LUT 0.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX20
Input 1 data select bits for 5x1 LUT 0.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2714
NXP Semiconductors

<!-- page 2715 -->

41.11.162
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE2_MUX6n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1E40h offset + (4d × i), where i=0d to 3d
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
MUX27
0
MUX26
0
MUX25
0
MUX24
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
PXP_HW_PXP_WFE_B_STAGE2_MUX6n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX27
Input 3 data select bits for 5x1 LUT 1.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX26
Input 2 data select bits for 5x1 LUT 1.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX25
Input 1 data select bits for 5x1 LUT 1.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX24
Input 5 data select bits for 5x1 LUT 0.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2715

<!-- page 2716 -->

41.11.163
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE2_MUX7n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1E50h offset + (4d × i), where i=0d to 3d
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
MUX31
0
MUX30
0
MUX29
0
MUX28
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
PXP_HW_PXP_WFE_B_STAGE2_MUX7n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX31
Input 2 data select bits for 5x1 LUT 2.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX30
Input 1 data select bits for 5x1 LUT 2.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX29
Input 5 data select bits for 5x1 LUT 1.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX28
Input 4 data select bits for 5x1 LUT 1.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2716
NXP Semiconductors

<!-- page 2717 -->

41.11.164
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE2_MUX8n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1E60h offset + (4d × i), where i=0d to 3d
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
MUX35
0
MUX34
0
MUX33
0
MUX32
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
PXP_HW_PXP_WFE_B_STAGE2_MUX8n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX35
Input 1 data select bits for 5x1 LUT 3.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX34
Input 5 data select bits for 5x1 LUT 2.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX33
Input 4 data select bits for 5x1 LUT 2.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX32
Input 3 data select bits for 5x1 LUT 2.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2717

<!-- page 2718 -->

41.11.165
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE2_MUX9n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1E70h offset + (4d × i), where i=0d to 3d
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
MUX39
0
MUX38
0
MUX37
0
MUX36
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
PXP_HW_PXP_WFE_B_STAGE2_MUX9n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX39
Input 5 data select bits for 5x1 LUT 3.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX38
Input 4 data select bits for 5x1 LUT 3.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX37
Input 3 data select bits for 5x1 LUT 3.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX36
Input 2 data select bits for 5x1 LUT 3.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2718
NXP Semiconductors

<!-- page 2719 -->

41.11.166
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE2_MUX10n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1E80h offset + (4d × i), where i=0d to 3d
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
MUX43
0
MUX42
0
MUX41
0
MUX40
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
1
1
0
0
PXP_HW_PXP_WFE_B_STAGE2_MUX10n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX43
Input data select bits for Comparator 0.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX42
Input data select bits for ALU 0.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX41
Input data select bits for ALU 0.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX40
Instruction select bits for ALU 0.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2719

<!-- page 2720 -->

41.11.167
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE2_MUX11n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1E90h offset + (4d × i), where i=0d to 3d
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
MUX47
0
MUX46
0
MUX45
0
MUX44
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
PXP_HW_PXP_WFE_B_STAGE2_MUX11n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX47
Input data select bits for Comparator 2.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX46
Input data select bits for Comparator 1.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX45
Input data select bits for Comparator 1.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX44
Input data select bits for Comparator 0.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2720
NXP Semiconductors

<!-- page 2721 -->

41.11.168
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE2_MUX12n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1EA0h offset + (4d × i), where i=0d to 3d
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
MUX48
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
PXP_HW_PXP_WFE_B_STAGE2_MUX12n field descriptions
Field
Description
31–6
Reserved
This read-only field is reserved and always has the value 0.
MUX48
Input data select bits for Comparator 2.
41.11.169
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE3_MUX0n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1EB0h offset + (4d × i), where i=0d to 3d
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
MUX3
0
MUX2
0
MUX1
0
MUX0
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2721

<!-- page 2722 -->

PXP_HW_PXP_WFE_B_STAGE3_MUX0n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX3
Input 4 flag select bits for F8x1 LUT0.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX2
Input 3 flag select bits for F8x1 LUT0.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX1
Input 2 flag select bits for F8x1 LUT 0.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX0
Input 1 flag select bits for F8x1 LUT 0.
41.11.170
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE3_MUX1n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1EC0h offset + (4d × i), where i=0d to 3d
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
MUX7
0
MUX6
0
MUX5
0
MUX4
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
PXP_HW_PXP_WFE_B_STAGE3_MUX1n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX7
Input 8 flag select bits for F8x1 LUT 0.
23–22
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2722
NXP Semiconductors

<!-- page 2723 -->

PXP_HW_PXP_WFE_B_STAGE3_MUX1n field descriptions (continued)
Field
Description
21–16
MUX6
Input 7 flag select bits for F8x1 LUT 0.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX5
Input 6 flag select bits for F8x1 LUT 0.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX4
Input 5 flag select bits for F8x1 LUT 0.
41.11.171
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE3_MUX2n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1ED0h offset + (4d × i), where i=0d to 3d
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
MUX11
0
MUX10
0
MUX9
0
MUX8
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
PXP_HW_PXP_WFE_B_STAGE3_MUX2n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX11
Input 4 flag select bits for F8x1 LUT 1.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX10
Input 3 flag select bits for F8x1 LUT 1.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX9
Input 2 flag select bits for F8x1 LUT 1.
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2723

<!-- page 2724 -->

PXP_HW_PXP_WFE_B_STAGE3_MUX2n field descriptions (continued)
Field
Description
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX8
Input 1 flag select bits for F8x1 LUT 1.
41.11.172
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE3_MUX3n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1EE0h offset + (4d × i), where i=0d to 3d
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
MUX15
0
MUX14
0
MUX13
0
MUX12
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
PXP_HW_PXP_WFE_B_STAGE3_MUX3n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX15
Input 8 flag select bits for F8x1 LUT 1.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX14
Input 7 flag select bits for F8x1 LUT 1.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX13
Input 6 flag select bits for F8x1 LUT 1.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX12
Input 5 flag select bits for F8x1 LUT 1.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2724
NXP Semiconductors

<!-- page 2725 -->

41.11.173
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE3_MUX4n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1EF0h offset + (4d × i), where i=0d to 3d
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
MUX19
0
MUX18
0
MUX17
0
MUX16
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
PXP_HW_PXP_WFE_B_STAGE3_MUX4n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX19
Input 4 flag select bits for F8x1 LUT 2.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX18
Input 3 flag select bits for F8x1 LUT 2.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX17
Input 2 flag select bits for F8x1 LUT 2.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX16
Input 1 flag select bits for F8x1 LUT 2.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2725

<!-- page 2726 -->

41.11.174
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE3_MUX5n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1F00h offset + (4d × i), where i=0d to 3d
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
MUX23
0
MUX22
0
MUX21
0
MUX20
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
PXP_HW_PXP_WFE_B_STAGE3_MUX5n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX23
Input 8 flag select bits for F8x1 LUT 2.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX22
Input 7 flag select bits for F8x1 LUT 2.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX21
Input 6 flag select bits for F8x1 LUT 2.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX20
Input 5 flag select bits for F8x1 LUT 2.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2726
NXP Semiconductors

<!-- page 2727 -->

41.11.175
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE3_MUX6n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1F10h offset + (4d × i), where i=0d to 3d
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
MUX27
0
MUX26
0
MUX25
0
MUX24
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
PXP_HW_PXP_WFE_B_STAGE3_MUX6n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX27
Input 4 flag select bits for F8x1 LUT 3.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX26
Input 3 flag select bits for F8x1 LUT 3.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX25
Input 2 flag select bits for F8x1 LUT 3.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX24
Input 1 flag select bits for F8x1 LUT 3.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2727

<!-- page 2728 -->

41.11.176
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE3_MUX7n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1F20h offset + (4d × i), where i=0d to 3d
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
MUX31
0
MUX30
0
MUX29
0
MUX28
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
PXP_HW_PXP_WFE_B_STAGE3_MUX7n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX31
Input 8 flag select bits for F8x1 LUT 3.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX30
Input 7 flag select bits for F8x1 LUT 3.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX29
Input 6 flag select bits for F8x1 LUT 3.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX28
Input 5 flag select bits for F8x1 LUT 3.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2728
NXP Semiconductors

<!-- page 2729 -->

41.11.177
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE3_MUX8n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1F30h offset + (4d × i), where i=0d to 3d
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
MUX35
0
MUX34
0
MUX33
0
MUX32
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
PXP_HW_PXP_WFE_B_STAGE3_MUX8n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX35
Input data select bits for DMUX 3.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX34
Input data select bits for DMUX 2.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX33
Input data select bits for DMUX 1.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX32
Input data select bits for DMUX 0.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2729

<!-- page 2730 -->

41.11.178
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE3_MUX9n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1F40h offset + (4d × i), where i=0d to 3d
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
MUX39
0
MUX38
0
MUX37
0
MUX36
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
PXP_HW_PXP_WFE_B_STAGE3_MUX9n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX39
Input data select bits for DMUX 7.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX38
Input data select bits for DMUX 6.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX37
Input data select bits for DMUX 5.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX36
Input data select bits for DMUX 4.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2730
NXP Semiconductors

<!-- page 2731 -->

41.11.179
This register defines the control bits for the pxp wfe
sub-block (PXP_HW_PXP_WFE_B_STAGE3_MUX10n)
Mux value to select one of the flags or data inputs of the pipeline stage. Each mux
corresponds to one of the inputs to each of the logic elements (e.g. alu, comparator, LUT,
etc). Some logic elements have one mux and others have two or more. The mux numbers
are mapped to the pipeline according to the hardware configuration. Please see the
reference design for the mux map.
Address: 21C_C000h base + 1F50h offset + (4d × i), where i=0d to 3d
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
MUX43
0
MUX42
0
MUX41
0
MUX40
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
PXP_HW_PXP_WFE_B_STAGE3_MUX10n field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUX43
Input flag select bits for FMUX 3.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUX42
Input flag select bits for FMUX 2.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUX41
Input flag select bits for FMUX 1.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUX40
Input flag select bits for FMUX 0.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2731

<!-- page 2732 -->

41.11.180
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_0)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 1F60h offset = 21C_DF60h
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
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_0 field descriptions
Field
Description
31–24
LUTOUT3
LUTOUT 3
23–16
LUTOUT2
LUTOUT 2
15–8
LUTOUT1
LUTOUT 1
LUTOUT0
LUTOUT 0
41.11.181
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_1)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 1F70h offset = 21C_DF70h
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
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2732
NXP Semiconductors

<!-- page 2733 -->

PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_1 field descriptions
Field
Description
31–24
LUTOUT7
LUTOUT 3
23–16
LUTOUT6
LUTOUT 2
15–8
LUTOUT5
LUTOUT 1
LUTOUT4
LUTOUT 0
41.11.182
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_2)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 1F80h offset = 21C_DF80h
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
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
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
PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_2 field descriptions
Field
Description
31–24
LUTOUT11
LUTOUT 3
23–16
LUTOUT10
LUTOUT 2
15–8
LUTOUT9
LUTOUT 1
LUTOUT8
LUTOUT 0
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2733

<!-- page 2734 -->

41.11.183
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_3)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 1F90h offset = 21C_DF90h
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
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
PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_3 field descriptions
Field
Description
31–24
LUTOUT15
LUTOUT 3
23–16
LUTOUT14
LUTOUT 2
15–8
LUTOUT13
LUTOUT 1
LUTOUT12
LUTOUT 0
41.11.184
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_4)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 1FA0h offset = 21C_DFA0h
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
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2734
NXP Semiconductors

<!-- page 2735 -->

PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_4 field descriptions
Field
Description
31–24
LUTOUT19
LUTOUT 3
23–16
LUTOUT18
LUTOUT 2
15–8
LUTOUT17
LUTOUT 1
LUTOUT16
LUTOUT 0
41.11.185
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_5)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 1FB0h offset = 21C_DFB0h
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
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
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
PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_5 field descriptions
Field
Description
31–24
LUTOUT23
LUTOUT 3
23–16
LUTOUT22
LUTOUT 2
15–8
LUTOUT21
LUTOUT 1
LUTOUT20
LUTOUT 0
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2735

<!-- page 2736 -->

41.11.186
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_6)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 1FC0h offset = 21C_DFC0h
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
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
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
PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_6 field descriptions
Field
Description
31–24
LUTOUT27
LUTOUT 3
23–16
LUTOUT26
LUTOUT 2
15–8
LUTOUT25
LUTOUT 1
LUTOUT24
LUTOUT 0
41.11.187
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_7)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 1FD0h offset = 21C_DFD0h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2736
NXP Semiconductors

<!-- page 2737 -->

PXP_HW_PXP_WFE_B_STG1_5X8_OUT0_7 field descriptions
Field
Description
31–24
LUTOUT31
LUTOUT 3
23–16
LUTOUT30
LUTOUT 2
15–8
LUTOUT29
LUTOUT 1
LUTOUT28
LUTOUT 0
41.11.188
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_0)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 1FE0h offset = 21C_DFE0h
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
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_0 field descriptions
Field
Description
31–24
LUTOUT3
LUTOUT 3
23–16
LUTOUT2
LUTOUT 2
15–8
LUTOUT1
LUTOUT 1
LUTOUT0
LUTOUT 0
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2737

<!-- page 2738 -->

41.11.189
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_1)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 1FF0h offset = 21C_DFF0h
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
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
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
PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_1 field descriptions
Field
Description
31–24
LUTOUT7
LUTOUT 3
23–16
LUTOUT6
LUTOUT 2
15–8
LUTOUT5
LUTOUT 1
LUTOUT4
LUTOUT 0
41.11.190
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_2)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2000h offset = 21C_E000h
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
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2738
NXP Semiconductors

<!-- page 2739 -->

PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_2 field descriptions
Field
Description
31–24
LUTOUT11
LUTOUT 3
23–16
LUTOUT10
LUTOUT 2
15–8
LUTOUT9
LUTOUT 1
LUTOUT8
LUTOUT 0
41.11.191
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_3)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2010h offset = 21C_E010h
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
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
PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_3 field descriptions
Field
Description
31–24
LUTOUT15
LUTOUT 3
23–16
LUTOUT14
LUTOUT 2
15–8
LUTOUT13
LUTOUT 1
LUTOUT12
LUTOUT 0
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2739

<!-- page 2740 -->

41.11.192
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_4)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2020h offset = 21C_E020h
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
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_4 field descriptions
Field
Description
31–24
LUTOUT19
LUTOUT 3
23–16
LUTOUT18
LUTOUT 2
15–8
LUTOUT17
LUTOUT 1
LUTOUT16
LUTOUT 0
41.11.193
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_5)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2030h offset = 21C_E030h
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
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2740
NXP Semiconductors

<!-- page 2741 -->

PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_5 field descriptions
Field
Description
31–24
LUTOUT23
LUTOUT 3
23–16
LUTOUT22
LUTOUT 2
15–8
LUTOUT21
LUTOUT 1
LUTOUT20
LUTOUT 0
41.11.194
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_6)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2040h offset = 21C_E040h
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
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
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
PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_6 field descriptions
Field
Description
31–24
LUTOUT27
LUTOUT 3
23–16
LUTOUT26
LUTOUT 2
15–8
LUTOUT25
LUTOUT 1
LUTOUT24
LUTOUT 0
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2741

<!-- page 2742 -->

41.11.195
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_7)
The 5x8 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2050h offset = 21C_E050h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
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
PXP_HW_PXP_WFE_B_STG1_5X8_OUT1_7 field descriptions
Field
Description
31–24
LUTOUT31
LUTOUT 3
23–16
LUTOUT30
LUTOUT 2
15–8
LUTOUT29
LUTOUT 1
LUTOUT28
LUTOUT 0
41.11.196
Each set mask bit enables one of the corresponding
flag input bits. There is one mask per 5x8 LUT.
(PXP_HW_PXP_WFE_B_STAGE1_5X8_MASKS_0)
Each set mask bit enables one of the corresponding flag input bits. There is one mask per
5x8 LUT.
Address: 21C_C000h base + 2060h offset = 21C_E060h
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
MASK1
0
MASK0
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2742
NXP Semiconductors

<!-- page 2743 -->

PXP_HW_PXP_WFE_B_STAGE1_5X8_MASKS_0 field descriptions
Field
Description
31–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
MASK1
This field selects the input flags that are valid for 5x8 LUT 1. Bit 0 = input 1, Bit 1 = input 2 and so on.
7–5
Reserved
This read-only field is reserved and always has the value 0.
MASK0
This field selects the input flags that are valid for 5x8 LUT 0. Bit 0 = input 1, Bit 1 = input 2 and so on.
41.11.197
This register defines the output values (new flag) for
the 5x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_5X1_OUT0)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2070h offset = 21C_E070h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
PXP_HW_PXP_WFE_B_STG1_5X1_OUT0 field descriptions
Field
Description
31
LUTOUT31
LUT OUT
30
LUTOUT30
LUT OUT
29
LUTOUT29
LUT OUT
28
LUTOUT28
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2743

<!-- page 2744 -->

PXP_HW_PXP_WFE_B_STG1_5X1_OUT0 field descriptions (continued)
Field
Description
27
LUTOUT27
LUT OUT
26
LUTOUT26
LUT OUT
25
LUTOUT25
LUT OUT
24
LUTOUT24
LUT OUT
23
LUTOUT23
LUT OUT
22
LUTOUT22
LUT OUT
21
LUTOUT21
LUT OUT
20
LUTOUT20
LUT OUT
19
LUTOUT19
LUT OUT
18
LUTOUT18
LUT OUT
17
LUTOUT17
LUT OUT
16
LUTOUT16
LUT OUT
15
LUTOUT15
LUT OUT
14
LUTOUT14
LUT OUT
13
LUTOUT13
LUT OUT
12
LUTOUT12
LUT OUT
11
LUTOUT11
LUT OUT
10
LUTOUT10
LUT OUT
9
LUTOUT9
LUT OUT
8
LUTOUT8
LUT OUT
7
LUTOUT7
LUT OUT
6
LUTOUT6
LUT OUT
5
LUTOUT5
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2744
NXP Semiconductors

<!-- page 2745 -->

PXP_HW_PXP_WFE_B_STG1_5X1_OUT0 field descriptions (continued)
Field
Description
4
LUTOUT4
LUT OUT
3
LUTOUT3
LUT OUT
2
LUTOUT2
LUT OUT
1
LUTOUT1
LUT OUT
0
LUTOUT0
LUT OUT
41.11.198
Each set mask bit enables one of the corresponding
flag input bits. There is one mask per 5x1 LUT.
(PXP_HW_PXP_WFE_B_STG1_5X1_MASKS)
Each set mask bit enables one of the corresponding flag input bits. There is one mask per
5x1 LUT.
Address: 21C_C000h base + 2080h offset = 21C_E080h
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
MASK0
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
PXP_HW_PXP_WFE_B_STG1_5X1_MASKS field descriptions
Field
Description
31–5
Reserved
This read-only field is reserved and always has the value 0.
MASK0
This field selects the input flags that are valid for 5x1 LUT 0. Bit 0 = input 1, Bit 1 = input 2 and so on.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2745

<!-- page 2746 -->

41.11.199
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_0)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2090h offset = 21C_E090h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_0 field descriptions
Field
Description
31
LUTOUT31
LUT OUT
30
LUTOUT30
LUT OUT
29
LUTOUT29
LUT OUT
28
LUTOUT28
LUT OUT
27
LUTOUT27
LUT OUT
26
LUTOUT26
LUT OUT
25
LUTOUT25
LUT OUT
24
LUTOUT24
LUT OUT
23
LUTOUT23
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2746
NXP Semiconductors

<!-- page 2747 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_0 field descriptions (continued)
Field
Description
22
LUTOUT22
LUT OUT
21
LUTOUT21
LUT OUT
20
LUTOUT20
LUT OUT
19
LUTOUT19
LUT OUT
18
LUTOUT18
LUT OUT
17
LUTOUT17
LUT OUT
16
LUTOUT16
LUT OUT
15
LUTOUT15
LUT OUT
14
LUTOUT14
LUT OUT
13
LUTOUT13
LUT OUT
12
LUTOUT12
LUT OUT
11
LUTOUT11
LUT OUT
10
LUTOUT10
LUT OUT
9
LUTOUT9
LUT OUT
8
LUTOUT8
LUT OUT
7
LUTOUT7
LUT OUT
6
LUTOUT6
LUT OUT
5
LUTOUT5
LUT OUT
4
LUTOUT4
LUT OUT
3
LUTOUT3
LUT OUT
2
LUTOUT2
LUT OUT
1
LUTOUT1
LUT OUT
0
LUTOUT0
LUT OUT
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2747

<!-- page 2748 -->

41.11.200
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_1)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 20A0h offset = 21C_E0A0h
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
LUTOUT63
LUTOUT62
LUTOUT61
LUTOUT60
LUTOUT59
LUTOUT58
LUTOUT57
LUTOUT56
LUTOUT55
LUTOUT54
LUTOUT53
LUTOUT52
LUTOUT51
LUTOUT50
LUTOUT49
LUTOUT48
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
LUTOUT47
LUTOUT46
LUTOUT45
LUTOUT44
LUTOUT43
LUTOUT42
LUTOUT41
LUTOUT40
LUTOUT39
LUTOUT38
LUTOUT37
LUTOUT36
LUTOUT35
LUTOUT34
LUTOUT33
LUTOUT32
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
PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_1 field descriptions
Field
Description
31
LUTOUT63
LUT OUT
30
LUTOUT62
LUT OUT
29
LUTOUT61
LUT OUT
28
LUTOUT60
LUT OUT
27
LUTOUT59
LUT OUT
26
LUTOUT58
LUT OUT
25
LUTOUT57
LUT OUT
24
LUTOUT56
LUT OUT
23
LUTOUT55
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2748
NXP Semiconductors

<!-- page 2749 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_1 field descriptions (continued)
Field
Description
22
LUTOUT54
LUT OUT
21
LUTOUT53
LUT OUT
20
LUTOUT52
LUT OUT
19
LUTOUT51
LUT OUT
18
LUTOUT50
LUT OUT
17
LUTOUT49
LUT OUT
16
LUTOUT48
LUT OUT
15
LUTOUT47
LUT OUT
14
LUTOUT46
LUT OUT
13
LUTOUT45
LUT OUT
12
LUTOUT44
LUT OUT
11
LUTOUT43
LUT OUT
10
LUTOUT42
LUT OUT
9
LUTOUT41
LUT OUT
8
LUTOUT40
LUT OUT
7
LUTOUT39
LUT OUT
6
LUTOUT38
LUT OUT
5
LUTOUT37
LUT OUT
4
LUTOUT36
LUT OUT
3
LUTOUT35
LUT OUT
2
LUTOUT34
LUT OUT
1
LUTOUT33
LUT OUT
0
LUTOUT32
LUT OUT
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2749

<!-- page 2750 -->

41.11.201
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_2)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 20B0h offset = 21C_E0B0h
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
LUTOUT95
LUTOUT94
LUTOUT93
LUTOUT92
LUTOUT91
LUTOUT90
LUTOUT89
LUTOUT88
LUTOUT87
LUTOUT86
LUTOUT85
LUTOUT84
LUTOUT83
LUTOUT82
LUTOUT81
LUTOUT80
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
LUTOUT79
LUTOUT78
LUTOUT77
LUTOUT76
LUTOUT75
LUTOUT74
LUTOUT73
LUTOUT72
LUTOUT71
LUTOUT70
LUTOUT69
LUTOUT68
LUTOUT67
LUTOUT66
LUTOUT65
LUTOUT64
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
PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_2 field descriptions
Field
Description
31
LUTOUT95
LUT OUT
30
LUTOUT94
LUT OUT
29
LUTOUT93
LUT OUT
28
LUTOUT92
LUT OUT
27
LUTOUT91
LUT OUT
26
LUTOUT90
LUT OUT
25
LUTOUT89
LUT OUT
24
LUTOUT88
LUT OUT
23
LUTOUT87
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2750
NXP Semiconductors

<!-- page 2751 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_2 field descriptions (continued)
Field
Description
22
LUTOUT86
LUT OUT
21
LUTOUT85
LUT OUT
20
LUTOUT84
LUT OUT
19
LUTOUT83
LUT OUT
18
LUTOUT82
LUT OUT
17
LUTOUT81
LUT OUT
16
LUTOUT80
LUT OUT
15
LUTOUT79
LUT OUT
14
LUTOUT78
LUT OUT
13
LUTOUT77
LUT OUT
12
LUTOUT76
LUT OUT
11
LUTOUT75
LUT OUT
10
LUTOUT74
LUT OUT
9
LUTOUT73
LUT OUT
8
LUTOUT72
LUT OUT
7
LUTOUT71
LUT OUT
6
LUTOUT70
LUT OUT
5
LUTOUT69
LUT OUT
4
LUTOUT68
LUT OUT
3
LUTOUT67
LUT OUT
2
LUTOUT66
LUT OUT
1
LUTOUT65
LUT OUT
0
LUTOUT64
LUT OUT
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2751

<!-- page 2752 -->

41.11.202
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_3)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 20C0h offset = 21C_E0C0h
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
LUTOUT127
LUTOUT126
LUTOUT125
LUTOUT124
LUTOUT123
LUTOUT122
LUTOUT121
LUTOUT120
LUTOUT119
LUTOUT118
LUTOUT117
LUTOUT116
LUTOUT115
LUTOUT114
LUTOUT113
LUTOUT112
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
LUTOUT111
LUTOUT110
LUTOUT109
LUTOUT108
LUTOUT107
LUTOUT106
LUTOUT105
LUTOUT104
LUTOUT103
LUTOUT102
LUTOUT101
LUTOUT100
LUTOUT99
LUTOUT98
LUTOUT97
LUTOUT96
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
PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_3 field descriptions
Field
Description
31
LUTOUT127
LUT OUT
30
LUTOUT126
LUT OUT
29
LUTOUT125
LUT OUT
28
LUTOUT124
LUT OUT
27
LUTOUT123
LUT OUT
26
LUTOUT122
LUT OUT
25
LUTOUT121
LUT OUT
24
LUTOUT120
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2752
NXP Semiconductors

<!-- page 2753 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_3 field descriptions (continued)
Field
Description
23
LUTOUT119
LUT OUT
22
LUTOUT118
LUT OUT
21
LUTOUT117
LUT OUT
20
LUTOUT116
LUT OUT
19
LUTOUT115
LUT OUT
18
LUTOUT114
LUT OUT
17
LUTOUT113
LUT OUT
16
LUTOUT112
LUT OUT
15
LUTOUT111
LUT OUT
14
LUTOUT110
LUT OUT
13
LUTOUT109
LUT OUT
12
LUTOUT108
LUT OUT
11
LUTOUT107
LUT OUT
10
LUTOUT106
LUT OUT
9
LUTOUT105
LUT OUT
8
LUTOUT104
LUT OUT
7
LUTOUT103
LUT OUT
6
LUTOUT102
LUT OUT
5
LUTOUT101
LUT OUT
4
LUTOUT100
LUT OUT
3
LUTOUT99
LUT OUT
2
LUTOUT98
LUT OUT
1
LUTOUT97
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2753

<!-- page 2754 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_3 field descriptions (continued)
Field
Description
0
LUTOUT96
LUT OUT
41.11.203
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_4)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 20D0h offset = 21C_E0D0h
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
LUTOUT159
LUTOUT158
LUTOUT157
LUTOUT156
LUTOUT155
LUTOUT154
LUTOUT153
LUTOUT152
LUTOUT151
LUTOUT150
LUTOUT149
LUTOUT148
LUTOUT147
LUTOUT146
LUTOUT145
LUTOUT144
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
LUTOUT143
LUTOUT142
LUTOUT141
LUTOUT140
LUTOUT139
LUTOUT138
LUTOUT137
LUTOUT136
LUTOUT135
LUTOUT134
LUTOUT133
LUTOUT132
LUTOUT131
LUTOUT130
LUTOUT129
LUTOUT128
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
PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_4 field descriptions
Field
Description
31
LUTOUT159
LUT OUT
30
LUTOUT158
LUT OUT
29
LUTOUT157
LUT OUT
28
LUTOUT156
LUT OUT
27
LUTOUT155
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2754
NXP Semiconductors

<!-- page 2755 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_4 field descriptions (continued)
Field
Description
26
LUTOUT154
LUT OUT
25
LUTOUT153
LUT OUT
24
LUTOUT152
LUT OUT
23
LUTOUT151
LUT OUT
22
LUTOUT150
LUT OUT
21
LUTOUT149
LUT OUT
20
LUTOUT148
LUT OUT
19
LUTOUT147
LUT OUT
18
LUTOUT146
LUT OUT
17
LUTOUT145
LUT OUT
16
LUTOUT144
LUT OUT
15
LUTOUT143
LUT OUT
14
LUTOUT142
LUT OUT
13
LUTOUT141
LUT OUT
12
LUTOUT140
LUT OUT
11
LUTOUT139
LUT OUT
10
LUTOUT138
LUT OUT
9
LUTOUT137
LUT OUT
8
LUTOUT136
LUT OUT
7
LUTOUT135
LUT OUT
6
LUTOUT134
LUT OUT
5
LUTOUT133
LUT OUT
4
LUTOUT132
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2755

<!-- page 2756 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_4 field descriptions (continued)
Field
Description
3
LUTOUT131
LUT OUT
2
LUTOUT130
LUT OUT
1
LUTOUT129
LUT OUT
0
LUTOUT128
LUT OUT
41.11.204
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_5)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 20E0h offset = 21C_E0E0h
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
LUTOUT191
LUTOUT190
LUTOUT189
LUTOUT188
LUTOUT187
LUTOUT186
LUTOUT185
LUTOUT184
LUTOUT183
LUTOUT182
LUTOUT181
LUTOUT180
LUTOUT179
LUTOUT178
LUTOUT177
LUTOUT176
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
LUTOUT175
LUTOUT174
LUTOUT173
LUTOUT172
LUTOUT171
LUTOUT170
LUTOUT169
LUTOUT168
LUTOUT167
LUTOUT166
LUTOUT165
LUTOUT164
LUTOUT163
LUTOUT162
LUTOUT161
LUTOUT160
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
PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_5 field descriptions
Field
Description
31
LUTOUT191
LUT OUT
30
LUTOUT190
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2756
NXP Semiconductors

<!-- page 2757 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_5 field descriptions (continued)
Field
Description
29
LUTOUT189
LUT OUT
28
LUTOUT188
LUT OUT
27
LUTOUT187
LUT OUT
26
LUTOUT186
LUT OUT
25
LUTOUT185
LUT OUT
24
LUTOUT184
LUT OUT
23
LUTOUT183
LUT OUT
22
LUTOUT182
LUT OUT
21
LUTOUT181
LUT OUT
20
LUTOUT180
LUT OUT
19
LUTOUT179
LUT OUT
18
LUTOUT178
LUT OUT
17
LUTOUT177
LUT OUT
16
LUTOUT176
LUT OUT
15
LUTOUT175
LUT OUT
14
LUTOUT174
LUT OUT
13
LUTOUT173
LUT OUT
12
LUTOUT172
LUT OUT
11
LUTOUT171
LUT OUT
10
LUTOUT170
LUT OUT
9
LUTOUT169
LUT OUT
8
LUTOUT168
LUT OUT
7
LUTOUT167
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2757

<!-- page 2758 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_5 field descriptions (continued)
Field
Description
6
LUTOUT166
LUT OUT
5
LUTOUT165
LUT OUT
4
LUTOUT164
LUT OUT
3
LUTOUT163
LUT OUT
2
LUTOUT162
LUT OUT
1
LUTOUT161
LUT OUT
0
LUTOUT160
LUT OUT
41.11.205
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_6)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 20F0h offset = 21C_E0F0h
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
LUTOUT223
LUTOUT222
LUTOUT221
LUTOUT220
LUTOUT219
LUTOUT218
LUTOUT217
LUTOUT216
LUTOUT215
LUTOUT214
LUTOUT213
LUTOUT212
LUTOUT211
LUTOUT210
LUTOUT209
LUTOUT208
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
LUTOUT207
LUTOUT206
LUTOUT205
LUTOUT204
LUTOUT203
LUTOUT202
LUTOUT201
LUTOUT200
LUTOUT199
LUTOUT198
LUTOUT197
LUTOUT196
LUTOUT195
LUTOUT194
LUTOUT193
LUTOUT192
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2758
NXP Semiconductors

<!-- page 2759 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_6 field descriptions
Field
Description
31
LUTOUT223
LUT OUT
30
LUTOUT222
LUT OUT
29
LUTOUT221
LUT OUT
28
LUTOUT220
LUT OUT
27
LUTOUT219
LUT OUT
26
LUTOUT218
LUT OUT
25
LUTOUT217
LUT OUT
24
LUTOUT216
LUT OUT
23
LUTOUT215
LUT OUT
22
LUTOUT214
LUT OUT
21
LUTOUT213
LUT OUT
20
LUTOUT212
LUT OUT
19
LUTOUT211
LUT OUT
18
LUTOUT210
LUT OUT
17
LUTOUT209
LUT OUT
16
LUTOUT208
LUT OUT
15
LUTOUT207
LUT OUT
14
LUTOUT206
LUT OUT
13
LUTOUT205
LUT OUT
12
LUTOUT204
LUT OUT
11
LUTOUT203
LUT OUT
10
LUTOUT202
LUT OUT
9
LUTOUT201
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2759

<!-- page 2760 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_6 field descriptions (continued)
Field
Description
8
LUTOUT200
LUT OUT
7
LUTOUT199
LUT OUT
6
LUTOUT198
LUT OUT
5
LUTOUT197
LUT OUT
4
LUTOUT196
LUT OUT
3
LUTOUT195
LUT OUT
2
LUTOUT194
LUT OUT
1
LUTOUT193
LUT OUT
0
LUTOUT192
LUT OUT
41.11.206
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_7)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2100h offset = 21C_E100h
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
LUTOUT255
LUTOUT254
LUTOUT253
LUTOUT252
LUTOUT251
LUTOUT250
LUTOUT249
LUTOUT248
LUTOUT247
LUTOUT246
LUTOUT245
LUTOUT244
LUTOUT243
LUTOUT242
LUTOUT241
LUTOUT240
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
LUTOUT239
LUTOUT238
LUTOUT237
LUTOUT236
LUTOUT235
LUTOUT234
LUTOUT233
LUTOUT232
LUTOUT231
LUTOUT230
LUTOUT229
LUTOUT228
LUTOUT227
LUTOUT226
LUTOUT225
LUTOUT224
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2760
NXP Semiconductors

<!-- page 2761 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_7 field descriptions
Field
Description
31
LUTOUT255
LUT OUT
30
LUTOUT254
LUT OUT
29
LUTOUT253
LUT OUT
28
LUTOUT252
LUT OUT
27
LUTOUT251
LUT OUT
26
LUTOUT250
LUT OUT
25
LUTOUT249
LUT OUT
24
LUTOUT248
LUT OUT
23
LUTOUT247
LUT OUT
22
LUTOUT246
LUT OUT
21
LUTOUT245
LUT OUT
20
LUTOUT244
LUT OUT
19
LUTOUT243
LUT OUT
18
LUTOUT242
LUT OUT
17
LUTOUT241
LUT OUT
16
LUTOUT240
LUT OUT
15
LUTOUT239
LUT OUT
14
LUTOUT238
LUT OUT
13
LUTOUT237
LUT OUT
12
LUTOUT236
LUT OUT
11
LUTOUT235
LUT OUT
10
LUTOUT234
LUT OUT
9
LUTOUT233
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2761

<!-- page 2762 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT0_7 field descriptions (continued)
Field
Description
8
LUTOUT232
LUT OUT
7
LUTOUT231
LUT OUT
6
LUTOUT230
LUT OUT
5
LUTOUT229
LUT OUT
4
LUTOUT228
LUT OUT
3
LUTOUT227
LUT OUT
2
LUTOUT226
LUT OUT
1
LUTOUT225
LUT OUT
0
LUTOUT224
LUT OUT
41.11.207
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_0)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2110h offset = 21C_E110h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2762
NXP Semiconductors

<!-- page 2763 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_0 field descriptions
Field
Description
31
LUTOUT31
LUT OUT
30
LUTOUT30
LUT OUT
29
LUTOUT29
LUT OUT
28
LUTOUT28
LUT OUT
27
LUTOUT27
LUT OUT
26
LUTOUT26
LUT OUT
25
LUTOUT25
LUT OUT
24
LUTOUT24
LUT OUT
23
LUTOUT23
LUT OUT
22
LUTOUT22
LUT OUT
21
LUTOUT21
LUT OUT
20
LUTOUT20
LUT OUT
19
LUTOUT19
LUT OUT
18
LUTOUT18
LUT OUT
17
LUTOUT17
LUT OUT
16
LUTOUT16
LUT OUT
15
LUTOUT15
LUT OUT
14
LUTOUT14
LUT OUT
13
LUTOUT13
LUT OUT
12
LUTOUT12
LUT OUT
11
LUTOUT11
LUT OUT
10
LUTOUT10
LUT OUT
9
LUTOUT9
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2763

<!-- page 2764 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_0 field descriptions (continued)
Field
Description
8
LUTOUT8
LUT OUT
7
LUTOUT7
LUT OUT
6
LUTOUT6
LUT OUT
5
LUTOUT5
LUT OUT
4
LUTOUT4
LUT OUT
3
LUTOUT3
LUT OUT
2
LUTOUT2
LUT OUT
1
LUTOUT1
LUT OUT
0
LUTOUT0
LUT OUT
41.11.208
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_1)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2120h offset = 21C_E120h
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
LUTOUT63
LUTOUT62
LUTOUT61
LUTOUT60
LUTOUT59
LUTOUT58
LUTOUT57
LUTOUT56
LUTOUT55
LUTOUT54
LUTOUT53
LUTOUT52
LUTOUT51
LUTOUT50
LUTOUT49
LUTOUT48
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
LUTOUT47
LUTOUT46
LUTOUT45
LUTOUT44
LUTOUT43
LUTOUT42
LUTOUT41
LUTOUT40
LUTOUT39
LUTOUT38
LUTOUT37
LUTOUT36
LUTOUT35
LUTOUT34
LUTOUT33
LUTOUT32
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2764
NXP Semiconductors

<!-- page 2765 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_1 field descriptions
Field
Description
31
LUTOUT63
LUT OUT
30
LUTOUT62
LUT OUT
29
LUTOUT61
LUT OUT
28
LUTOUT60
LUT OUT
27
LUTOUT59
LUT OUT
26
LUTOUT58
LUT OUT
25
LUTOUT57
LUT OUT
24
LUTOUT56
LUT OUT
23
LUTOUT55
LUT OUT
22
LUTOUT54
LUT OUT
21
LUTOUT53
LUT OUT
20
LUTOUT52
LUT OUT
19
LUTOUT51
LUT OUT
18
LUTOUT50
LUT OUT
17
LUTOUT49
LUT OUT
16
LUTOUT48
LUT OUT
15
LUTOUT47
LUT OUT
14
LUTOUT46
LUT OUT
13
LUTOUT45
LUT OUT
12
LUTOUT44
LUT OUT
11
LUTOUT43
LUT OUT
10
LUTOUT42
LUT OUT
9
LUTOUT41
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2765

<!-- page 2766 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_1 field descriptions (continued)
Field
Description
8
LUTOUT40
LUT OUT
7
LUTOUT39
LUT OUT
6
LUTOUT38
LUT OUT
5
LUTOUT37
LUT OUT
4
LUTOUT36
LUT OUT
3
LUTOUT35
LUT OUT
2
LUTOUT34
LUT OUT
1
LUTOUT33
LUT OUT
0
LUTOUT32
LUT OUT
41.11.209
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_2)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2130h offset = 21C_E130h
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
LUTOUT95
LUTOUT94
LUTOUT93
LUTOUT92
LUTOUT91
LUTOUT90
LUTOUT89
LUTOUT88
LUTOUT87
LUTOUT86
LUTOUT85
LUTOUT84
LUTOUT83
LUTOUT82
LUTOUT81
LUTOUT80
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
LUTOUT79
LUTOUT78
LUTOUT77
LUTOUT76
LUTOUT75
LUTOUT74
LUTOUT73
LUTOUT72
LUTOUT71
LUTOUT70
LUTOUT69
LUTOUT68
LUTOUT67
LUTOUT66
LUTOUT65
LUTOUT64
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2766
NXP Semiconductors

<!-- page 2767 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_2 field descriptions
Field
Description
31
LUTOUT95
LUT OUT
30
LUTOUT94
LUT OUT
29
LUTOUT93
LUT OUT
28
LUTOUT92
LUT OUT
27
LUTOUT91
LUT OUT
26
LUTOUT90
LUT OUT
25
LUTOUT89
LUT OUT
24
LUTOUT88
LUT OUT
23
LUTOUT87
LUT OUT
22
LUTOUT86
LUT OUT
21
LUTOUT85
LUT OUT
20
LUTOUT84
LUT OUT
19
LUTOUT83
LUT OUT
18
LUTOUT82
LUT OUT
17
LUTOUT81
LUT OUT
16
LUTOUT80
LUT OUT
15
LUTOUT79
LUT OUT
14
LUTOUT78
LUT OUT
13
LUTOUT77
LUT OUT
12
LUTOUT76
LUT OUT
11
LUTOUT75
LUT OUT
10
LUTOUT74
LUT OUT
9
LUTOUT73
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2767

<!-- page 2768 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_2 field descriptions (continued)
Field
Description
8
LUTOUT72
LUT OUT
7
LUTOUT71
LUT OUT
6
LUTOUT70
LUT OUT
5
LUTOUT69
LUT OUT
4
LUTOUT68
LUT OUT
3
LUTOUT67
LUT OUT
2
LUTOUT66
LUT OUT
1
LUTOUT65
LUT OUT
0
LUTOUT64
LUT OUT
41.11.210
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_3)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2140h offset = 21C_E140h
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
LUTOUT127
LUTOUT126
LUTOUT125
LUTOUT124
LUTOUT123
LUTOUT122
LUTOUT121
LUTOUT120
LUTOUT119
LUTOUT118
LUTOUT117
LUTOUT116
LUTOUT115
LUTOUT114
LUTOUT113
LUTOUT112
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
LUTOUT111
LUTOUT110
LUTOUT109
LUTOUT108
LUTOUT107
LUTOUT106
LUTOUT105
LUTOUT104
LUTOUT103
LUTOUT102
LUTOUT101
LUTOUT100
LUTOUT99
LUTOUT98
LUTOUT97
LUTOUT96
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2768
NXP Semiconductors

<!-- page 2769 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_3 field descriptions
Field
Description
31
LUTOUT127
LUT OUT
30
LUTOUT126
LUT OUT
29
LUTOUT125
LUT OUT
28
LUTOUT124
LUT OUT
27
LUTOUT123
LUT OUT
26
LUTOUT122
LUT OUT
25
LUTOUT121
LUT OUT
24
LUTOUT120
LUT OUT
23
LUTOUT119
LUT OUT
22
LUTOUT118
LUT OUT
21
LUTOUT117
LUT OUT
20
LUTOUT116
LUT OUT
19
LUTOUT115
LUT OUT
18
LUTOUT114
LUT OUT
17
LUTOUT113
LUT OUT
16
LUTOUT112
LUT OUT
15
LUTOUT111
LUT OUT
14
LUTOUT110
LUT OUT
13
LUTOUT109
LUT OUT
12
LUTOUT108
LUT OUT
11
LUTOUT107
LUT OUT
10
LUTOUT106
LUT OUT
9
LUTOUT105
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2769

<!-- page 2770 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_3 field descriptions (continued)
Field
Description
8
LUTOUT104
LUT OUT
7
LUTOUT103
LUT OUT
6
LUTOUT102
LUT OUT
5
LUTOUT101
LUT OUT
4
LUTOUT100
LUT OUT
3
LUTOUT99
LUT OUT
2
LUTOUT98
LUT OUT
1
LUTOUT97
LUT OUT
0
LUTOUT96
LUT OUT
41.11.211
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_4)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2150h offset = 21C_E150h
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
LUTOUT159
LUTOUT158
LUTOUT157
LUTOUT156
LUTOUT155
LUTOUT154
LUTOUT153
LUTOUT152
LUTOUT151
LUTOUT150
LUTOUT149
LUTOUT148
LUTOUT147
LUTOUT146
LUTOUT145
LUTOUT144
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
LUTOUT143
LUTOUT142
LUTOUT141
LUTOUT140
LUTOUT139
LUTOUT138
LUTOUT137
LUTOUT136
LUTOUT135
LUTOUT134
LUTOUT133
LUTOUT132
LUTOUT131
LUTOUT130
LUTOUT129
LUTOUT128
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2770
NXP Semiconductors

<!-- page 2771 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_4 field descriptions
Field
Description
31
LUTOUT159
LUT OUT
30
LUTOUT158
LUT OUT
29
LUTOUT157
LUT OUT
28
LUTOUT156
LUT OUT
27
LUTOUT155
LUT OUT
26
LUTOUT154
LUT OUT
25
LUTOUT153
LUT OUT
24
LUTOUT152
LUT OUT
23
LUTOUT151
LUT OUT
22
LUTOUT150
LUT OUT
21
LUTOUT149
LUT OUT
20
LUTOUT148
LUT OUT
19
LUTOUT147
LUT OUT
18
LUTOUT146
LUT OUT
17
LUTOUT145
LUT OUT
16
LUTOUT144
LUT OUT
15
LUTOUT143
LUT OUT
14
LUTOUT142
LUT OUT
13
LUTOUT141
LUT OUT
12
LUTOUT140
LUT OUT
11
LUTOUT139
LUT OUT
10
LUTOUT138
LUT OUT
9
LUTOUT137
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2771

<!-- page 2772 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_4 field descriptions (continued)
Field
Description
8
LUTOUT136
LUT OUT
7
LUTOUT135
LUT OUT
6
LUTOUT134
LUT OUT
5
LUTOUT133
LUT OUT
4
LUTOUT132
LUT OUT
3
LUTOUT131
LUT OUT
2
LUTOUT130
LUT OUT
1
LUTOUT129
LUT OUT
0
LUTOUT128
LUT OUT
41.11.212
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_5)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2160h offset = 21C_E160h
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
LUTOUT191
LUTOUT190
LUTOUT189
LUTOUT188
LUTOUT187
LUTOUT186
LUTOUT185
LUTOUT184
LUTOUT183
LUTOUT182
LUTOUT181
LUTOUT180
LUTOUT179
LUTOUT178
LUTOUT177
LUTOUT176
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
LUTOUT175
LUTOUT174
LUTOUT173
LUTOUT172
LUTOUT171
LUTOUT170
LUTOUT169
LUTOUT168
LUTOUT167
LUTOUT166
LUTOUT165
LUTOUT164
LUTOUT163
LUTOUT162
LUTOUT161
LUTOUT160
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2772
NXP Semiconductors

<!-- page 2773 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_5 field descriptions
Field
Description
31
LUTOUT191
LUT OUT
30
LUTOUT190
LUT OUT
29
LUTOUT189
LUT OUT
28
LUTOUT188
LUT OUT
27
LUTOUT187
LUT OUT
26
LUTOUT186
LUT OUT
25
LUTOUT185
LUT OUT
24
LUTOUT184
LUT OUT
23
LUTOUT183
LUT OUT
22
LUTOUT182
LUT OUT
21
LUTOUT181
LUT OUT
20
LUTOUT180
LUT OUT
19
LUTOUT179
LUT OUT
18
LUTOUT178
LUT OUT
17
LUTOUT177
LUT OUT
16
LUTOUT176
LUT OUT
15
LUTOUT175
LUT OUT
14
LUTOUT174
LUT OUT
13
LUTOUT173
LUT OUT
12
LUTOUT172
LUT OUT
11
LUTOUT171
LUT OUT
10
LUTOUT170
LUT OUT
9
LUTOUT169
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2773

<!-- page 2774 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_5 field descriptions (continued)
Field
Description
8
LUTOUT168
LUT OUT
7
LUTOUT167
LUT OUT
6
LUTOUT166
LUT OUT
5
LUTOUT165
LUT OUT
4
LUTOUT164
LUT OUT
3
LUTOUT163
LUT OUT
2
LUTOUT162
LUT OUT
1
LUTOUT161
LUT OUT
0
LUTOUT160
LUT OUT
41.11.213
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_6)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2170h offset = 21C_E170h
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
LUTOUT223
LUTOUT222
LUTOUT221
LUTOUT220
LUTOUT219
LUTOUT218
LUTOUT217
LUTOUT216
LUTOUT215
LUTOUT214
LUTOUT213
LUTOUT212
LUTOUT211
LUTOUT210
LUTOUT209
LUTOUT208
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
LUTOUT207
LUTOUT206
LUTOUT205
LUTOUT204
LUTOUT203
LUTOUT202
LUTOUT201
LUTOUT200
LUTOUT199
LUTOUT198
LUTOUT197
LUTOUT196
LUTOUT195
LUTOUT194
LUTOUT193
LUTOUT192
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2774
NXP Semiconductors

<!-- page 2775 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_6 field descriptions
Field
Description
31
LUTOUT223
LUT OUT
30
LUTOUT222
LUT OUT
29
LUTOUT221
LUT OUT
28
LUTOUT220
LUT OUT
27
LUTOUT219
LUT OUT
26
LUTOUT218
LUT OUT
25
LUTOUT217
LUT OUT
24
LUTOUT216
LUT OUT
23
LUTOUT215
LUT OUT
22
LUTOUT214
LUT OUT
21
LUTOUT213
LUT OUT
20
LUTOUT212
LUT OUT
19
LUTOUT211
LUT OUT
18
LUTOUT210
LUT OUT
17
LUTOUT209
LUT OUT
16
LUTOUT208
LUT OUT
15
LUTOUT207
LUT OUT
14
LUTOUT206
LUT OUT
13
LUTOUT205
LUT OUT
12
LUTOUT204
LUT OUT
11
LUTOUT203
LUT OUT
10
LUTOUT202
LUT OUT
9
LUTOUT201
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2775

<!-- page 2776 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_6 field descriptions (continued)
Field
Description
8
LUTOUT200
LUT OUT
7
LUTOUT199
LUT OUT
6
LUTOUT198
LUT OUT
5
LUTOUT197
LUT OUT
4
LUTOUT196
LUT OUT
3
LUTOUT195
LUT OUT
2
LUTOUT194
LUT OUT
1
LUTOUT193
LUT OUT
0
LUTOUT192
LUT OUT
41.11.214
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_7)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2180h offset = 21C_E180h
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
LUTOUT255
LUTOUT254
LUTOUT253
LUTOUT252
LUTOUT251
LUTOUT250
LUTOUT249
LUTOUT248
LUTOUT247
LUTOUT246
LUTOUT245
LUTOUT244
LUTOUT243
LUTOUT242
LUTOUT241
LUTOUT240
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
LUTOUT239
LUTOUT238
LUTOUT237
LUTOUT236
LUTOUT235
LUTOUT234
LUTOUT233
LUTOUT232
LUTOUT231
LUTOUT230
LUTOUT229
LUTOUT228
LUTOUT227
LUTOUT226
LUTOUT225
LUTOUT224
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2776
NXP Semiconductors

<!-- page 2777 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_7 field descriptions
Field
Description
31
LUTOUT255
LUT OUT
30
LUTOUT254
LUT OUT
29
LUTOUT253
LUT OUT
28
LUTOUT252
LUT OUT
27
LUTOUT251
LUT OUT
26
LUTOUT250
LUT OUT
25
LUTOUT249
LUT OUT
24
LUTOUT248
LUT OUT
23
LUTOUT247
LUT OUT
22
LUTOUT246
LUT OUT
21
LUTOUT245
LUT OUT
20
LUTOUT244
LUT OUT
19
LUTOUT243
LUT OUT
18
LUTOUT242
LUT OUT
17
LUTOUT241
LUT OUT
16
LUTOUT240
LUT OUT
15
LUTOUT239
LUT OUT
14
LUTOUT238
LUT OUT
13
LUTOUT237
LUT OUT
12
LUTOUT236
LUT OUT
11
LUTOUT235
LUT OUT
10
LUTOUT234
LUT OUT
9
LUTOUT233
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2777

<!-- page 2778 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT1_7 field descriptions (continued)
Field
Description
8
LUTOUT232
LUT OUT
7
LUTOUT231
LUT OUT
6
LUTOUT230
LUT OUT
5
LUTOUT229
LUT OUT
4
LUTOUT228
LUT OUT
3
LUTOUT227
LUT OUT
2
LUTOUT226
LUT OUT
1
LUTOUT225
LUT OUT
0
LUTOUT224
LUT OUT
41.11.215
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_0)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2190h offset = 21C_E190h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2778
NXP Semiconductors

<!-- page 2779 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_0 field descriptions
Field
Description
31
LUTOUT31
LUT OUT
30
LUTOUT30
LUT OUT
29
LUTOUT29
LUT OUT
28
LUTOUT28
LUT OUT
27
LUTOUT27
LUT OUT
26
LUTOUT26
LUT OUT
25
LUTOUT25
LUT OUT
24
LUTOUT24
LUT OUT
23
LUTOUT23
LUT OUT
22
LUTOUT22
LUT OUT
21
LUTOUT21
LUT OUT
20
LUTOUT20
LUT OUT
19
LUTOUT19
LUT OUT
18
LUTOUT18
LUT OUT
17
LUTOUT17
LUT OUT
16
LUTOUT16
LUT OUT
15
LUTOUT15
LUT OUT
14
LUTOUT14
LUT OUT
13
LUTOUT13
LUT OUT
12
LUTOUT12
LUT OUT
11
LUTOUT11
LUT OUT
10
LUTOUT10
LUT OUT
9
LUTOUT9
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2779

<!-- page 2780 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_0 field descriptions (continued)
Field
Description
8
LUTOUT8
LUT OUT
7
LUTOUT7
LUT OUT
6
LUTOUT6
LUT OUT
5
LUTOUT5
LUT OUT
4
LUTOUT4
LUT OUT
3
LUTOUT3
LUT OUT
2
LUTOUT2
LUT OUT
1
LUTOUT1
LUT OUT
0
LUTOUT0
LUT OUT
41.11.216
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_1)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 21A0h offset = 21C_E1A0h
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
LUTOUT63
LUTOUT62
LUTOUT61
LUTOUT60
LUTOUT59
LUTOUT58
LUTOUT57
LUTOUT56
LUTOUT55
LUTOUT54
LUTOUT53
LUTOUT52
LUTOUT51
LUTOUT50
LUTOUT49
LUTOUT48
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
LUTOUT47
LUTOUT46
LUTOUT45
LUTOUT44
LUTOUT43
LUTOUT42
LUTOUT41
LUTOUT40
LUTOUT39
LUTOUT38
LUTOUT37
LUTOUT36
LUTOUT35
LUTOUT34
LUTOUT33
LUTOUT32
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2780
NXP Semiconductors

<!-- page 2781 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_1 field descriptions
Field
Description
31
LUTOUT63
LUT OUT
30
LUTOUT62
LUT OUT
29
LUTOUT61
LUT OUT
28
LUTOUT60
LUT OUT
27
LUTOUT59
LUT OUT
26
LUTOUT58
LUT OUT
25
LUTOUT57
LUT OUT
24
LUTOUT56
LUT OUT
23
LUTOUT55
LUT OUT
22
LUTOUT54
LUT OUT
21
LUTOUT53
LUT OUT
20
LUTOUT52
LUT OUT
19
LUTOUT51
LUT OUT
18
LUTOUT50
LUT OUT
17
LUTOUT49
LUT OUT
16
LUTOUT48
LUT OUT
15
LUTOUT47
LUT OUT
14
LUTOUT46
LUT OUT
13
LUTOUT45
LUT OUT
12
LUTOUT44
LUT OUT
11
LUTOUT43
LUT OUT
10
LUTOUT42
LUT OUT
9
LUTOUT41
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2781

<!-- page 2782 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_1 field descriptions (continued)
Field
Description
8
LUTOUT40
LUT OUT
7
LUTOUT39
LUT OUT
6
LUTOUT38
LUT OUT
5
LUTOUT37
LUT OUT
4
LUTOUT36
LUT OUT
3
LUTOUT35
LUT OUT
2
LUTOUT34
LUT OUT
1
LUTOUT33
LUT OUT
0
LUTOUT32
LUT OUT
41.11.217
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_2)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 21B0h offset = 21C_E1B0h
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
LUTOUT95
LUTOUT94
LUTOUT93
LUTOUT92
LUTOUT91
LUTOUT90
LUTOUT89
LUTOUT88
LUTOUT87
LUTOUT86
LUTOUT85
LUTOUT84
LUTOUT83
LUTOUT82
LUTOUT81
LUTOUT80
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
LUTOUT79
LUTOUT78
LUTOUT77
LUTOUT76
LUTOUT75
LUTOUT74
LUTOUT73
LUTOUT72
LUTOUT71
LUTOUT70
LUTOUT69
LUTOUT68
LUTOUT67
LUTOUT66
LUTOUT65
LUTOUT64
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2782
NXP Semiconductors

<!-- page 2783 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_2 field descriptions
Field
Description
31
LUTOUT95
LUT OUT
30
LUTOUT94
LUT OUT
29
LUTOUT93
LUT OUT
28
LUTOUT92
LUT OUT
27
LUTOUT91
LUT OUT
26
LUTOUT90
LUT OUT
25
LUTOUT89
LUT OUT
24
LUTOUT88
LUT OUT
23
LUTOUT87
LUT OUT
22
LUTOUT86
LUT OUT
21
LUTOUT85
LUT OUT
20
LUTOUT84
LUT OUT
19
LUTOUT83
LUT OUT
18
LUTOUT82
LUT OUT
17
LUTOUT81
LUT OUT
16
LUTOUT80
LUT OUT
15
LUTOUT79
LUT OUT
14
LUTOUT78
LUT OUT
13
LUTOUT77
LUT OUT
12
LUTOUT76
LUT OUT
11
LUTOUT75
LUT OUT
10
LUTOUT74
LUT OUT
9
LUTOUT73
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2783

<!-- page 2784 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_2 field descriptions (continued)
Field
Description
8
LUTOUT72
LUT OUT
7
LUTOUT71
LUT OUT
6
LUTOUT70
LUT OUT
5
LUTOUT69
LUT OUT
4
LUTOUT68
LUT OUT
3
LUTOUT67
LUT OUT
2
LUTOUT66
LUT OUT
1
LUTOUT65
LUT OUT
0
LUTOUT64
LUT OUT
41.11.218
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_3)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 21C0h offset = 21C_E1C0h
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
LUTOUT127
LUTOUT126
LUTOUT125
LUTOUT124
LUTOUT123
LUTOUT122
LUTOUT121
LUTOUT120
LUTOUT119
LUTOUT118
LUTOUT117
LUTOUT116
LUTOUT115
LUTOUT114
LUTOUT113
LUTOUT112
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
LUTOUT111
LUTOUT110
LUTOUT109
LUTOUT108
LUTOUT107
LUTOUT106
LUTOUT105
LUTOUT104
LUTOUT103
LUTOUT102
LUTOUT101
LUTOUT100
LUTOUT99
LUTOUT98
LUTOUT97
LUTOUT96
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2784
NXP Semiconductors

<!-- page 2785 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_3 field descriptions
Field
Description
31
LUTOUT127
LUT OUT
30
LUTOUT126
LUT OUT
29
LUTOUT125
LUT OUT
28
LUTOUT124
LUT OUT
27
LUTOUT123
LUT OUT
26
LUTOUT122
LUT OUT
25
LUTOUT121
LUT OUT
24
LUTOUT120
LUT OUT
23
LUTOUT119
LUT OUT
22
LUTOUT118
LUT OUT
21
LUTOUT117
LUT OUT
20
LUTOUT116
LUT OUT
19
LUTOUT115
LUT OUT
18
LUTOUT114
LUT OUT
17
LUTOUT113
LUT OUT
16
LUTOUT112
LUT OUT
15
LUTOUT111
LUT OUT
14
LUTOUT110
LUT OUT
13
LUTOUT109
LUT OUT
12
LUTOUT108
LUT OUT
11
LUTOUT107
LUT OUT
10
LUTOUT106
LUT OUT
9
LUTOUT105
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2785

<!-- page 2786 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_3 field descriptions (continued)
Field
Description
8
LUTOUT104
LUT OUT
7
LUTOUT103
LUT OUT
6
LUTOUT102
LUT OUT
5
LUTOUT101
LUT OUT
4
LUTOUT100
LUT OUT
3
LUTOUT99
LUT OUT
2
LUTOUT98
LUT OUT
1
LUTOUT97
LUT OUT
0
LUTOUT96
LUT OUT
41.11.219
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_4)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 21D0h offset = 21C_E1D0h
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
LUTOUT159
LUTOUT158
LUTOUT157
LUTOUT156
LUTOUT155
LUTOUT154
LUTOUT153
LUTOUT152
LUTOUT151
LUTOUT150
LUTOUT149
LUTOUT148
LUTOUT147
LUTOUT146
LUTOUT145
LUTOUT144
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
LUTOUT143
LUTOUT142
LUTOUT141
LUTOUT140
LUTOUT139
LUTOUT138
LUTOUT137
LUTOUT136
LUTOUT135
LUTOUT134
LUTOUT133
LUTOUT132
LUTOUT131
LUTOUT130
LUTOUT129
LUTOUT128
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2786
NXP Semiconductors

<!-- page 2787 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_4 field descriptions
Field
Description
31
LUTOUT159
LUT OUT
30
LUTOUT158
LUT OUT
29
LUTOUT157
LUT OUT
28
LUTOUT156
LUT OUT
27
LUTOUT155
LUT OUT
26
LUTOUT154
LUT OUT
25
LUTOUT153
LUT OUT
24
LUTOUT152
LUT OUT
23
LUTOUT151
LUT OUT
22
LUTOUT150
LUT OUT
21
LUTOUT149
LUT OUT
20
LUTOUT148
LUT OUT
19
LUTOUT147
LUT OUT
18
LUTOUT146
LUT OUT
17
LUTOUT145
LUT OUT
16
LUTOUT144
LUT OUT
15
LUTOUT143
LUT OUT
14
LUTOUT142
LUT OUT
13
LUTOUT141
LUT OUT
12
LUTOUT140
LUT OUT
11
LUTOUT139
LUT OUT
10
LUTOUT138
LUT OUT
9
LUTOUT137
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2787

<!-- page 2788 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_4 field descriptions (continued)
Field
Description
8
LUTOUT136
LUT OUT
7
LUTOUT135
LUT OUT
6
LUTOUT134
LUT OUT
5
LUTOUT133
LUT OUT
4
LUTOUT132
LUT OUT
3
LUTOUT131
LUT OUT
2
LUTOUT130
LUT OUT
1
LUTOUT129
LUT OUT
0
LUTOUT128
LUT OUT
41.11.220
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_5)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 21E0h offset = 21C_E1E0h
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
LUTOUT191
LUTOUT190
LUTOUT189
LUTOUT188
LUTOUT187
LUTOUT186
LUTOUT185
LUTOUT184
LUTOUT183
LUTOUT182
LUTOUT181
LUTOUT180
LUTOUT179
LUTOUT178
LUTOUT177
LUTOUT176
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
LUTOUT175
LUTOUT174
LUTOUT173
LUTOUT172
LUTOUT171
LUTOUT170
LUTOUT169
LUTOUT168
LUTOUT167
LUTOUT166
LUTOUT165
LUTOUT164
LUTOUT163
LUTOUT162
LUTOUT161
LUTOUT160
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2788
NXP Semiconductors

<!-- page 2789 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_5 field descriptions
Field
Description
31
LUTOUT191
LUT OUT
30
LUTOUT190
LUT OUT
29
LUTOUT189
LUT OUT
28
LUTOUT188
LUT OUT
27
LUTOUT187
LUT OUT
26
LUTOUT186
LUT OUT
25
LUTOUT185
LUT OUT
24
LUTOUT184
LUT OUT
23
LUTOUT183
LUT OUT
22
LUTOUT182
LUT OUT
21
LUTOUT181
LUT OUT
20
LUTOUT180
LUT OUT
19
LUTOUT179
LUT OUT
18
LUTOUT178
LUT OUT
17
LUTOUT177
LUT OUT
16
LUTOUT176
LUT OUT
15
LUTOUT175
LUT OUT
14
LUTOUT174
LUT OUT
13
LUTOUT173
LUT OUT
12
LUTOUT172
LUT OUT
11
LUTOUT171
LUT OUT
10
LUTOUT170
LUT OUT
9
LUTOUT169
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2789

<!-- page 2790 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_5 field descriptions (continued)
Field
Description
8
LUTOUT168
LUT OUT
7
LUTOUT167
LUT OUT
6
LUTOUT166
LUT OUT
5
LUTOUT165
LUT OUT
4
LUTOUT164
LUT OUT
3
LUTOUT163
LUT OUT
2
LUTOUT162
LUT OUT
1
LUTOUT161
LUT OUT
0
LUTOUT160
LUT OUT
41.11.221
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_6)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 21F0h offset = 21C_E1F0h
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
LUTOUT223
LUTOUT222
LUTOUT221
LUTOUT220
LUTOUT219
LUTOUT218
LUTOUT217
LUTOUT216
LUTOUT215
LUTOUT214
LUTOUT213
LUTOUT212
LUTOUT211
LUTOUT210
LUTOUT209
LUTOUT208
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
LUTOUT207
LUTOUT206
LUTOUT205
LUTOUT204
LUTOUT203
LUTOUT202
LUTOUT201
LUTOUT200
LUTOUT199
LUTOUT198
LUTOUT197
LUTOUT196
LUTOUT195
LUTOUT194
LUTOUT193
LUTOUT192
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2790
NXP Semiconductors

<!-- page 2791 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_6 field descriptions
Field
Description
31
LUTOUT223
LUT OUT
30
LUTOUT222
LUT OUT
29
LUTOUT221
LUT OUT
28
LUTOUT220
LUT OUT
27
LUTOUT219
LUT OUT
26
LUTOUT218
LUT OUT
25
LUTOUT217
LUT OUT
24
LUTOUT216
LUT OUT
23
LUTOUT215
LUT OUT
22
LUTOUT214
LUT OUT
21
LUTOUT213
LUT OUT
20
LUTOUT212
LUT OUT
19
LUTOUT211
LUT OUT
18
LUTOUT210
LUT OUT
17
LUTOUT209
LUT OUT
16
LUTOUT208
LUT OUT
15
LUTOUT207
LUT OUT
14
LUTOUT206
LUT OUT
13
LUTOUT205
LUT OUT
12
LUTOUT204
LUT OUT
11
LUTOUT203
LUT OUT
10
LUTOUT202
LUT OUT
9
LUTOUT201
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2791

<!-- page 2792 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_6 field descriptions (continued)
Field
Description
8
LUTOUT200
LUT OUT
7
LUTOUT199
LUT OUT
6
LUTOUT198
LUT OUT
5
LUTOUT197
LUT OUT
4
LUTOUT196
LUT OUT
3
LUTOUT195
LUT OUT
2
LUTOUT194
LUT OUT
1
LUTOUT193
LUT OUT
0
LUTOUT192
LUT OUT
41.11.222
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_7)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2200h offset = 21C_E200h
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
LUTOUT255
LUTOUT254
LUTOUT253
LUTOUT252
LUTOUT251
LUTOUT250
LUTOUT249
LUTOUT248
LUTOUT247
LUTOUT246
LUTOUT245
LUTOUT244
LUTOUT243
LUTOUT242
LUTOUT241
LUTOUT240
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
LUTOUT239
LUTOUT238
LUTOUT237
LUTOUT236
LUTOUT235
LUTOUT234
LUTOUT233
LUTOUT232
LUTOUT231
LUTOUT230
LUTOUT229
LUTOUT228
LUTOUT227
LUTOUT226
LUTOUT225
LUTOUT224
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2792
NXP Semiconductors

<!-- page 2793 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_7 field descriptions
Field
Description
31
LUTOUT255
LUT OUT
30
LUTOUT254
LUT OUT
29
LUTOUT253
LUT OUT
28
LUTOUT252
LUT OUT
27
LUTOUT251
LUT OUT
26
LUTOUT250
LUT OUT
25
LUTOUT249
LUT OUT
24
LUTOUT248
LUT OUT
23
LUTOUT247
LUT OUT
22
LUTOUT246
LUT OUT
21
LUTOUT245
LUT OUT
20
LUTOUT244
LUT OUT
19
LUTOUT243
LUT OUT
18
LUTOUT242
LUT OUT
17
LUTOUT241
LUT OUT
16
LUTOUT240
LUT OUT
15
LUTOUT239
LUT OUT
14
LUTOUT238
LUT OUT
13
LUTOUT237
LUT OUT
12
LUTOUT236
LUT OUT
11
LUTOUT235
LUT OUT
10
LUTOUT234
LUT OUT
9
LUTOUT233
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2793

<!-- page 2794 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT2_7 field descriptions (continued)
Field
Description
8
LUTOUT232
LUT OUT
7
LUTOUT231
LUT OUT
6
LUTOUT230
LUT OUT
5
LUTOUT229
LUT OUT
4
LUTOUT228
LUT OUT
3
LUTOUT227
LUT OUT
2
LUTOUT226
LUT OUT
1
LUTOUT225
LUT OUT
0
LUTOUT224
LUT OUT
41.11.223
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_0)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2210h offset = 21C_E210h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2794
NXP Semiconductors

<!-- page 2795 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_0 field descriptions
Field
Description
31
LUTOUT31
LUT OUT
30
LUTOUT30
LUT OUT
29
LUTOUT29
LUT OUT
28
LUTOUT28
LUT OUT
27
LUTOUT27
LUT OUT
26
LUTOUT26
LUT OUT
25
LUTOUT25
LUT OUT
24
LUTOUT24
LUT OUT
23
LUTOUT23
LUT OUT
22
LUTOUT22
LUT OUT
21
LUTOUT21
LUT OUT
20
LUTOUT20
LUT OUT
19
LUTOUT19
LUT OUT
18
LUTOUT18
LUT OUT
17
LUTOUT17
LUT OUT
16
LUTOUT16
LUT OUT
15
LUTOUT15
LUT OUT
14
LUTOUT14
LUT OUT
13
LUTOUT13
LUT OUT
12
LUTOUT12
LUT OUT
11
LUTOUT11
LUT OUT
10
LUTOUT10
LUT OUT
9
LUTOUT9
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2795

<!-- page 2796 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_0 field descriptions (continued)
Field
Description
8
LUTOUT8
LUT OUT
7
LUTOUT7
LUT OUT
6
LUTOUT6
LUT OUT
5
LUTOUT5
LUT OUT
4
LUTOUT4
LUT OUT
3
LUTOUT3
LUT OUT
2
LUTOUT2
LUT OUT
1
LUTOUT1
LUT OUT
0
LUTOUT0
LUT OUT
41.11.224
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_1)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2220h offset = 21C_E220h
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
LUTOUT63
LUTOUT62
LUTOUT61
LUTOUT60
LUTOUT59
LUTOUT58
LUTOUT57
LUTOUT56
LUTOUT55
LUTOUT54
LUTOUT53
LUTOUT52
LUTOUT51
LUTOUT50
LUTOUT49
LUTOUT48
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
LUTOUT47
LUTOUT46
LUTOUT45
LUTOUT44
LUTOUT43
LUTOUT42
LUTOUT41
LUTOUT40
LUTOUT39
LUTOUT38
LUTOUT37
LUTOUT36
LUTOUT35
LUTOUT34
LUTOUT33
LUTOUT32
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2796
NXP Semiconductors

<!-- page 2797 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_1 field descriptions
Field
Description
31
LUTOUT63
LUT OUT
30
LUTOUT62
LUT OUT
29
LUTOUT61
LUT OUT
28
LUTOUT60
LUT OUT
27
LUTOUT59
LUT OUT
26
LUTOUT58
LUT OUT
25
LUTOUT57
LUT OUT
24
LUTOUT56
LUT OUT
23
LUTOUT55
LUT OUT
22
LUTOUT54
LUT OUT
21
LUTOUT53
LUT OUT
20
LUTOUT52
LUT OUT
19
LUTOUT51
LUT OUT
18
LUTOUT50
LUT OUT
17
LUTOUT49
LUT OUT
16
LUTOUT48
LUT OUT
15
LUTOUT47
LUT OUT
14
LUTOUT46
LUT OUT
13
LUTOUT45
LUT OUT
12
LUTOUT44
LUT OUT
11
LUTOUT43
LUT OUT
10
LUTOUT42
LUT OUT
9
LUTOUT41
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2797

<!-- page 2798 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_1 field descriptions (continued)
Field
Description
8
LUTOUT40
LUT OUT
7
LUTOUT39
LUT OUT
6
LUTOUT38
LUT OUT
5
LUTOUT37
LUT OUT
4
LUTOUT36
LUT OUT
3
LUTOUT35
LUT OUT
2
LUTOUT34
LUT OUT
1
LUTOUT33
LUT OUT
0
LUTOUT32
LUT OUT
41.11.225
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_2)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2230h offset = 21C_E230h
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
LUTOUT95
LUTOUT94
LUTOUT93
LUTOUT92
LUTOUT91
LUTOUT90
LUTOUT89
LUTOUT88
LUTOUT87
LUTOUT86
LUTOUT85
LUTOUT84
LUTOUT83
LUTOUT82
LUTOUT81
LUTOUT80
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
LUTOUT79
LUTOUT78
LUTOUT77
LUTOUT76
LUTOUT75
LUTOUT74
LUTOUT73
LUTOUT72
LUTOUT71
LUTOUT70
LUTOUT69
LUTOUT68
LUTOUT67
LUTOUT66
LUTOUT65
LUTOUT64
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2798
NXP Semiconductors

<!-- page 2799 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_2 field descriptions
Field
Description
31
LUTOUT95
LUT OUT
30
LUTOUT94
LUT OUT
29
LUTOUT93
LUT OUT
28
LUTOUT92
LUT OUT
27
LUTOUT91
LUT OUT
26
LUTOUT90
LUT OUT
25
LUTOUT89
LUT OUT
24
LUTOUT88
LUT OUT
23
LUTOUT87
LUT OUT
22
LUTOUT86
LUT OUT
21
LUTOUT85
LUT OUT
20
LUTOUT84
LUT OUT
19
LUTOUT83
LUT OUT
18
LUTOUT82
LUT OUT
17
LUTOUT81
LUT OUT
16
LUTOUT80
LUT OUT
15
LUTOUT79
LUT OUT
14
LUTOUT78
LUT OUT
13
LUTOUT77
LUT OUT
12
LUTOUT76
LUT OUT
11
LUTOUT75
LUT OUT
10
LUTOUT74
LUT OUT
9
LUTOUT73
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2799

<!-- page 2800 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_2 field descriptions (continued)
Field
Description
8
LUTOUT72
LUT OUT
7
LUTOUT71
LUT OUT
6
LUTOUT70
LUT OUT
5
LUTOUT69
LUT OUT
4
LUTOUT68
LUT OUT
3
LUTOUT67
LUT OUT
2
LUTOUT66
LUT OUT
1
LUTOUT65
LUT OUT
0
LUTOUT64
LUT OUT
41.11.226
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_3)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2240h offset = 21C_E240h
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
LUTOUT127
LUTOUT126
LUTOUT125
LUTOUT124
LUTOUT123
LUTOUT122
LUTOUT121
LUTOUT120
LUTOUT119
LUTOUT118
LUTOUT117
LUTOUT116
LUTOUT115
LUTOUT114
LUTOUT113
LUTOUT112
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
LUTOUT111
LUTOUT110
LUTOUT109
LUTOUT108
LUTOUT107
LUTOUT106
LUTOUT105
LUTOUT104
LUTOUT103
LUTOUT102
LUTOUT101
LUTOUT100
LUTOUT99
LUTOUT98
LUTOUT97
LUTOUT96
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2800
NXP Semiconductors

<!-- page 2801 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_3 field descriptions
Field
Description
31
LUTOUT127
LUT OUT
30
LUTOUT126
LUT OUT
29
LUTOUT125
LUT OUT
28
LUTOUT124
LUT OUT
27
LUTOUT123
LUT OUT
26
LUTOUT122
LUT OUT
25
LUTOUT121
LUT OUT
24
LUTOUT120
LUT OUT
23
LUTOUT119
LUT OUT
22
LUTOUT118
LUT OUT
21
LUTOUT117
LUT OUT
20
LUTOUT116
LUT OUT
19
LUTOUT115
LUT OUT
18
LUTOUT114
LUT OUT
17
LUTOUT113
LUT OUT
16
LUTOUT112
LUT OUT
15
LUTOUT111
LUT OUT
14
LUTOUT110
LUT OUT
13
LUTOUT109
LUT OUT
12
LUTOUT108
LUT OUT
11
LUTOUT107
LUT OUT
10
LUTOUT106
LUT OUT
9
LUTOUT105
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2801

<!-- page 2802 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_3 field descriptions (continued)
Field
Description
8
LUTOUT104
LUT OUT
7
LUTOUT103
LUT OUT
6
LUTOUT102
LUT OUT
5
LUTOUT101
LUT OUT
4
LUTOUT100
LUT OUT
3
LUTOUT99
LUT OUT
2
LUTOUT98
LUT OUT
1
LUTOUT97
LUT OUT
0
LUTOUT96
LUT OUT
41.11.227
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_4)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2250h offset = 21C_E250h
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
LUTOUT159
LUTOUT158
LUTOUT157
LUTOUT156
LUTOUT155
LUTOUT154
LUTOUT153
LUTOUT152
LUTOUT151
LUTOUT150
LUTOUT149
LUTOUT148
LUTOUT147
LUTOUT146
LUTOUT145
LUTOUT144
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
LUTOUT143
LUTOUT142
LUTOUT141
LUTOUT140
LUTOUT139
LUTOUT138
LUTOUT137
LUTOUT136
LUTOUT135
LUTOUT134
LUTOUT133
LUTOUT132
LUTOUT131
LUTOUT130
LUTOUT129
LUTOUT128
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2802
NXP Semiconductors

<!-- page 2803 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_4 field descriptions
Field
Description
31
LUTOUT159
LUT OUT
30
LUTOUT158
LUT OUT
29
LUTOUT157
LUT OUT
28
LUTOUT156
LUT OUT
27
LUTOUT155
LUT OUT
26
LUTOUT154
LUT OUT
25
LUTOUT153
LUT OUT
24
LUTOUT152
LUT OUT
23
LUTOUT151
LUT OUT
22
LUTOUT150
LUT OUT
21
LUTOUT149
LUT OUT
20
LUTOUT148
LUT OUT
19
LUTOUT147
LUT OUT
18
LUTOUT146
LUT OUT
17
LUTOUT145
LUT OUT
16
LUTOUT144
LUT OUT
15
LUTOUT143
LUT OUT
14
LUTOUT142
LUT OUT
13
LUTOUT141
LUT OUT
12
LUTOUT140
LUT OUT
11
LUTOUT139
LUT OUT
10
LUTOUT138
LUT OUT
9
LUTOUT137
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2803

<!-- page 2804 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_4 field descriptions (continued)
Field
Description
8
LUTOUT136
LUT OUT
7
LUTOUT135
LUT OUT
6
LUTOUT134
LUT OUT
5
LUTOUT133
LUT OUT
4
LUTOUT132
LUT OUT
3
LUTOUT131
LUT OUT
2
LUTOUT130
LUT OUT
1
LUTOUT129
LUT OUT
0
LUTOUT128
LUT OUT
41.11.228
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_5)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2260h offset = 21C_E260h
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
LUTOUT191
LUTOUT190
LUTOUT189
LUTOUT188
LUTOUT187
LUTOUT186
LUTOUT185
LUTOUT184
LUTOUT183
LUTOUT182
LUTOUT181
LUTOUT180
LUTOUT179
LUTOUT178
LUTOUT177
LUTOUT176
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
LUTOUT175
LUTOUT174
LUTOUT173
LUTOUT172
LUTOUT171
LUTOUT170
LUTOUT169
LUTOUT168
LUTOUT167
LUTOUT166
LUTOUT165
LUTOUT164
LUTOUT163
LUTOUT162
LUTOUT161
LUTOUT160
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2804
NXP Semiconductors

<!-- page 2805 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_5 field descriptions
Field
Description
31
LUTOUT191
LUT OUT
30
LUTOUT190
LUT OUT
29
LUTOUT189
LUT OUT
28
LUTOUT188
LUT OUT
27
LUTOUT187
LUT OUT
26
LUTOUT186
LUT OUT
25
LUTOUT185
LUT OUT
24
LUTOUT184
LUT OUT
23
LUTOUT183
LUT OUT
22
LUTOUT182
LUT OUT
21
LUTOUT181
LUT OUT
20
LUTOUT180
LUT OUT
19
LUTOUT179
LUT OUT
18
LUTOUT178
LUT OUT
17
LUTOUT177
LUT OUT
16
LUTOUT176
LUT OUT
15
LUTOUT175
LUT OUT
14
LUTOUT174
LUT OUT
13
LUTOUT173
LUT OUT
12
LUTOUT172
LUT OUT
11
LUTOUT171
LUT OUT
10
LUTOUT170
LUT OUT
9
LUTOUT169
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2805

<!-- page 2806 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_5 field descriptions (continued)
Field
Description
8
LUTOUT168
LUT OUT
7
LUTOUT167
LUT OUT
6
LUTOUT166
LUT OUT
5
LUTOUT165
LUT OUT
4
LUTOUT164
LUT OUT
3
LUTOUT163
LUT OUT
2
LUTOUT162
LUT OUT
1
LUTOUT161
LUT OUT
0
LUTOUT160
LUT OUT
41.11.229
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_6)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2270h offset = 21C_E270h
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
LUTOUT223
LUTOUT222
LUTOUT221
LUTOUT220
LUTOUT219
LUTOUT218
LUTOUT217
LUTOUT216
LUTOUT215
LUTOUT214
LUTOUT213
LUTOUT212
LUTOUT211
LUTOUT210
LUTOUT209
LUTOUT208
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
LUTOUT207
LUTOUT206
LUTOUT205
LUTOUT204
LUTOUT203
LUTOUT202
LUTOUT201
LUTOUT200
LUTOUT199
LUTOUT198
LUTOUT197
LUTOUT196
LUTOUT195
LUTOUT194
LUTOUT193
LUTOUT192
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2806
NXP Semiconductors

<!-- page 2807 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_6 field descriptions
Field
Description
31
LUTOUT223
LUT OUT
30
LUTOUT222
LUT OUT
29
LUTOUT221
LUT OUT
28
LUTOUT220
LUT OUT
27
LUTOUT219
LUT OUT
26
LUTOUT218
LUT OUT
25
LUTOUT217
LUT OUT
24
LUTOUT216
LUT OUT
23
LUTOUT215
LUT OUT
22
LUTOUT214
LUT OUT
21
LUTOUT213
LUT OUT
20
LUTOUT212
LUT OUT
19
LUTOUT211
LUT OUT
18
LUTOUT210
LUT OUT
17
LUTOUT209
LUT OUT
16
LUTOUT208
LUT OUT
15
LUTOUT207
LUT OUT
14
LUTOUT206
LUT OUT
13
LUTOUT205
LUT OUT
12
LUTOUT204
LUT OUT
11
LUTOUT203
LUT OUT
10
LUTOUT202
LUT OUT
9
LUTOUT201
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2807

<!-- page 2808 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_6 field descriptions (continued)
Field
Description
8
LUTOUT200
LUT OUT
7
LUTOUT199
LUT OUT
6
LUTOUT198
LUT OUT
5
LUTOUT197
LUT OUT
4
LUTOUT196
LUT OUT
3
LUTOUT195
LUT OUT
2
LUTOUT194
LUT OUT
1
LUTOUT193
LUT OUT
0
LUTOUT192
LUT OUT
41.11.230
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_7)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2280h offset = 21C_E280h
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
LUTOUT255
LUTOUT254
LUTOUT253
LUTOUT252
LUTOUT251
LUTOUT250
LUTOUT249
LUTOUT248
LUTOUT247
LUTOUT246
LUTOUT245
LUTOUT244
LUTOUT243
LUTOUT242
LUTOUT241
LUTOUT240
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
LUTOUT239
LUTOUT238
LUTOUT237
LUTOUT236
LUTOUT235
LUTOUT234
LUTOUT233
LUTOUT232
LUTOUT231
LUTOUT230
LUTOUT229
LUTOUT228
LUTOUT227
LUTOUT226
LUTOUT225
LUTOUT224
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2808
NXP Semiconductors

<!-- page 2809 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_7 field descriptions
Field
Description
31
LUTOUT255
LUT OUT
30
LUTOUT254
LUT OUT
29
LUTOUT253
LUT OUT
28
LUTOUT252
LUT OUT
27
LUTOUT251
LUT OUT
26
LUTOUT250
LUT OUT
25
LUTOUT249
LUT OUT
24
LUTOUT248
LUT OUT
23
LUTOUT247
LUT OUT
22
LUTOUT246
LUT OUT
21
LUTOUT245
LUT OUT
20
LUTOUT244
LUT OUT
19
LUTOUT243
LUT OUT
18
LUTOUT242
LUT OUT
17
LUTOUT241
LUT OUT
16
LUTOUT240
LUT OUT
15
LUTOUT239
LUT OUT
14
LUTOUT238
LUT OUT
13
LUTOUT237
LUT OUT
12
LUTOUT236
LUT OUT
11
LUTOUT235
LUT OUT
10
LUTOUT234
LUT OUT
9
LUTOUT233
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2809

<!-- page 2810 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT3_7 field descriptions (continued)
Field
Description
8
LUTOUT232
LUT OUT
7
LUTOUT231
LUT OUT
6
LUTOUT230
LUT OUT
5
LUTOUT229
LUT OUT
4
LUTOUT228
LUT OUT
3
LUTOUT227
LUT OUT
2
LUTOUT226
LUT OUT
1
LUTOUT225
LUT OUT
0
LUTOUT224
LUT OUT
41.11.231
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_0)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2290h offset = 21C_E290h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2810
NXP Semiconductors

<!-- page 2811 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_0 field descriptions
Field
Description
31
LUTOUT31
LUT OUT
30
LUTOUT30
LUT OUT
29
LUTOUT29
LUT OUT
28
LUTOUT28
LUT OUT
27
LUTOUT27
LUT OUT
26
LUTOUT26
LUT OUT
25
LUTOUT25
LUT OUT
24
LUTOUT24
LUT OUT
23
LUTOUT23
LUT OUT
22
LUTOUT22
LUT OUT
21
LUTOUT21
LUT OUT
20
LUTOUT20
LUT OUT
19
LUTOUT19
LUT OUT
18
LUTOUT18
LUT OUT
17
LUTOUT17
LUT OUT
16
LUTOUT16
LUT OUT
15
LUTOUT15
LUT OUT
14
LUTOUT14
LUT OUT
13
LUTOUT13
LUT OUT
12
LUTOUT12
LUT OUT
11
LUTOUT11
LUT OUT
10
LUTOUT10
LUT OUT
9
LUTOUT9
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2811

<!-- page 2812 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_0 field descriptions (continued)
Field
Description
8
LUTOUT8
LUT OUT
7
LUTOUT7
LUT OUT
6
LUTOUT6
LUT OUT
5
LUTOUT5
LUT OUT
4
LUTOUT4
LUT OUT
3
LUTOUT3
LUT OUT
2
LUTOUT2
LUT OUT
1
LUTOUT1
LUT OUT
0
LUTOUT0
LUT OUT
41.11.232
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_1)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 22A0h offset = 21C_E2A0h
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
LUTOUT63
LUTOUT62
LUTOUT61
LUTOUT60
LUTOUT59
LUTOUT58
LUTOUT57
LUTOUT56
LUTOUT55
LUTOUT54
LUTOUT53
LUTOUT52
LUTOUT51
LUTOUT50
LUTOUT49
LUTOUT48
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
LUTOUT47
LUTOUT46
LUTOUT45
LUTOUT44
LUTOUT43
LUTOUT42
LUTOUT41
LUTOUT40
LUTOUT39
LUTOUT38
LUTOUT37
LUTOUT36
LUTOUT35
LUTOUT34
LUTOUT33
LUTOUT32
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2812
NXP Semiconductors

<!-- page 2813 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_1 field descriptions
Field
Description
31
LUTOUT63
LUT OUT
30
LUTOUT62
LUT OUT
29
LUTOUT61
LUT OUT
28
LUTOUT60
LUT OUT
27
LUTOUT59
LUT OUT
26
LUTOUT58
LUT OUT
25
LUTOUT57
LUT OUT
24
LUTOUT56
LUT OUT
23
LUTOUT55
LUT OUT
22
LUTOUT54
LUT OUT
21
LUTOUT53
LUT OUT
20
LUTOUT52
LUT OUT
19
LUTOUT51
LUT OUT
18
LUTOUT50
LUT OUT
17
LUTOUT49
LUT OUT
16
LUTOUT48
LUT OUT
15
LUTOUT47
LUT OUT
14
LUTOUT46
LUT OUT
13
LUTOUT45
LUT OUT
12
LUTOUT44
LUT OUT
11
LUTOUT43
LUT OUT
10
LUTOUT42
LUT OUT
9
LUTOUT41
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2813

<!-- page 2814 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_1 field descriptions (continued)
Field
Description
8
LUTOUT40
LUT OUT
7
LUTOUT39
LUT OUT
6
LUTOUT38
LUT OUT
5
LUTOUT37
LUT OUT
4
LUTOUT36
LUT OUT
3
LUTOUT35
LUT OUT
2
LUTOUT34
LUT OUT
1
LUTOUT33
LUT OUT
0
LUTOUT32
LUT OUT
41.11.233
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_2)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 22B0h offset = 21C_E2B0h
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
LUTOUT95
LUTOUT94
LUTOUT93
LUTOUT92
LUTOUT91
LUTOUT90
LUTOUT89
LUTOUT88
LUTOUT87
LUTOUT86
LUTOUT85
LUTOUT84
LUTOUT83
LUTOUT82
LUTOUT81
LUTOUT80
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
LUTOUT79
LUTOUT78
LUTOUT77
LUTOUT76
LUTOUT75
LUTOUT74
LUTOUT73
LUTOUT72
LUTOUT71
LUTOUT70
LUTOUT69
LUTOUT68
LUTOUT67
LUTOUT66
LUTOUT65
LUTOUT64
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2814
NXP Semiconductors

<!-- page 2815 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_2 field descriptions
Field
Description
31
LUTOUT95
LUT OUT
30
LUTOUT94
LUT OUT
29
LUTOUT93
LUT OUT
28
LUTOUT92
LUT OUT
27
LUTOUT91
LUT OUT
26
LUTOUT90
LUT OUT
25
LUTOUT89
LUT OUT
24
LUTOUT88
LUT OUT
23
LUTOUT87
LUT OUT
22
LUTOUT86
LUT OUT
21
LUTOUT85
LUT OUT
20
LUTOUT84
LUT OUT
19
LUTOUT83
LUT OUT
18
LUTOUT82
LUT OUT
17
LUTOUT81
LUT OUT
16
LUTOUT80
LUT OUT
15
LUTOUT79
LUT OUT
14
LUTOUT78
LUT OUT
13
LUTOUT77
LUT OUT
12
LUTOUT76
LUT OUT
11
LUTOUT75
LUT OUT
10
LUTOUT74
LUT OUT
9
LUTOUT73
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2815

<!-- page 2816 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_2 field descriptions (continued)
Field
Description
8
LUTOUT72
LUT OUT
7
LUTOUT71
LUT OUT
6
LUTOUT70
LUT OUT
5
LUTOUT69
LUT OUT
4
LUTOUT68
LUT OUT
3
LUTOUT67
LUT OUT
2
LUTOUT66
LUT OUT
1
LUTOUT65
LUT OUT
0
LUTOUT64
LUT OUT
41.11.234
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_3)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 22C0h offset = 21C_E2C0h
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
LUTOUT127
LUTOUT126
LUTOUT125
LUTOUT124
LUTOUT123
LUTOUT122
LUTOUT121
LUTOUT120
LUTOUT119
LUTOUT118
LUTOUT117
LUTOUT116
LUTOUT115
LUTOUT114
LUTOUT113
LUTOUT112
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
LUTOUT111
LUTOUT110
LUTOUT109
LUTOUT108
LUTOUT107
LUTOUT106
LUTOUT105
LUTOUT104
LUTOUT103
LUTOUT102
LUTOUT101
LUTOUT100
LUTOUT99
LUTOUT98
LUTOUT97
LUTOUT96
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2816
NXP Semiconductors

<!-- page 2817 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_3 field descriptions
Field
Description
31
LUTOUT127
LUT OUT
30
LUTOUT126
LUT OUT
29
LUTOUT125
LUT OUT
28
LUTOUT124
LUT OUT
27
LUTOUT123
LUT OUT
26
LUTOUT122
LUT OUT
25
LUTOUT121
LUT OUT
24
LUTOUT120
LUT OUT
23
LUTOUT119
LUT OUT
22
LUTOUT118
LUT OUT
21
LUTOUT117
LUT OUT
20
LUTOUT116
LUT OUT
19
LUTOUT115
LUT OUT
18
LUTOUT114
LUT OUT
17
LUTOUT113
LUT OUT
16
LUTOUT112
LUT OUT
15
LUTOUT111
LUT OUT
14
LUTOUT110
LUT OUT
13
LUTOUT109
LUT OUT
12
LUTOUT108
LUT OUT
11
LUTOUT107
LUT OUT
10
LUTOUT106
LUT OUT
9
LUTOUT105
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2817

<!-- page 2818 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_3 field descriptions (continued)
Field
Description
8
LUTOUT104
LUT OUT
7
LUTOUT103
LUT OUT
6
LUTOUT102
LUT OUT
5
LUTOUT101
LUT OUT
4
LUTOUT100
LUT OUT
3
LUTOUT99
LUT OUT
2
LUTOUT98
LUT OUT
1
LUTOUT97
LUT OUT
0
LUTOUT96
LUT OUT
41.11.235
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_4)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 22D0h offset = 21C_E2D0h
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
LUTOUT159
LUTOUT158
LUTOUT157
LUTOUT156
LUTOUT155
LUTOUT154
LUTOUT153
LUTOUT152
LUTOUT151
LUTOUT150
LUTOUT149
LUTOUT148
LUTOUT147
LUTOUT146
LUTOUT145
LUTOUT144
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
LUTOUT143
LUTOUT142
LUTOUT141
LUTOUT140
LUTOUT139
LUTOUT138
LUTOUT137
LUTOUT136
LUTOUT135
LUTOUT134
LUTOUT133
LUTOUT132
LUTOUT131
LUTOUT130
LUTOUT129
LUTOUT128
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2818
NXP Semiconductors

<!-- page 2819 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_4 field descriptions
Field
Description
31
LUTOUT159
LUT OUT
30
LUTOUT158
LUT OUT
29
LUTOUT157
LUT OUT
28
LUTOUT156
LUT OUT
27
LUTOUT155
LUT OUT
26
LUTOUT154
LUT OUT
25
LUTOUT153
LUT OUT
24
LUTOUT152
LUT OUT
23
LUTOUT151
LUT OUT
22
LUTOUT150
LUT OUT
21
LUTOUT149
LUT OUT
20
LUTOUT148
LUT OUT
19
LUTOUT147
LUT OUT
18
LUTOUT146
LUT OUT
17
LUTOUT145
LUT OUT
16
LUTOUT144
LUT OUT
15
LUTOUT143
LUT OUT
14
LUTOUT142
LUT OUT
13
LUTOUT141
LUT OUT
12
LUTOUT140
LUT OUT
11
LUTOUT139
LUT OUT
10
LUTOUT138
LUT OUT
9
LUTOUT137
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2819

<!-- page 2820 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_4 field descriptions (continued)
Field
Description
8
LUTOUT136
LUT OUT
7
LUTOUT135
LUT OUT
6
LUTOUT134
LUT OUT
5
LUTOUT133
LUT OUT
4
LUTOUT132
LUT OUT
3
LUTOUT131
LUT OUT
2
LUTOUT130
LUT OUT
1
LUTOUT129
LUT OUT
0
LUTOUT128
LUT OUT
41.11.236
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_5)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 22E0h offset = 21C_E2E0h
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
LUTOUT191
LUTOUT190
LUTOUT189
LUTOUT188
LUTOUT187
LUTOUT186
LUTOUT185
LUTOUT184
LUTOUT183
LUTOUT182
LUTOUT181
LUTOUT180
LUTOUT179
LUTOUT178
LUTOUT177
LUTOUT176
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
LUTOUT175
LUTOUT174
LUTOUT173
LUTOUT172
LUTOUT171
LUTOUT170
LUTOUT169
LUTOUT168
LUTOUT167
LUTOUT166
LUTOUT165
LUTOUT164
LUTOUT163
LUTOUT162
LUTOUT161
LUTOUT160
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2820
NXP Semiconductors

<!-- page 2821 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_5 field descriptions
Field
Description
31
LUTOUT191
LUT OUT
30
LUTOUT190
LUT OUT
29
LUTOUT189
LUT OUT
28
LUTOUT188
LUT OUT
27
LUTOUT187
LUT OUT
26
LUTOUT186
LUT OUT
25
LUTOUT185
LUT OUT
24
LUTOUT184
LUT OUT
23
LUTOUT183
LUT OUT
22
LUTOUT182
LUT OUT
21
LUTOUT181
LUT OUT
20
LUTOUT180
LUT OUT
19
LUTOUT179
LUT OUT
18
LUTOUT178
LUT OUT
17
LUTOUT177
LUT OUT
16
LUTOUT176
LUT OUT
15
LUTOUT175
LUT OUT
14
LUTOUT174
LUT OUT
13
LUTOUT173
LUT OUT
12
LUTOUT172
LUT OUT
11
LUTOUT171
LUT OUT
10
LUTOUT170
LUT OUT
9
LUTOUT169
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2821

<!-- page 2822 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_5 field descriptions (continued)
Field
Description
8
LUTOUT168
LUT OUT
7
LUTOUT167
LUT OUT
6
LUTOUT166
LUT OUT
5
LUTOUT165
LUT OUT
4
LUTOUT164
LUT OUT
3
LUTOUT163
LUT OUT
2
LUTOUT162
LUT OUT
1
LUTOUT161
LUT OUT
0
LUTOUT160
LUT OUT
41.11.237
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_6)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 22F0h offset = 21C_E2F0h
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
LUTOUT223
LUTOUT222
LUTOUT221
LUTOUT220
LUTOUT219
LUTOUT218
LUTOUT217
LUTOUT216
LUTOUT215
LUTOUT214
LUTOUT213
LUTOUT212
LUTOUT211
LUTOUT210
LUTOUT209
LUTOUT208
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
LUTOUT207
LUTOUT206
LUTOUT205
LUTOUT204
LUTOUT203
LUTOUT202
LUTOUT201
LUTOUT200
LUTOUT199
LUTOUT198
LUTOUT197
LUTOUT196
LUTOUT195
LUTOUT194
LUTOUT193
LUTOUT192
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2822
NXP Semiconductors

<!-- page 2823 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_6 field descriptions
Field
Description
31
LUTOUT223
LUT OUT
30
LUTOUT222
LUT OUT
29
LUTOUT221
LUT OUT
28
LUTOUT220
LUT OUT
27
LUTOUT219
LUT OUT
26
LUTOUT218
LUT OUT
25
LUTOUT217
LUT OUT
24
LUTOUT216
LUT OUT
23
LUTOUT215
LUT OUT
22
LUTOUT214
LUT OUT
21
LUTOUT213
LUT OUT
20
LUTOUT212
LUT OUT
19
LUTOUT211
LUT OUT
18
LUTOUT210
LUT OUT
17
LUTOUT209
LUT OUT
16
LUTOUT208
LUT OUT
15
LUTOUT207
LUT OUT
14
LUTOUT206
LUT OUT
13
LUTOUT205
LUT OUT
12
LUTOUT204
LUT OUT
11
LUTOUT203
LUT OUT
10
LUTOUT202
LUT OUT
9
LUTOUT201
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2823

<!-- page 2824 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_6 field descriptions (continued)
Field
Description
8
LUTOUT200
LUT OUT
7
LUTOUT199
LUT OUT
6
LUTOUT198
LUT OUT
5
LUTOUT197
LUT OUT
4
LUTOUT196
LUT OUT
3
LUTOUT195
LUT OUT
2
LUTOUT194
LUT OUT
1
LUTOUT193
LUT OUT
0
LUTOUT192
LUT OUT
41.11.238
This register defines the output values (new flag) for
the 8x1 LUTs in stage 1.
(PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_7)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2300h offset = 21C_E300h
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
LUTOUT255
LUTOUT254
LUTOUT253
LUTOUT252
LUTOUT251
LUTOUT250
LUTOUT249
LUTOUT248
LUTOUT247
LUTOUT246
LUTOUT245
LUTOUT244
LUTOUT243
LUTOUT242
LUTOUT241
LUTOUT240
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
LUTOUT239
LUTOUT238
LUTOUT237
LUTOUT236
LUTOUT235
LUTOUT234
LUTOUT233
LUTOUT232
LUTOUT231
LUTOUT230
LUTOUT229
LUTOUT228
LUTOUT227
LUTOUT226
LUTOUT225
LUTOUT224
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2824
NXP Semiconductors

<!-- page 2825 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_7 field descriptions
Field
Description
31
LUTOUT255
LUT OUT
30
LUTOUT254
LUT OUT
29
LUTOUT253
LUT OUT
28
LUTOUT252
LUT OUT
27
LUTOUT251
LUT OUT
26
LUTOUT250
LUT OUT
25
LUTOUT249
LUT OUT
24
LUTOUT248
LUT OUT
23
LUTOUT247
LUT OUT
22
LUTOUT246
LUT OUT
21
LUTOUT245
LUT OUT
20
LUTOUT244
LUT OUT
19
LUTOUT243
LUT OUT
18
LUTOUT242
LUT OUT
17
LUTOUT241
LUT OUT
16
LUTOUT240
LUT OUT
15
LUTOUT239
LUT OUT
14
LUTOUT238
LUT OUT
13
LUTOUT237
LUT OUT
12
LUTOUT236
LUT OUT
11
LUTOUT235
LUT OUT
10
LUTOUT234
LUT OUT
9
LUTOUT233
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2825

<!-- page 2826 -->

PXP_HW_PXP_WFE_B_STG1_8X1_OUT4_7 field descriptions (continued)
Field
Description
8
LUTOUT232
LUT OUT
7
LUTOUT231
LUT OUT
6
LUTOUT230
LUT OUT
5
LUTOUT229
LUT OUT
4
LUTOUT228
LUT OUT
3
LUTOUT227
LUT OUT
2
LUTOUT226
LUT OUT
1
LUTOUT225
LUT OUT
0
LUTOUT224
LUT OUT
41.11.239
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_0)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2310h offset = 21C_E310h
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
LUTOUT3
0
LUTOUT2
0
LUTOUT1
0
LUTOUT0
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_0 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT3
LUTOUT 3
23–22
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2826
NXP Semiconductors

<!-- page 2827 -->

PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_0 field descriptions (continued)
Field
Description
21–16
LUTOUT2
LUTOUT 2
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT1
LUTOUT 1
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT0
LUTOUT 0
41.11.240
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_1)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2320h offset = 21C_E320h
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
LUTOUT7
0
LUTOUT6
0
LUTOUT5
0
LUTOUT4
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_1 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT7
LUTOUT 7
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT6
LUTOUT 6
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT5
LUTOUT 5
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT4
LUTOUT 4
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2827

<!-- page 2828 -->

41.11.241
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_2)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2330h offset = 21C_E330h
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
LUTOUT11
0
LUTOUT10
0
LUTOUT9
0
LUTOUT8
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_2 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT11
LUTOUT 11
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT10
LUTOUT 10
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT9
LUTOUT 9
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT8
LUTOUT 8
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2828
NXP Semiconductors

<!-- page 2829 -->

41.11.242
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_3)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2340h offset = 21C_E340h
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
LUTOUT15
0
LUTOUT14
0
LUTOUT13
0
LUTOUT12
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_3 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT15
LUTOUT 15
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT14
LUTOUT 14
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT13
LUTOUT 13
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT12
LUTOUT 12
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2829

<!-- page 2830 -->

41.11.243
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_4)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2350h offset = 21C_E350h
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
LUTOUT19
0
LUTOUT18
0
LUTOUT17
0
LUTOUT16
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_4 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT19
LUTOUT 19
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT18
LUTOUT 18
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT17
LUTOUT 17
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT16
LUTOUT 16
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2830
NXP Semiconductors

<!-- page 2831 -->

41.11.244
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_5)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2360h offset = 21C_E360h
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
LUTOUT23
0
LUTOUT22
0
LUTOUT21
0
LUTOUT20
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_5 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT23
LUTOUT 23
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT22
LUTOUT 22
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT21
LUTOUT 21
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT20
LUTOUT 20
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2831

<!-- page 2832 -->

41.11.245
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_6)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2370h offset = 21C_E370h
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
LUTOUT27
0
LUTOUT26
0
LUTOUT25
0
LUTOUT24
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_6 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT27
LUTOUT 27
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT26
LUTOUT 26
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT25
LUTOUT 25
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT24
LUTOUT 24
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2832
NXP Semiconductors

<!-- page 2833 -->

41.11.246
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_7)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2380h offset = 21C_E380h
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
LUTOUT31
0
LUTOUT30
0
LUTOUT29
0
LUTOUT28
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT0_7 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT31
LUTOUT 31
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT30
LUTOUT 30
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT29
LUTOUT 29
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT28
LUTOUT 28
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2833

<!-- page 2834 -->

41.11.247
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_0)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2390h offset = 21C_E390h
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
LUTOUT3
0
LUTOUT2
0
LUTOUT1
0
LUTOUT0
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_0 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT3
LUTOUT 3
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT2
LUTOUT 2
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT1
LUTOUT 1
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT0
LUTOUT 0
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2834
NXP Semiconductors

<!-- page 2835 -->

41.11.248
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_1)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 23A0h offset = 21C_E3A0h
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
LUTOUT7
0
LUTOUT6
0
LUTOUT5
0
LUTOUT4
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_1 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT7
LUTOUT 7
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT6
LUTOUT 6
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT5
LUTOUT 5
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT4
LUTOUT 4
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2835

<!-- page 2836 -->

41.11.249
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_2)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 23B0h offset = 21C_E3B0h
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
LUTOUT11
0
LUTOUT10
0
LUTOUT9
0
LUTOUT8
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_2 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT11
LUTOUT 11
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT10
LUTOUT 10
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT9
LUTOUT 9
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT8
LUTOUT 8
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2836
NXP Semiconductors

<!-- page 2837 -->

41.11.250
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_3)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 23C0h offset = 21C_E3C0h
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
LUTOUT15
0
LUTOUT14
0
LUTOUT13
0
LUTOUT12
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_3 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT15
LUTOUT 15
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT14
LUTOUT 14
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT13
LUTOUT 13
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT12
LUTOUT 12
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2837

<!-- page 2838 -->

41.11.251
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_4)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 23D0h offset = 21C_E3D0h
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
LUTOUT19
0
LUTOUT18
0
LUTOUT17
0
LUTOUT16
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_4 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT19
LUTOUT 19
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT18
LUTOUT 18
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT17
LUTOUT 17
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT16
LUTOUT 16
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2838
NXP Semiconductors

<!-- page 2839 -->

41.11.252
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_5)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 23E0h offset = 21C_E3E0h
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
LUTOUT23
0
LUTOUT22
0
LUTOUT21
0
LUTOUT20
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_5 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT23
LUTOUT 23
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT22
LUTOUT 22
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT21
LUTOUT 21
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT20
LUTOUT 20
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2839

<!-- page 2840 -->

41.11.253
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_6)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 23F0h offset = 21C_E3F0h
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
LUTOUT27
0
LUTOUT26
0
LUTOUT25
0
LUTOUT24
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_6 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT27
LUTOUT 27
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT26
LUTOUT 26
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT25
LUTOUT 25
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT24
LUTOUT 24
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2840
NXP Semiconductors

<!-- page 2841 -->

41.11.254
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_7)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2400h offset = 21C_E400h
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
LUTOUT31
0
LUTOUT30
0
LUTOUT29
0
LUTOUT28
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT1_7 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT31
LUTOUT 31
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT30
LUTOUT 30
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT29
LUTOUT 29
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT28
LUTOUT 28
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2841

<!-- page 2842 -->

41.11.255
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_0)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2410h offset = 21C_E410h
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
LUTOUT3
0
LUTOUT2
0
LUTOUT1
0
LUTOUT0
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_0 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT3
LUTOUT 3
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT2
LUTOUT 2
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT1
LUTOUT 1
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT0
LUTOUT 0
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2842
NXP Semiconductors

<!-- page 2843 -->

41.11.256
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_1)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2420h offset = 21C_E420h
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
LUTOUT7
0
LUTOUT6
0
LUTOUT5
0
LUTOUT4
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_1 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT7
LUTOUT 7
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT6
LUTOUT 6
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT5
LUTOUT 5
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT4
LUTOUT 4
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2843

<!-- page 2844 -->

41.11.257
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_2)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2430h offset = 21C_E430h
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
LUTOUT11
0
LUTOUT10
0
LUTOUT9
0
LUTOUT8
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_2 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT11
LUTOUT 11
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT10
LUTOUT 10
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT9
LUTOUT 9
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT8
LUTOUT 8
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2844
NXP Semiconductors

<!-- page 2845 -->

41.11.258
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_3)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2440h offset = 21C_E440h
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
LUTOUT15
0
LUTOUT14
0
LUTOUT13
0
LUTOUT12
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_3 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT15
LUTOUT 15
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT14
LUTOUT 14
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT13
LUTOUT 13
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT12
LUTOUT 12
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2845

<!-- page 2846 -->

41.11.259
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_4)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2450h offset = 21C_E450h
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
LUTOUT19
0
LUTOUT18
0
LUTOUT17
0
LUTOUT16
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_4 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT19
LUTOUT 19
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT18
LUTOUT 18
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT17
LUTOUT 17
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT16
LUTOUT 16
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2846
NXP Semiconductors

<!-- page 2847 -->

41.11.260
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_5)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2460h offset = 21C_E460h
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
LUTOUT23
0
LUTOUT22
0
LUTOUT21
0
LUTOUT20
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_5 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT23
LUTOUT 23
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT22
LUTOUT 22
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT21
LUTOUT 21
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT20
LUTOUT 20
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2847

<!-- page 2848 -->

41.11.261
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_6)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2470h offset = 21C_E470h
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
LUTOUT27
0
LUTOUT26
0
LUTOUT25
0
LUTOUT24
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_6 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT27
LUTOUT 27
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT26
LUTOUT 26
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT25
LUTOUT 25
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT24
LUTOUT 24
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2848
NXP Semiconductors

<!-- page 2849 -->

41.11.262
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_7)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2480h offset = 21C_E480h
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
LUTOUT31
0
LUTOUT30
0
LUTOUT29
0
LUTOUT28
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT2_7 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT31
LUTOUT 31
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT30
LUTOUT 30
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT29
LUTOUT 29
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT28
LUTOUT 28
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2849

<!-- page 2850 -->

41.11.263
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_0)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2490h offset = 21C_E490h
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
LUTOUT3
0
LUTOUT2
0
LUTOUT1
0
LUTOUT0
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_0 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT3
LUTOUT 3
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT2
LUTOUT 2
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT1
LUTOUT 1
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT0
LUTOUT 0
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2850
NXP Semiconductors

<!-- page 2851 -->

41.11.264
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_1)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 24A0h offset = 21C_E4A0h
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
LUTOUT7
0
LUTOUT6
0
LUTOUT5
0
LUTOUT4
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_1 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT7
LUTOUT 7
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT6
LUTOUT 6
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT5
LUTOUT 5
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT4
LUTOUT 4
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2851

<!-- page 2852 -->

41.11.265
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_2)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 24B0h offset = 21C_E4B0h
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
LUTOUT11
0
LUTOUT10
0
LUTOUT9
0
LUTOUT8
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_2 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT11
LUTOUT 11
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT10
LUTOUT 10
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT9
LUTOUT 9
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT8
LUTOUT 8
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2852
NXP Semiconductors

<!-- page 2853 -->

41.11.266
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_3)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 24C0h offset = 21C_E4C0h
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
LUTOUT15
0
LUTOUT14
0
LUTOUT13
0
LUTOUT12
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_3 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT15
LUTOUT 15
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT14
LUTOUT 14
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT13
LUTOUT 13
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT12
LUTOUT 12
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2853

<!-- page 2854 -->

41.11.267
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_4)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 24E0h offset = 21C_E4E0h
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
LUTOUT19
0
LUTOUT18
0
LUTOUT17
0
LUTOUT16
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_4 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT19
LUTOUT 19
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT18
LUTOUT 18
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT17
LUTOUT 17
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT16
LUTOUT 16
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2854
NXP Semiconductors

<!-- page 2855 -->

41.11.268
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_5)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 24F0h offset = 21C_E4F0h
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
LUTOUT23
0
LUTOUT22
0
LUTOUT21
0
LUTOUT20
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_5 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT23
LUTOUT 23
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT22
LUTOUT 22
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT21
LUTOUT 21
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT20
LUTOUT 20
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2855

<!-- page 2856 -->

41.11.269
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_6)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2500h offset = 21C_E500h
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
LUTOUT27
0
LUTOUT26
0
LUTOUT25
0
LUTOUT24
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_6 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT27
LUTOUT 27
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT26
LUTOUT 26
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT25
LUTOUT 25
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT24
LUTOUT 24
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2856
NXP Semiconductors

<!-- page 2857 -->

41.11.270
This register defines the control bits for the pxp wfe
sub-block
(PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_7)
The 5x6 LUT output value for input value n. This output value determines which input to
select (flag, data).
Address: 21C_C000h base + 2510h offset = 21C_E510h
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
LUTOUT31
0
LUTOUT30
0
LUTOUT29
0
LUTOUT28
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
PXP_HW_PXP_WFE_B_STG2_5X6_OUT3_7 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
LUTOUT31
LUTOUT 31
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
LUTOUT30
LUTOUT 30
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
LUTOUT29
LUTOUT 29
7–6
Reserved
This read-only field is reserved and always has the value 0.
LUTOUT28
LUTOUT 28
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2857

<!-- page 2858 -->

41.11.271
Each set mask bit enables one of the corresponding
flag input bits. There is one mask per 5x6 LUT.
(PXP_HW_PXP_WFE_B_STAGE2_5X6_MASKS_0)
Each set mask bit enables one of the corresponding flag input bits. There is one mask per
5x6 LUT.
Address: 21C_C000h base + 2520h offset = 21C_E520h
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
MASK3
0
MASK2
0
MASK1
0
MASK0
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
PXP_HW_PXP_WFE_B_STAGE2_5X6_MASKS_0 field descriptions
Field
Description
31–29
Reserved
This read-only field is reserved and always has the value 0.
28–24
MASK3
This field selects the input flags that are valid for 5x6 LUT 1. Bit 0 = input 1, Bit 1 = input 2 and so on.
23–21
Reserved
This read-only field is reserved and always has the value 0.
20–16
MASK2
This field selects the input flags that are valid for 5x6 LUT 0. Bit 0 = input 1, Bit 1 = input 2 and so on.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
MASK1
This field selects the input flags that are valid for 5x6 LUT 1. Bit 0 = input 1, Bit 1 = input 2 and so on.
7–5
Reserved
This read-only field is reserved and always has the value 0.
MASK0
This field selects the input flags that are valid for 5x6 LUT 0. Bit 0 = input 1, Bit 1 = input 2 and so on.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2858
NXP Semiconductors

<!-- page 2859 -->

41.11.272
Each Address specifies the MUX position in the MUX
array. There is one MUXADDR per 5x6 LUT.
(PXP_HW_PXP_WFE_B_STAGE2_5X6_ADDR_0)
Address: 21C_C000h base + 2530h offset = 21C_E530h
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
MUXADDR3
0
MUXADDR2
0
MUXADDR1
0
MUXADDR0
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
PXP_HW_PXP_WFE_B_STAGE2_5X6_ADDR_0 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
MUXADDR3
This field reflects the address of the next stage element. The corresponding 5x6 lut output will become the
select to this element.
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
MUXADDR2
This field reflects the address of the next stage element. The corresponding 5x6 lut output will become the
select to this element.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
MUXADDR1
This field reflects the address of the next stage element. The corresponding 5x6 lut output will become the
select to this element.
7–6
Reserved
This read-only field is reserved and always has the value 0.
MUXADDR0
This field reflects the address of the next stage element. The corresponding 5x6 lut output will become the
select to this element.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2859

<!-- page 2860 -->

41.11.273
This register defines the output values (new flag) for
the 5x1 LUTs in stage 2.
(PXP_HW_PXP_WFE_B_STG2_5X1_OUT0)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2540h offset = 21C_E540h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
PXP_HW_PXP_WFE_B_STG2_5X1_OUT0 field descriptions
Field
Description
31
LUTOUT31
LUT OUT
30
LUTOUT30
LUT OUT
29
LUTOUT29
LUT OUT
28
LUTOUT28
LUT OUT
27
LUTOUT27
LUT OUT
26
LUTOUT26
LUT OUT
25
LUTOUT25
LUT OUT
24
LUTOUT24
LUT OUT
23
LUTOUT23
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2860
NXP Semiconductors

<!-- page 2861 -->

PXP_HW_PXP_WFE_B_STG2_5X1_OUT0 field descriptions (continued)
Field
Description
22
LUTOUT22
LUT OUT
21
LUTOUT21
LUT OUT
20
LUTOUT20
LUT OUT
19
LUTOUT19
LUT OUT
18
LUTOUT18
LUT OUT
17
LUTOUT17
LUT OUT
16
LUTOUT16
LUT OUT
15
LUTOUT15
LUT OUT
14
LUTOUT14
LUT OUT
13
LUTOUT13
LUT OUT
12
LUTOUT12
LUT OUT
11
LUTOUT11
LUT OUT
10
LUTOUT10
LUT OUT
9
LUTOUT9
LUT OUT
8
LUTOUT8
LUT OUT
7
LUTOUT7
LUT OUT
6
LUTOUT6
LUT OUT
5
LUTOUT5
LUT OUT
4
LUTOUT4
LUT OUT
3
LUTOUT3
LUT OUT
2
LUTOUT2
LUT OUT
1
LUTOUT1
LUT OUT
0
LUTOUT0
LUT OUT
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2861

<!-- page 2862 -->

41.11.274
This register defines the output values (new flag) for
the 5x1 LUTs in stage 2.
(PXP_HW_PXP_WFE_B_STG2_5X1_OUT1)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2550h offset = 21C_E550h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
PXP_HW_PXP_WFE_B_STG2_5X1_OUT1 field descriptions
Field
Description
31
LUTOUT31
LUT OUT
30
LUTOUT30
LUT OUT
29
LUTOUT29
LUT OUT
28
LUTOUT28
LUT OUT
27
LUTOUT27
LUT OUT
26
LUTOUT26
LUT OUT
25
LUTOUT25
LUT OUT
24
LUTOUT24
LUT OUT
23
LUTOUT23
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2862
NXP Semiconductors

<!-- page 2863 -->

PXP_HW_PXP_WFE_B_STG2_5X1_OUT1 field descriptions (continued)
Field
Description
22
LUTOUT22
LUT OUT
21
LUTOUT21
LUT OUT
20
LUTOUT20
LUT OUT
19
LUTOUT19
LUT OUT
18
LUTOUT18
LUT OUT
17
LUTOUT17
LUT OUT
16
LUTOUT16
LUT OUT
15
LUTOUT15
LUT OUT
14
LUTOUT14
LUT OUT
13
LUTOUT13
LUT OUT
12
LUTOUT12
LUT OUT
11
LUTOUT11
LUT OUT
10
LUTOUT10
LUT OUT
9
LUTOUT9
LUT OUT
8
LUTOUT8
LUT OUT
7
LUTOUT7
LUT OUT
6
LUTOUT6
LUT OUT
5
LUTOUT5
LUT OUT
4
LUTOUT4
LUT OUT
3
LUTOUT3
LUT OUT
2
LUTOUT2
LUT OUT
1
LUTOUT1
LUT OUT
0
LUTOUT0
LUT OUT
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2863

<!-- page 2864 -->

41.11.275
This register defines the output values (new flag) for
the 5x1 LUTs in stage 2.
(PXP_HW_PXP_WFE_B_STG2_5X1_OUT2)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2560h offset = 21C_E560h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
PXP_HW_PXP_WFE_B_STG2_5X1_OUT2 field descriptions
Field
Description
31
LUTOUT31
LUT OUT
30
LUTOUT30
LUT OUT
29
LUTOUT29
LUT OUT
28
LUTOUT28
LUT OUT
27
LUTOUT27
LUT OUT
26
LUTOUT26
LUT OUT
25
LUTOUT25
LUT OUT
24
LUTOUT24
LUT OUT
23
LUTOUT23
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2864
NXP Semiconductors

<!-- page 2865 -->

PXP_HW_PXP_WFE_B_STG2_5X1_OUT2 field descriptions (continued)
Field
Description
22
LUTOUT22
LUT OUT
21
LUTOUT21
LUT OUT
20
LUTOUT20
LUT OUT
19
LUTOUT19
LUT OUT
18
LUTOUT18
LUT OUT
17
LUTOUT17
LUT OUT
16
LUTOUT16
LUT OUT
15
LUTOUT15
LUT OUT
14
LUTOUT14
LUT OUT
13
LUTOUT13
LUT OUT
12
LUTOUT12
LUT OUT
11
LUTOUT11
LUT OUT
10
LUTOUT10
LUT OUT
9
LUTOUT9
LUT OUT
8
LUTOUT8
LUT OUT
7
LUTOUT7
LUT OUT
6
LUTOUT6
LUT OUT
5
LUTOUT5
LUT OUT
4
LUTOUT4
LUT OUT
3
LUTOUT3
LUT OUT
2
LUTOUT2
LUT OUT
1
LUTOUT1
LUT OUT
0
LUTOUT0
LUT OUT
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2865

<!-- page 2866 -->

41.11.276
This register defines the output values (new flag) for
the 5x1 LUTs in stage 2.
(PXP_HW_PXP_WFE_B_STG2_5X1_OUT3)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2570h offset = 21C_E570h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
PXP_HW_PXP_WFE_B_STG2_5X1_OUT3 field descriptions
Field
Description
31
LUTOUT31
LUT OUT
30
LUTOUT30
LUT OUT
29
LUTOUT29
LUT OUT
28
LUTOUT28
LUT OUT
27
LUTOUT27
LUT OUT
26
LUTOUT26
LUT OUT
25
LUTOUT25
LUT OUT
24
LUTOUT24
LUT OUT
23
LUTOUT23
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2866
NXP Semiconductors

<!-- page 2867 -->

PXP_HW_PXP_WFE_B_STG2_5X1_OUT3 field descriptions (continued)
Field
Description
22
LUTOUT22
LUT OUT
21
LUTOUT21
LUT OUT
20
LUTOUT20
LUT OUT
19
LUTOUT19
LUT OUT
18
LUTOUT18
LUT OUT
17
LUTOUT17
LUT OUT
16
LUTOUT16
LUT OUT
15
LUTOUT15
LUT OUT
14
LUTOUT14
LUT OUT
13
LUTOUT13
LUT OUT
12
LUTOUT12
LUT OUT
11
LUTOUT11
LUT OUT
10
LUTOUT10
LUT OUT
9
LUTOUT9
LUT OUT
8
LUTOUT8
LUT OUT
7
LUTOUT7
LUT OUT
6
LUTOUT6
LUT OUT
5
LUTOUT5
LUT OUT
4
LUTOUT4
LUT OUT
3
LUTOUT3
LUT OUT
2
LUTOUT2
LUT OUT
1
LUTOUT1
LUT OUT
0
LUTOUT0
LUT OUT
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2867

<!-- page 2868 -->

41.11.277
Each set mask bit enables one of the corresponding
flag input bits. There is one mask per 5x1 LUT.
(PXP_HW_PXP_WFE_B_STG2_5X1_MASKS)
Each set mask bit enables one of the corresponding flag input bits. There is one mask per
5x1 LUT.
Address: 21C_C000h base + 2580h offset = 21C_E580h
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
MASK3
0
MASK2
0
MASK1
0
MASK0
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
PXP_HW_PXP_WFE_B_STG2_5X1_MASKS field descriptions
Field
Description
31–29
Reserved
This read-only field is reserved and always has the value 0.
28–24
MASK3
This field selects the input flags that are valid for 5x1 LUT 1. Bit 0 = input 1, Bit 1 = input 2 and so on.
23–21
Reserved
This read-only field is reserved and always has the value 0.
20–16
MASK2
This field selects the input flags that are valid for 5x1 LUT 0. Bit 0 = input 1, Bit 1 = input 2 and so on.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
MASK1
This field selects the input flags that are valid for 5x1 LUT 1. Bit 0 = input 1, Bit 1 = input 2 and so on.
7–5
Reserved
This read-only field is reserved and always has the value 0.
MASK0
This field selects the input flags that are valid for 5x1 LUT 0. Bit 0 = input 1, Bit 1 = input 2 and so on.
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2868
NXP Semiconductors

<!-- page 2869 -->

41.11.278
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_0)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2590h offset = 21C_E590h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_0 field descriptions
Field
Description
31
LUTOUT31
LUT OUT
30
LUTOUT30
LUT OUT
29
LUTOUT29
LUT OUT
28
LUTOUT28
LUT OUT
27
LUTOUT27
LUT OUT
26
LUTOUT26
LUT OUT
25
LUTOUT25
LUT OUT
24
LUTOUT24
LUT OUT
23
LUTOUT23
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2869

<!-- page 2870 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_0 field descriptions (continued)
Field
Description
22
LUTOUT22
LUT OUT
21
LUTOUT21
LUT OUT
20
LUTOUT20
LUT OUT
19
LUTOUT19
LUT OUT
18
LUTOUT18
LUT OUT
17
LUTOUT17
LUT OUT
16
LUTOUT16
LUT OUT
15
LUTOUT15
LUT OUT
14
LUTOUT14
LUT OUT
13
LUTOUT13
LUT OUT
12
LUTOUT12
LUT OUT
11
LUTOUT11
LUT OUT
10
LUTOUT10
LUT OUT
9
LUTOUT9
LUT OUT
8
LUTOUT8
LUT OUT
7
LUTOUT7
LUT OUT
6
LUTOUT6
LUT OUT
5
LUTOUT5
LUT OUT
4
LUTOUT4
LUT OUT
3
LUTOUT3
LUT OUT
2
LUTOUT2
LUT OUT
1
LUTOUT1
LUT OUT
0
LUTOUT0
LUT OUT
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2870
NXP Semiconductors

<!-- page 2871 -->

41.11.279
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_1)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 25A0h offset = 21C_E5A0h
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
LUTOUT63
LUTOUT62
LUTOUT61
LUTOUT60
LUTOUT59
LUTOUT58
LUTOUT57
LUTOUT56
LUTOUT55
LUTOUT54
LUTOUT53
LUTOUT52
LUTOUT51
LUTOUT50
LUTOUT49
LUTOUT48
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
LUTOUT47
LUTOUT46
LUTOUT45
LUTOUT44
LUTOUT43
LUTOUT42
LUTOUT41
LUTOUT40
LUTOUT39
LUTOUT38
LUTOUT37
LUTOUT36
LUTOUT35
LUTOUT34
LUTOUT33
LUTOUT32
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
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_1 field descriptions
Field
Description
31
LUTOUT63
LUT OUT
30
LUTOUT62
LUT OUT
29
LUTOUT61
LUT OUT
28
LUTOUT60
LUT OUT
27
LUTOUT59
LUT OUT
26
LUTOUT58
LUT OUT
25
LUTOUT57
LUT OUT
24
LUTOUT56
LUT OUT
23
LUTOUT55
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2871

<!-- page 2872 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_1 field descriptions (continued)
Field
Description
22
LUTOUT54
LUT OUT
21
LUTOUT53
LUT OUT
20
LUTOUT52
LUT OUT
19
LUTOUT51
LUT OUT
18
LUTOUT50
LUT OUT
17
LUTOUT49
LUT OUT
16
LUTOUT48
LUT OUT
15
LUTOUT47
LUT OUT
14
LUTOUT46
LUT OUT
13
LUTOUT45
LUT OUT
12
LUTOUT44
LUT OUT
11
LUTOUT43
LUT OUT
10
LUTOUT42
LUT OUT
9
LUTOUT41
LUT OUT
8
LUTOUT40
LUT OUT
7
LUTOUT39
LUT OUT
6
LUTOUT38
LUT OUT
5
LUTOUT37
LUT OUT
4
LUTOUT36
LUT OUT
3
LUTOUT35
LUT OUT
2
LUTOUT34
LUT OUT
1
LUTOUT33
LUT OUT
0
LUTOUT32
LUT OUT
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2872
NXP Semiconductors

<!-- page 2873 -->

41.11.280
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_2)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 25B0h offset = 21C_E5B0h
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
LUTOUT95
LUTOUT94
LUTOUT93
LUTOUT92
LUTOUT91
LUTOUT90
LUTOUT89
LUTOUT88
LUTOUT87
LUTOUT86
LUTOUT85
LUTOUT84
LUTOUT83
LUTOUT82
LUTOUT81
LUTOUT80
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
LUTOUT79
LUTOUT78
LUTOUT77
LUTOUT76
LUTOUT75
LUTOUT74
LUTOUT73
LUTOUT72
LUTOUT71
LUTOUT70
LUTOUT69
LUTOUT68
LUTOUT67
LUTOUT66
LUTOUT65
LUTOUT64
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
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_2 field descriptions
Field
Description
31
LUTOUT95
LUT OUT
30
LUTOUT94
LUT OUT
29
LUTOUT93
LUT OUT
28
LUTOUT92
LUT OUT
27
LUTOUT91
LUT OUT
26
LUTOUT90
LUT OUT
25
LUTOUT89
LUT OUT
24
LUTOUT88
LUT OUT
23
LUTOUT87
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2873

<!-- page 2874 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_2 field descriptions (continued)
Field
Description
22
LUTOUT86
LUT OUT
21
LUTOUT85
LUT OUT
20
LUTOUT84
LUT OUT
19
LUTOUT83
LUT OUT
18
LUTOUT82
LUT OUT
17
LUTOUT81
LUT OUT
16
LUTOUT80
LUT OUT
15
LUTOUT79
LUT OUT
14
LUTOUT78
LUT OUT
13
LUTOUT77
LUT OUT
12
LUTOUT76
LUT OUT
11
LUTOUT75
LUT OUT
10
LUTOUT74
LUT OUT
9
LUTOUT73
LUT OUT
8
LUTOUT72
LUT OUT
7
LUTOUT71
LUT OUT
6
LUTOUT70
LUT OUT
5
LUTOUT69
LUT OUT
4
LUTOUT68
LUT OUT
3
LUTOUT67
LUT OUT
2
LUTOUT66
LUT OUT
1
LUTOUT65
LUT OUT
0
LUTOUT64
LUT OUT
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2874
NXP Semiconductors

<!-- page 2875 -->

41.11.281
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_3)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 25C0h offset = 21C_E5C0h
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
LUTOUT127
LUTOUT126
LUTOUT125
LUTOUT124
LUTOUT123
LUTOUT122
LUTOUT121
LUTOUT120
LUTOUT119
LUTOUT118
LUTOUT117
LUTOUT116
LUTOUT115
LUTOUT114
LUTOUT113
LUTOUT112
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
LUTOUT111
LUTOUT110
LUTOUT109
LUTOUT108
LUTOUT107
LUTOUT106
LUTOUT105
LUTOUT104
LUTOUT103
LUTOUT102
LUTOUT101
LUTOUT100
LUTOUT99
LUTOUT98
LUTOUT97
LUTOUT96
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
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_3 field descriptions
Field
Description
31
LUTOUT127
LUT OUT
30
LUTOUT126
LUT OUT
29
LUTOUT125
LUT OUT
28
LUTOUT124
LUT OUT
27
LUTOUT123
LUT OUT
26
LUTOUT122
LUT OUT
25
LUTOUT121
LUT OUT
24
LUTOUT120
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2875

<!-- page 2876 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_3 field descriptions (continued)
Field
Description
23
LUTOUT119
LUT OUT
22
LUTOUT118
LUT OUT
21
LUTOUT117
LUT OUT
20
LUTOUT116
LUT OUT
19
LUTOUT115
LUT OUT
18
LUTOUT114
LUT OUT
17
LUTOUT113
LUT OUT
16
LUTOUT112
LUT OUT
15
LUTOUT111
LUT OUT
14
LUTOUT110
LUT OUT
13
LUTOUT109
LUT OUT
12
LUTOUT108
LUT OUT
11
LUTOUT107
LUT OUT
10
LUTOUT106
LUT OUT
9
LUTOUT105
LUT OUT
8
LUTOUT104
LUT OUT
7
LUTOUT103
LUT OUT
6
LUTOUT102
LUT OUT
5
LUTOUT101
LUT OUT
4
LUTOUT100
LUT OUT
3
LUTOUT99
LUT OUT
2
LUTOUT98
LUT OUT
1
LUTOUT97
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2876
NXP Semiconductors

<!-- page 2877 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_3 field descriptions (continued)
Field
Description
0
LUTOUT96
LUT OUT
41.11.282
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_4)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 25D0h offset = 21C_E5D0h
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
LUTOUT159
LUTOUT158
LUTOUT157
LUTOUT156
LUTOUT155
LUTOUT154
LUTOUT153
LUTOUT152
LUTOUT151
LUTOUT150
LUTOUT149
LUTOUT148
LUTOUT147
LUTOUT146
LUTOUT145
LUTOUT144
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
LUTOUT143
LUTOUT142
LUTOUT141
LUTOUT140
LUTOUT139
LUTOUT138
LUTOUT137
LUTOUT136
LUTOUT135
LUTOUT134
LUTOUT133
LUTOUT132
LUTOUT131
LUTOUT130
LUTOUT129
LUTOUT128
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
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_4 field descriptions
Field
Description
31
LUTOUT159
LUT OUT
30
LUTOUT158
LUT OUT
29
LUTOUT157
LUT OUT
28
LUTOUT156
LUT OUT
27
LUTOUT155
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2877

<!-- page 2878 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_4 field descriptions (continued)
Field
Description
26
LUTOUT154
LUT OUT
25
LUTOUT153
LUT OUT
24
LUTOUT152
LUT OUT
23
LUTOUT151
LUT OUT
22
LUTOUT150
LUT OUT
21
LUTOUT149
LUT OUT
20
LUTOUT148
LUT OUT
19
LUTOUT147
LUT OUT
18
LUTOUT146
LUT OUT
17
LUTOUT145
LUT OUT
16
LUTOUT144
LUT OUT
15
LUTOUT143
LUT OUT
14
LUTOUT142
LUT OUT
13
LUTOUT141
LUT OUT
12
LUTOUT140
LUT OUT
11
LUTOUT139
LUT OUT
10
LUTOUT138
LUT OUT
9
LUTOUT137
LUT OUT
8
LUTOUT136
LUT OUT
7
LUTOUT135
LUT OUT
6
LUTOUT134
LUT OUT
5
LUTOUT133
LUT OUT
4
LUTOUT132
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2878
NXP Semiconductors

<!-- page 2879 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_4 field descriptions (continued)
Field
Description
3
LUTOUT131
LUT OUT
2
LUTOUT130
LUT OUT
1
LUTOUT129
LUT OUT
0
LUTOUT128
LUT OUT
41.11.283
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_5)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 25E0h offset = 21C_E5E0h
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
LUTOUT191
LUTOUT190
LUTOUT189
LUTOUT188
LUTOUT187
LUTOUT186
LUTOUT185
LUTOUT184
LUTOUT183
LUTOUT182
LUTOUT181
LUTOUT180
LUTOUT179
LUTOUT178
LUTOUT177
LUTOUT176
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
LUTOUT175
LUTOUT174
LUTOUT173
LUTOUT172
LUTOUT171
LUTOUT170
LUTOUT169
LUTOUT168
LUTOUT167
LUTOUT166
LUTOUT165
LUTOUT164
LUTOUT163
LUTOUT162
LUTOUT161
LUTOUT160
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
PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_5 field descriptions
Field
Description
31
LUTOUT191
LUT OUT
30
LUTOUT190
LUT OUT
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2879

<!-- page 2880 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_5 field descriptions (continued)
Field
Description
29
LUTOUT189
LUT OUT
28
LUTOUT188
LUT OUT
27
LUTOUT187
LUT OUT
26
LUTOUT186
LUT OUT
25
LUTOUT185
LUT OUT
24
LUTOUT184
LUT OUT
23
LUTOUT183
LUT OUT
22
LUTOUT182
LUT OUT
21
LUTOUT181
LUT OUT
20
LUTOUT180
LUT OUT
19
LUTOUT179
LUT OUT
18
LUTOUT178
LUT OUT
17
LUTOUT177
LUT OUT
16
LUTOUT176
LUT OUT
15
LUTOUT175
LUT OUT
14
LUTOUT174
LUT OUT
13
LUTOUT173
LUT OUT
12
LUTOUT172
LUT OUT
11
LUTOUT171
LUT OUT
10
LUTOUT170
LUT OUT
9
LUTOUT169
LUT OUT
8
LUTOUT168
LUT OUT
7
LUTOUT167
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2880
NXP Semiconductors

<!-- page 2881 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_5 field descriptions (continued)
Field
Description
6
LUTOUT166
LUT OUT
5
LUTOUT165
LUT OUT
4
LUTOUT164
LUT OUT
3
LUTOUT163
LUT OUT
2
LUTOUT162
LUT OUT
1
LUTOUT161
LUT OUT
0
LUTOUT160
LUT OUT
41.11.284
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_6)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 25F0h offset = 21C_E5F0h
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
LUTOUT223
LUTOUT222
LUTOUT221
LUTOUT220
LUTOUT219
LUTOUT218
LUTOUT217
LUTOUT216
LUTOUT215
LUTOUT214
LUTOUT213
LUTOUT212
LUTOUT211
LUTOUT210
LUTOUT209
LUTOUT208
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
LUTOUT207
LUTOUT206
LUTOUT205
LUTOUT204
LUTOUT203
LUTOUT202
LUTOUT201
LUTOUT200
LUTOUT199
LUTOUT198
LUTOUT197
LUTOUT196
LUTOUT195
LUTOUT194
LUTOUT193
LUTOUT192
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2881

<!-- page 2882 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_6 field descriptions
Field
Description
31
LUTOUT223
LUT OUT
30
LUTOUT222
LUT OUT
29
LUTOUT221
LUT OUT
28
LUTOUT220
LUT OUT
27
LUTOUT219
LUT OUT
26
LUTOUT218
LUT OUT
25
LUTOUT217
LUT OUT
24
LUTOUT216
LUT OUT
23
LUTOUT215
LUT OUT
22
LUTOUT214
LUT OUT
21
LUTOUT213
LUT OUT
20
LUTOUT212
LUT OUT
19
LUTOUT211
LUT OUT
18
LUTOUT210
LUT OUT
17
LUTOUT209
LUT OUT
16
LUTOUT208
LUT OUT
15
LUTOUT207
LUT OUT
14
LUTOUT206
LUT OUT
13
LUTOUT205
LUT OUT
12
LUTOUT204
LUT OUT
11
LUTOUT203
LUT OUT
10
LUTOUT202
LUT OUT
9
LUTOUT201
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2882
NXP Semiconductors

<!-- page 2883 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_6 field descriptions (continued)
Field
Description
8
LUTOUT200
LUT OUT
7
LUTOUT199
LUT OUT
6
LUTOUT198
LUT OUT
5
LUTOUT197
LUT OUT
4
LUTOUT196
LUT OUT
3
LUTOUT195
LUT OUT
2
LUTOUT194
LUT OUT
1
LUTOUT193
LUT OUT
0
LUTOUT192
LUT OUT
41.11.285
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_7)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2600h offset = 21C_E600h
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
LUTOUT255
LUTOUT254
LUTOUT253
LUTOUT252
LUTOUT251
LUTOUT250
LUTOUT249
LUTOUT248
LUTOUT247
LUTOUT246
LUTOUT245
LUTOUT244
LUTOUT243
LUTOUT242
LUTOUT241
LUTOUT240
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
LUTOUT239
LUTOUT238
LUTOUT237
LUTOUT236
LUTOUT235
LUTOUT234
LUTOUT233
LUTOUT232
LUTOUT231
LUTOUT230
LUTOUT229
LUTOUT228
LUTOUT227
LUTOUT226
LUTOUT225
LUTOUT224
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2883

<!-- page 2884 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_7 field descriptions
Field
Description
31
LUTOUT255
LUT OUT
30
LUTOUT254
LUT OUT
29
LUTOUT253
LUT OUT
28
LUTOUT252
LUT OUT
27
LUTOUT251
LUT OUT
26
LUTOUT250
LUT OUT
25
LUTOUT249
LUT OUT
24
LUTOUT248
LUT OUT
23
LUTOUT247
LUT OUT
22
LUTOUT246
LUT OUT
21
LUTOUT245
LUT OUT
20
LUTOUT244
LUT OUT
19
LUTOUT243
LUT OUT
18
LUTOUT242
LUT OUT
17
LUTOUT241
LUT OUT
16
LUTOUT240
LUT OUT
15
LUTOUT239
LUT OUT
14
LUTOUT238
LUT OUT
13
LUTOUT237
LUT OUT
12
LUTOUT236
LUT OUT
11
LUTOUT235
LUT OUT
10
LUTOUT234
LUT OUT
9
LUTOUT233
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2884
NXP Semiconductors

<!-- page 2885 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT0_7 field descriptions (continued)
Field
Description
8
LUTOUT232
LUT OUT
7
LUTOUT231
LUT OUT
6
LUTOUT230
LUT OUT
5
LUTOUT229
LUT OUT
4
LUTOUT228
LUT OUT
3
LUTOUT227
LUT OUT
2
LUTOUT226
LUT OUT
1
LUTOUT225
LUT OUT
0
LUTOUT224
LUT OUT
41.11.286
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_0)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2610h offset = 21C_E610h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2885

<!-- page 2886 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_0 field descriptions
Field
Description
31
LUTOUT31
LUT OUT
30
LUTOUT30
LUT OUT
29
LUTOUT29
LUT OUT
28
LUTOUT28
LUT OUT
27
LUTOUT27
LUT OUT
26
LUTOUT26
LUT OUT
25
LUTOUT25
LUT OUT
24
LUTOUT24
LUT OUT
23
LUTOUT23
LUT OUT
22
LUTOUT22
LUT OUT
21
LUTOUT21
LUT OUT
20
LUTOUT20
LUT OUT
19
LUTOUT19
LUT OUT
18
LUTOUT18
LUT OUT
17
LUTOUT17
LUT OUT
16
LUTOUT16
LUT OUT
15
LUTOUT15
LUT OUT
14
LUTOUT14
LUT OUT
13
LUTOUT13
LUT OUT
12
LUTOUT12
LUT OUT
11
LUTOUT11
LUT OUT
10
LUTOUT10
LUT OUT
9
LUTOUT9
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2886
NXP Semiconductors

<!-- page 2887 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_0 field descriptions (continued)
Field
Description
8
LUTOUT8
LUT OUT
7
LUTOUT7
LUT OUT
6
LUTOUT6
LUT OUT
5
LUTOUT5
LUT OUT
4
LUTOUT4
LUT OUT
3
LUTOUT3
LUT OUT
2
LUTOUT2
LUT OUT
1
LUTOUT1
LUT OUT
0
LUTOUT0
LUT OUT
41.11.287
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_1)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2620h offset = 21C_E620h
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
LUTOUT63
LUTOUT62
LUTOUT61
LUTOUT60
LUTOUT59
LUTOUT58
LUTOUT57
LUTOUT56
LUTOUT55
LUTOUT54
LUTOUT53
LUTOUT52
LUTOUT51
LUTOUT50
LUTOUT49
LUTOUT48
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
LUTOUT47
LUTOUT46
LUTOUT45
LUTOUT44
LUTOUT43
LUTOUT42
LUTOUT41
LUTOUT40
LUTOUT39
LUTOUT38
LUTOUT37
LUTOUT36
LUTOUT35
LUTOUT34
LUTOUT33
LUTOUT32
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2887

<!-- page 2888 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_1 field descriptions
Field
Description
31
LUTOUT63
LUT OUT
30
LUTOUT62
LUT OUT
29
LUTOUT61
LUT OUT
28
LUTOUT60
LUT OUT
27
LUTOUT59
LUT OUT
26
LUTOUT58
LUT OUT
25
LUTOUT57
LUT OUT
24
LUTOUT56
LUT OUT
23
LUTOUT55
LUT OUT
22
LUTOUT54
LUT OUT
21
LUTOUT53
LUT OUT
20
LUTOUT52
LUT OUT
19
LUTOUT51
LUT OUT
18
LUTOUT50
LUT OUT
17
LUTOUT49
LUT OUT
16
LUTOUT48
LUT OUT
15
LUTOUT47
LUT OUT
14
LUTOUT46
LUT OUT
13
LUTOUT45
LUT OUT
12
LUTOUT44
LUT OUT
11
LUTOUT43
LUT OUT
10
LUTOUT42
LUT OUT
9
LUTOUT41
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2888
NXP Semiconductors

<!-- page 2889 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_1 field descriptions (continued)
Field
Description
8
LUTOUT40
LUT OUT
7
LUTOUT39
LUT OUT
6
LUTOUT38
LUT OUT
5
LUTOUT37
LUT OUT
4
LUTOUT36
LUT OUT
3
LUTOUT35
LUT OUT
2
LUTOUT34
LUT OUT
1
LUTOUT33
LUT OUT
0
LUTOUT32
LUT OUT
41.11.288
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_2)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2630h offset = 21C_E630h
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
LUTOUT95
LUTOUT94
LUTOUT93
LUTOUT92
LUTOUT91
LUTOUT90
LUTOUT89
LUTOUT88
LUTOUT87
LUTOUT86
LUTOUT85
LUTOUT84
LUTOUT83
LUTOUT82
LUTOUT81
LUTOUT80
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
LUTOUT79
LUTOUT78
LUTOUT77
LUTOUT76
LUTOUT75
LUTOUT74
LUTOUT73
LUTOUT72
LUTOUT71
LUTOUT70
LUTOUT69
LUTOUT68
LUTOUT67
LUTOUT66
LUTOUT65
LUTOUT64
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2889

<!-- page 2890 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_2 field descriptions
Field
Description
31
LUTOUT95
LUT OUT
30
LUTOUT94
LUT OUT
29
LUTOUT93
LUT OUT
28
LUTOUT92
LUT OUT
27
LUTOUT91
LUT OUT
26
LUTOUT90
LUT OUT
25
LUTOUT89
LUT OUT
24
LUTOUT88
LUT OUT
23
LUTOUT87
LUT OUT
22
LUTOUT86
LUT OUT
21
LUTOUT85
LUT OUT
20
LUTOUT84
LUT OUT
19
LUTOUT83
LUT OUT
18
LUTOUT82
LUT OUT
17
LUTOUT81
LUT OUT
16
LUTOUT80
LUT OUT
15
LUTOUT79
LUT OUT
14
LUTOUT78
LUT OUT
13
LUTOUT77
LUT OUT
12
LUTOUT76
LUT OUT
11
LUTOUT75
LUT OUT
10
LUTOUT74
LUT OUT
9
LUTOUT73
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2890
NXP Semiconductors

<!-- page 2891 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_2 field descriptions (continued)
Field
Description
8
LUTOUT72
LUT OUT
7
LUTOUT71
LUT OUT
6
LUTOUT70
LUT OUT
5
LUTOUT69
LUT OUT
4
LUTOUT68
LUT OUT
3
LUTOUT67
LUT OUT
2
LUTOUT66
LUT OUT
1
LUTOUT65
LUT OUT
0
LUTOUT64
LUT OUT
41.11.289
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_3)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2640h offset = 21C_E640h
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
LUTOUT127
LUTOUT126
LUTOUT125
LUTOUT124
LUTOUT123
LUTOUT122
LUTOUT121
LUTOUT120
LUTOUT119
LUTOUT118
LUTOUT117
LUTOUT116
LUTOUT115
LUTOUT114
LUTOUT113
LUTOUT112
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
LUTOUT111
LUTOUT110
LUTOUT109
LUTOUT108
LUTOUT107
LUTOUT106
LUTOUT105
LUTOUT104
LUTOUT103
LUTOUT102
LUTOUT101
LUTOUT100
LUTOUT99
LUTOUT98
LUTOUT97
LUTOUT96
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2891

<!-- page 2892 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_3 field descriptions
Field
Description
31
LUTOUT127
LUT OUT
30
LUTOUT126
LUT OUT
29
LUTOUT125
LUT OUT
28
LUTOUT124
LUT OUT
27
LUTOUT123
LUT OUT
26
LUTOUT122
LUT OUT
25
LUTOUT121
LUT OUT
24
LUTOUT120
LUT OUT
23
LUTOUT119
LUT OUT
22
LUTOUT118
LUT OUT
21
LUTOUT117
LUT OUT
20
LUTOUT116
LUT OUT
19
LUTOUT115
LUT OUT
18
LUTOUT114
LUT OUT
17
LUTOUT113
LUT OUT
16
LUTOUT112
LUT OUT
15
LUTOUT111
LUT OUT
14
LUTOUT110
LUT OUT
13
LUTOUT109
LUT OUT
12
LUTOUT108
LUT OUT
11
LUTOUT107
LUT OUT
10
LUTOUT106
LUT OUT
9
LUTOUT105
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2892
NXP Semiconductors

<!-- page 2893 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_3 field descriptions (continued)
Field
Description
8
LUTOUT104
LUT OUT
7
LUTOUT103
LUT OUT
6
LUTOUT102
LUT OUT
5
LUTOUT101
LUT OUT
4
LUTOUT100
LUT OUT
3
LUTOUT99
LUT OUT
2
LUTOUT98
LUT OUT
1
LUTOUT97
LUT OUT
0
LUTOUT96
LUT OUT
41.11.290
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_4)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2650h offset = 21C_E650h
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
LUTOUT159
LUTOUT158
LUTOUT157
LUTOUT156
LUTOUT155
LUTOUT154
LUTOUT153
LUTOUT152
LUTOUT151
LUTOUT150
LUTOUT149
LUTOUT148
LUTOUT147
LUTOUT146
LUTOUT145
LUTOUT144
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
LUTOUT143
LUTOUT142
LUTOUT141
LUTOUT140
LUTOUT139
LUTOUT138
LUTOUT137
LUTOUT136
LUTOUT135
LUTOUT134
LUTOUT133
LUTOUT132
LUTOUT131
LUTOUT130
LUTOUT129
LUTOUT128
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2893

<!-- page 2894 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_4 field descriptions
Field
Description
31
LUTOUT159
LUT OUT
30
LUTOUT158
LUT OUT
29
LUTOUT157
LUT OUT
28
LUTOUT156
LUT OUT
27
LUTOUT155
LUT OUT
26
LUTOUT154
LUT OUT
25
LUTOUT153
LUT OUT
24
LUTOUT152
LUT OUT
23
LUTOUT151
LUT OUT
22
LUTOUT150
LUT OUT
21
LUTOUT149
LUT OUT
20
LUTOUT148
LUT OUT
19
LUTOUT147
LUT OUT
18
LUTOUT146
LUT OUT
17
LUTOUT145
LUT OUT
16
LUTOUT144
LUT OUT
15
LUTOUT143
LUT OUT
14
LUTOUT142
LUT OUT
13
LUTOUT141
LUT OUT
12
LUTOUT140
LUT OUT
11
LUTOUT139
LUT OUT
10
LUTOUT138
LUT OUT
9
LUTOUT137
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2894
NXP Semiconductors

<!-- page 2895 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_4 field descriptions (continued)
Field
Description
8
LUTOUT136
LUT OUT
7
LUTOUT135
LUT OUT
6
LUTOUT134
LUT OUT
5
LUTOUT133
LUT OUT
4
LUTOUT132
LUT OUT
3
LUTOUT131
LUT OUT
2
LUTOUT130
LUT OUT
1
LUTOUT129
LUT OUT
0
LUTOUT128
LUT OUT
41.11.291
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_5)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2660h offset = 21C_E660h
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
LUTOUT191
LUTOUT190
LUTOUT189
LUTOUT188
LUTOUT187
LUTOUT186
LUTOUT185
LUTOUT184
LUTOUT183
LUTOUT182
LUTOUT181
LUTOUT180
LUTOUT179
LUTOUT178
LUTOUT177
LUTOUT176
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
LUTOUT175
LUTOUT174
LUTOUT173
LUTOUT172
LUTOUT171
LUTOUT170
LUTOUT169
LUTOUT168
LUTOUT167
LUTOUT166
LUTOUT165
LUTOUT164
LUTOUT163
LUTOUT162
LUTOUT161
LUTOUT160
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2895

<!-- page 2896 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_5 field descriptions
Field
Description
31
LUTOUT191
LUT OUT
30
LUTOUT190
LUT OUT
29
LUTOUT189
LUT OUT
28
LUTOUT188
LUT OUT
27
LUTOUT187
LUT OUT
26
LUTOUT186
LUT OUT
25
LUTOUT185
LUT OUT
24
LUTOUT184
LUT OUT
23
LUTOUT183
LUT OUT
22
LUTOUT182
LUT OUT
21
LUTOUT181
LUT OUT
20
LUTOUT180
LUT OUT
19
LUTOUT179
LUT OUT
18
LUTOUT178
LUT OUT
17
LUTOUT177
LUT OUT
16
LUTOUT176
LUT OUT
15
LUTOUT175
LUT OUT
14
LUTOUT174
LUT OUT
13
LUTOUT173
LUT OUT
12
LUTOUT172
LUT OUT
11
LUTOUT171
LUT OUT
10
LUTOUT170
LUT OUT
9
LUTOUT169
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2896
NXP Semiconductors

<!-- page 2897 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_5 field descriptions (continued)
Field
Description
8
LUTOUT168
LUT OUT
7
LUTOUT167
LUT OUT
6
LUTOUT166
LUT OUT
5
LUTOUT165
LUT OUT
4
LUTOUT164
LUT OUT
3
LUTOUT163
LUT OUT
2
LUTOUT162
LUT OUT
1
LUTOUT161
LUT OUT
0
LUTOUT160
LUT OUT
41.11.292
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_6)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2670h offset = 21C_E670h
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
LUTOUT223
LUTOUT222
LUTOUT221
LUTOUT220
LUTOUT219
LUTOUT218
LUTOUT217
LUTOUT216
LUTOUT215
LUTOUT214
LUTOUT213
LUTOUT212
LUTOUT211
LUTOUT210
LUTOUT209
LUTOUT208
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
LUTOUT207
LUTOUT206
LUTOUT205
LUTOUT204
LUTOUT203
LUTOUT202
LUTOUT201
LUTOUT200
LUTOUT199
LUTOUT198
LUTOUT197
LUTOUT196
LUTOUT195
LUTOUT194
LUTOUT193
LUTOUT192
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2897

<!-- page 2898 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_6 field descriptions
Field
Description
31
LUTOUT223
LUT OUT
30
LUTOUT222
LUT OUT
29
LUTOUT221
LUT OUT
28
LUTOUT220
LUT OUT
27
LUTOUT219
LUT OUT
26
LUTOUT218
LUT OUT
25
LUTOUT217
LUT OUT
24
LUTOUT216
LUT OUT
23
LUTOUT215
LUT OUT
22
LUTOUT214
LUT OUT
21
LUTOUT213
LUT OUT
20
LUTOUT212
LUT OUT
19
LUTOUT211
LUT OUT
18
LUTOUT210
LUT OUT
17
LUTOUT209
LUT OUT
16
LUTOUT208
LUT OUT
15
LUTOUT207
LUT OUT
14
LUTOUT206
LUT OUT
13
LUTOUT205
LUT OUT
12
LUTOUT204
LUT OUT
11
LUTOUT203
LUT OUT
10
LUTOUT202
LUT OUT
9
LUTOUT201
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2898
NXP Semiconductors

<!-- page 2899 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_6 field descriptions (continued)
Field
Description
8
LUTOUT200
LUT OUT
7
LUTOUT199
LUT OUT
6
LUTOUT198
LUT OUT
5
LUTOUT197
LUT OUT
4
LUTOUT196
LUT OUT
3
LUTOUT195
LUT OUT
2
LUTOUT194
LUT OUT
1
LUTOUT193
LUT OUT
0
LUTOUT192
LUT OUT
41.11.293
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_7)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2680h offset = 21C_E680h
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
LUTOUT255
LUTOUT254
LUTOUT253
LUTOUT252
LUTOUT251
LUTOUT250
LUTOUT249
LUTOUT248
LUTOUT247
LUTOUT246
LUTOUT245
LUTOUT244
LUTOUT243
LUTOUT242
LUTOUT241
LUTOUT240
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
LUTOUT239
LUTOUT238
LUTOUT237
LUTOUT236
LUTOUT235
LUTOUT234
LUTOUT233
LUTOUT232
LUTOUT231
LUTOUT230
LUTOUT229
LUTOUT228
LUTOUT227
LUTOUT226
LUTOUT225
LUTOUT224
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2899

<!-- page 2900 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_7 field descriptions
Field
Description
31
LUTOUT255
LUT OUT
30
LUTOUT254
LUT OUT
29
LUTOUT253
LUT OUT
28
LUTOUT252
LUT OUT
27
LUTOUT251
LUT OUT
26
LUTOUT250
LUT OUT
25
LUTOUT249
LUT OUT
24
LUTOUT248
LUT OUT
23
LUTOUT247
LUT OUT
22
LUTOUT246
LUT OUT
21
LUTOUT245
LUT OUT
20
LUTOUT244
LUT OUT
19
LUTOUT243
LUT OUT
18
LUTOUT242
LUT OUT
17
LUTOUT241
LUT OUT
16
LUTOUT240
LUT OUT
15
LUTOUT239
LUT OUT
14
LUTOUT238
LUT OUT
13
LUTOUT237
LUT OUT
12
LUTOUT236
LUT OUT
11
LUTOUT235
LUT OUT
10
LUTOUT234
LUT OUT
9
LUTOUT233
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2900
NXP Semiconductors

<!-- page 2901 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT1_7 field descriptions (continued)
Field
Description
8
LUTOUT232
LUT OUT
7
LUTOUT231
LUT OUT
6
LUTOUT230
LUT OUT
5
LUTOUT229
LUT OUT
4
LUTOUT228
LUT OUT
3
LUTOUT227
LUT OUT
2
LUTOUT226
LUT OUT
1
LUTOUT225
LUT OUT
0
LUTOUT224
LUT OUT
41.11.294
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_0)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2690h offset = 21C_E690h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2901

<!-- page 2902 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_0 field descriptions
Field
Description
31
LUTOUT31
LUT OUT
30
LUTOUT30
LUT OUT
29
LUTOUT29
LUT OUT
28
LUTOUT28
LUT OUT
27
LUTOUT27
LUT OUT
26
LUTOUT26
LUT OUT
25
LUTOUT25
LUT OUT
24
LUTOUT24
LUT OUT
23
LUTOUT23
LUT OUT
22
LUTOUT22
LUT OUT
21
LUTOUT21
LUT OUT
20
LUTOUT20
LUT OUT
19
LUTOUT19
LUT OUT
18
LUTOUT18
LUT OUT
17
LUTOUT17
LUT OUT
16
LUTOUT16
LUT OUT
15
LUTOUT15
LUT OUT
14
LUTOUT14
LUT OUT
13
LUTOUT13
LUT OUT
12
LUTOUT12
LUT OUT
11
LUTOUT11
LUT OUT
10
LUTOUT10
LUT OUT
9
LUTOUT9
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2902
NXP Semiconductors

<!-- page 2903 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_0 field descriptions (continued)
Field
Description
8
LUTOUT8
LUT OUT
7
LUTOUT7
LUT OUT
6
LUTOUT6
LUT OUT
5
LUTOUT5
LUT OUT
4
LUTOUT4
LUT OUT
3
LUTOUT3
LUT OUT
2
LUTOUT2
LUT OUT
1
LUTOUT1
LUT OUT
0
LUTOUT0
LUT OUT
41.11.295
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_1)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 26A0h offset = 21C_E6A0h
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
LUTOUT63
LUTOUT62
LUTOUT61
LUTOUT60
LUTOUT59
LUTOUT58
LUTOUT57
LUTOUT56
LUTOUT55
LUTOUT54
LUTOUT53
LUTOUT52
LUTOUT51
LUTOUT50
LUTOUT49
LUTOUT48
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
LUTOUT47
LUTOUT46
LUTOUT45
LUTOUT44
LUTOUT43
LUTOUT42
LUTOUT41
LUTOUT40
LUTOUT39
LUTOUT38
LUTOUT37
LUTOUT36
LUTOUT35
LUTOUT34
LUTOUT33
LUTOUT32
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2903

<!-- page 2904 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_1 field descriptions
Field
Description
31
LUTOUT63
LUT OUT
30
LUTOUT62
LUT OUT
29
LUTOUT61
LUT OUT
28
LUTOUT60
LUT OUT
27
LUTOUT59
LUT OUT
26
LUTOUT58
LUT OUT
25
LUTOUT57
LUT OUT
24
LUTOUT56
LUT OUT
23
LUTOUT55
LUT OUT
22
LUTOUT54
LUT OUT
21
LUTOUT53
LUT OUT
20
LUTOUT52
LUT OUT
19
LUTOUT51
LUT OUT
18
LUTOUT50
LUT OUT
17
LUTOUT49
LUT OUT
16
LUTOUT48
LUT OUT
15
LUTOUT47
LUT OUT
14
LUTOUT46
LUT OUT
13
LUTOUT45
LUT OUT
12
LUTOUT44
LUT OUT
11
LUTOUT43
LUT OUT
10
LUTOUT42
LUT OUT
9
LUTOUT41
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2904
NXP Semiconductors

<!-- page 2905 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_1 field descriptions (continued)
Field
Description
8
LUTOUT40
LUT OUT
7
LUTOUT39
LUT OUT
6
LUTOUT38
LUT OUT
5
LUTOUT37
LUT OUT
4
LUTOUT36
LUT OUT
3
LUTOUT35
LUT OUT
2
LUTOUT34
LUT OUT
1
LUTOUT33
LUT OUT
0
LUTOUT32
LUT OUT
41.11.296
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_2)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 26B0h offset = 21C_E6B0h
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
LUTOUT95
LUTOUT94
LUTOUT93
LUTOUT92
LUTOUT91
LUTOUT90
LUTOUT89
LUTOUT88
LUTOUT87
LUTOUT86
LUTOUT85
LUTOUT84
LUTOUT83
LUTOUT82
LUTOUT81
LUTOUT80
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
LUTOUT79
LUTOUT78
LUTOUT77
LUTOUT76
LUTOUT75
LUTOUT74
LUTOUT73
LUTOUT72
LUTOUT71
LUTOUT70
LUTOUT69
LUTOUT68
LUTOUT67
LUTOUT66
LUTOUT65
LUTOUT64
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2905

<!-- page 2906 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_2 field descriptions
Field
Description
31
LUTOUT95
LUT OUT
30
LUTOUT94
LUT OUT
29
LUTOUT93
LUT OUT
28
LUTOUT92
LUT OUT
27
LUTOUT91
LUT OUT
26
LUTOUT90
LUT OUT
25
LUTOUT89
LUT OUT
24
LUTOUT88
LUT OUT
23
LUTOUT87
LUT OUT
22
LUTOUT86
LUT OUT
21
LUTOUT85
LUT OUT
20
LUTOUT84
LUT OUT
19
LUTOUT83
LUT OUT
18
LUTOUT82
LUT OUT
17
LUTOUT81
LUT OUT
16
LUTOUT80
LUT OUT
15
LUTOUT79
LUT OUT
14
LUTOUT78
LUT OUT
13
LUTOUT77
LUT OUT
12
LUTOUT76
LUT OUT
11
LUTOUT75
LUT OUT
10
LUTOUT74
LUT OUT
9
LUTOUT73
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2906
NXP Semiconductors

<!-- page 2907 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_2 field descriptions (continued)
Field
Description
8
LUTOUT72
LUT OUT
7
LUTOUT71
LUT OUT
6
LUTOUT70
LUT OUT
5
LUTOUT69
LUT OUT
4
LUTOUT68
LUT OUT
3
LUTOUT67
LUT OUT
2
LUTOUT66
LUT OUT
1
LUTOUT65
LUT OUT
0
LUTOUT64
LUT OUT
41.11.297
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_3)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 26C0h offset = 21C_E6C0h
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
LUTOUT127
LUTOUT126
LUTOUT125
LUTOUT124
LUTOUT123
LUTOUT122
LUTOUT121
LUTOUT120
LUTOUT119
LUTOUT118
LUTOUT117
LUTOUT116
LUTOUT115
LUTOUT114
LUTOUT113
LUTOUT112
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
LUTOUT111
LUTOUT110
LUTOUT109
LUTOUT108
LUTOUT107
LUTOUT106
LUTOUT105
LUTOUT104
LUTOUT103
LUTOUT102
LUTOUT101
LUTOUT100
LUTOUT99
LUTOUT98
LUTOUT97
LUTOUT96
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2907

<!-- page 2908 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_3 field descriptions
Field
Description
31
LUTOUT127
LUT OUT
30
LUTOUT126
LUT OUT
29
LUTOUT125
LUT OUT
28
LUTOUT124
LUT OUT
27
LUTOUT123
LUT OUT
26
LUTOUT122
LUT OUT
25
LUTOUT121
LUT OUT
24
LUTOUT120
LUT OUT
23
LUTOUT119
LUT OUT
22
LUTOUT118
LUT OUT
21
LUTOUT117
LUT OUT
20
LUTOUT116
LUT OUT
19
LUTOUT115
LUT OUT
18
LUTOUT114
LUT OUT
17
LUTOUT113
LUT OUT
16
LUTOUT112
LUT OUT
15
LUTOUT111
LUT OUT
14
LUTOUT110
LUT OUT
13
LUTOUT109
LUT OUT
12
LUTOUT108
LUT OUT
11
LUTOUT107
LUT OUT
10
LUTOUT106
LUT OUT
9
LUTOUT105
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2908
NXP Semiconductors

<!-- page 2909 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_3 field descriptions (continued)
Field
Description
8
LUTOUT104
LUT OUT
7
LUTOUT103
LUT OUT
6
LUTOUT102
LUT OUT
5
LUTOUT101
LUT OUT
4
LUTOUT100
LUT OUT
3
LUTOUT99
LUT OUT
2
LUTOUT98
LUT OUT
1
LUTOUT97
LUT OUT
0
LUTOUT96
LUT OUT
41.11.298
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_4)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 26D0h offset = 21C_E6D0h
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
LUTOUT159
LUTOUT158
LUTOUT157
LUTOUT156
LUTOUT155
LUTOUT154
LUTOUT153
LUTOUT152
LUTOUT151
LUTOUT150
LUTOUT149
LUTOUT148
LUTOUT147
LUTOUT146
LUTOUT145
LUTOUT144
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
LUTOUT143
LUTOUT142
LUTOUT141
LUTOUT140
LUTOUT139
LUTOUT138
LUTOUT137
LUTOUT136
LUTOUT135
LUTOUT134
LUTOUT133
LUTOUT132
LUTOUT131
LUTOUT130
LUTOUT129
LUTOUT128
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2909

<!-- page 2910 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_4 field descriptions
Field
Description
31
LUTOUT159
LUT OUT
30
LUTOUT158
LUT OUT
29
LUTOUT157
LUT OUT
28
LUTOUT156
LUT OUT
27
LUTOUT155
LUT OUT
26
LUTOUT154
LUT OUT
25
LUTOUT153
LUT OUT
24
LUTOUT152
LUT OUT
23
LUTOUT151
LUT OUT
22
LUTOUT150
LUT OUT
21
LUTOUT149
LUT OUT
20
LUTOUT148
LUT OUT
19
LUTOUT147
LUT OUT
18
LUTOUT146
LUT OUT
17
LUTOUT145
LUT OUT
16
LUTOUT144
LUT OUT
15
LUTOUT143
LUT OUT
14
LUTOUT142
LUT OUT
13
LUTOUT141
LUT OUT
12
LUTOUT140
LUT OUT
11
LUTOUT139
LUT OUT
10
LUTOUT138
LUT OUT
9
LUTOUT137
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2910
NXP Semiconductors

<!-- page 2911 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_4 field descriptions (continued)
Field
Description
8
LUTOUT136
LUT OUT
7
LUTOUT135
LUT OUT
6
LUTOUT134
LUT OUT
5
LUTOUT133
LUT OUT
4
LUTOUT132
LUT OUT
3
LUTOUT131
LUT OUT
2
LUTOUT130
LUT OUT
1
LUTOUT129
LUT OUT
0
LUTOUT128
LUT OUT
41.11.299
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_5)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 26E0h offset = 21C_E6E0h
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
LUTOUT191
LUTOUT190
LUTOUT189
LUTOUT188
LUTOUT187
LUTOUT186
LUTOUT185
LUTOUT184
LUTOUT183
LUTOUT182
LUTOUT181
LUTOUT180
LUTOUT179
LUTOUT178
LUTOUT177
LUTOUT176
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
LUTOUT175
LUTOUT174
LUTOUT173
LUTOUT172
LUTOUT171
LUTOUT170
LUTOUT169
LUTOUT168
LUTOUT167
LUTOUT166
LUTOUT165
LUTOUT164
LUTOUT163
LUTOUT162
LUTOUT161
LUTOUT160
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2911

<!-- page 2912 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_5 field descriptions
Field
Description
31
LUTOUT191
LUT OUT
30
LUTOUT190
LUT OUT
29
LUTOUT189
LUT OUT
28
LUTOUT188
LUT OUT
27
LUTOUT187
LUT OUT
26
LUTOUT186
LUT OUT
25
LUTOUT185
LUT OUT
24
LUTOUT184
LUT OUT
23
LUTOUT183
LUT OUT
22
LUTOUT182
LUT OUT
21
LUTOUT181
LUT OUT
20
LUTOUT180
LUT OUT
19
LUTOUT179
LUT OUT
18
LUTOUT178
LUT OUT
17
LUTOUT177
LUT OUT
16
LUTOUT176
LUT OUT
15
LUTOUT175
LUT OUT
14
LUTOUT174
LUT OUT
13
LUTOUT173
LUT OUT
12
LUTOUT172
LUT OUT
11
LUTOUT171
LUT OUT
10
LUTOUT170
LUT OUT
9
LUTOUT169
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2912
NXP Semiconductors

<!-- page 2913 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_5 field descriptions (continued)
Field
Description
8
LUTOUT168
LUT OUT
7
LUTOUT167
LUT OUT
6
LUTOUT166
LUT OUT
5
LUTOUT165
LUT OUT
4
LUTOUT164
LUT OUT
3
LUTOUT163
LUT OUT
2
LUTOUT162
LUT OUT
1
LUTOUT161
LUT OUT
0
LUTOUT160
LUT OUT
41.11.300
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_6)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 26F0h offset = 21C_E6F0h
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
LUTOUT223
LUTOUT222
LUTOUT221
LUTOUT220
LUTOUT219
LUTOUT218
LUTOUT217
LUTOUT216
LUTOUT215
LUTOUT214
LUTOUT213
LUTOUT212
LUTOUT211
LUTOUT210
LUTOUT209
LUTOUT208
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
LUTOUT207
LUTOUT206
LUTOUT205
LUTOUT204
LUTOUT203
LUTOUT202
LUTOUT201
LUTOUT200
LUTOUT199
LUTOUT198
LUTOUT197
LUTOUT196
LUTOUT195
LUTOUT194
LUTOUT193
LUTOUT192
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2913

<!-- page 2914 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_6 field descriptions
Field
Description
31
LUTOUT223
LUT OUT
30
LUTOUT222
LUT OUT
29
LUTOUT221
LUT OUT
28
LUTOUT220
LUT OUT
27
LUTOUT219
LUT OUT
26
LUTOUT218
LUT OUT
25
LUTOUT217
LUT OUT
24
LUTOUT216
LUT OUT
23
LUTOUT215
LUT OUT
22
LUTOUT214
LUT OUT
21
LUTOUT213
LUT OUT
20
LUTOUT212
LUT OUT
19
LUTOUT211
LUT OUT
18
LUTOUT210
LUT OUT
17
LUTOUT209
LUT OUT
16
LUTOUT208
LUT OUT
15
LUTOUT207
LUT OUT
14
LUTOUT206
LUT OUT
13
LUTOUT205
LUT OUT
12
LUTOUT204
LUT OUT
11
LUTOUT203
LUT OUT
10
LUTOUT202
LUT OUT
9
LUTOUT201
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2914
NXP Semiconductors

<!-- page 2915 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_6 field descriptions (continued)
Field
Description
8
LUTOUT200
LUT OUT
7
LUTOUT199
LUT OUT
6
LUTOUT198
LUT OUT
5
LUTOUT197
LUT OUT
4
LUTOUT196
LUT OUT
3
LUTOUT195
LUT OUT
2
LUTOUT194
LUT OUT
1
LUTOUT193
LUT OUT
0
LUTOUT192
LUT OUT
41.11.301
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_7)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2700h offset = 21C_E700h
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
LUTOUT255
LUTOUT254
LUTOUT253
LUTOUT252
LUTOUT251
LUTOUT250
LUTOUT249
LUTOUT248
LUTOUT247
LUTOUT246
LUTOUT245
LUTOUT244
LUTOUT243
LUTOUT242
LUTOUT241
LUTOUT240
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
LUTOUT239
LUTOUT238
LUTOUT237
LUTOUT236
LUTOUT235
LUTOUT234
LUTOUT233
LUTOUT232
LUTOUT231
LUTOUT230
LUTOUT229
LUTOUT228
LUTOUT227
LUTOUT226
LUTOUT225
LUTOUT224
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2915

<!-- page 2916 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_7 field descriptions
Field
Description
31
LUTOUT255
LUT OUT
30
LUTOUT254
LUT OUT
29
LUTOUT253
LUT OUT
28
LUTOUT252
LUT OUT
27
LUTOUT251
LUT OUT
26
LUTOUT250
LUT OUT
25
LUTOUT249
LUT OUT
24
LUTOUT248
LUT OUT
23
LUTOUT247
LUT OUT
22
LUTOUT246
LUT OUT
21
LUTOUT245
LUT OUT
20
LUTOUT244
LUT OUT
19
LUTOUT243
LUT OUT
18
LUTOUT242
LUT OUT
17
LUTOUT241
LUT OUT
16
LUTOUT240
LUT OUT
15
LUTOUT239
LUT OUT
14
LUTOUT238
LUT OUT
13
LUTOUT237
LUT OUT
12
LUTOUT236
LUT OUT
11
LUTOUT235
LUT OUT
10
LUTOUT234
LUT OUT
9
LUTOUT233
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2916
NXP Semiconductors

<!-- page 2917 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT2_7 field descriptions (continued)
Field
Description
8
LUTOUT232
LUT OUT
7
LUTOUT231
LUT OUT
6
LUTOUT230
LUT OUT
5
LUTOUT229
LUT OUT
4
LUTOUT228
LUT OUT
3
LUTOUT227
LUT OUT
2
LUTOUT226
LUT OUT
1
LUTOUT225
LUT OUT
0
LUTOUT224
LUT OUT
41.11.302
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_0)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2710h offset = 21C_E710h
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
LUTOUT31
LUTOUT30
LUTOUT29
LUTOUT28
LUTOUT27
LUTOUT26
LUTOUT25
LUTOUT24
LUTOUT23
LUTOUT22
LUTOUT21
LUTOUT20
LUTOUT19
LUTOUT18
LUTOUT17
LUTOUT16
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
LUTOUT15
LUTOUT14
LUTOUT13
LUTOUT12
LUTOUT11
LUTOUT10
LUTOUT9
LUTOUT8
LUTOUT7
LUTOUT6
LUTOUT5
LUTOUT4
LUTOUT3
LUTOUT2
LUTOUT1
LUTOUT0
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2917

<!-- page 2918 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_0 field descriptions
Field
Description
31
LUTOUT31
LUT OUT
30
LUTOUT30
LUT OUT
29
LUTOUT29
LUT OUT
28
LUTOUT28
LUT OUT
27
LUTOUT27
LUT OUT
26
LUTOUT26
LUT OUT
25
LUTOUT25
LUT OUT
24
LUTOUT24
LUT OUT
23
LUTOUT23
LUT OUT
22
LUTOUT22
LUT OUT
21
LUTOUT21
LUT OUT
20
LUTOUT20
LUT OUT
19
LUTOUT19
LUT OUT
18
LUTOUT18
LUT OUT
17
LUTOUT17
LUT OUT
16
LUTOUT16
LUT OUT
15
LUTOUT15
LUT OUT
14
LUTOUT14
LUT OUT
13
LUTOUT13
LUT OUT
12
LUTOUT12
LUT OUT
11
LUTOUT11
LUT OUT
10
LUTOUT10
LUT OUT
9
LUTOUT9
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2918
NXP Semiconductors

<!-- page 2919 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_0 field descriptions (continued)
Field
Description
8
LUTOUT8
LUT OUT
7
LUTOUT7
LUT OUT
6
LUTOUT6
LUT OUT
5
LUTOUT5
LUT OUT
4
LUTOUT4
LUT OUT
3
LUTOUT3
LUT OUT
2
LUTOUT2
LUT OUT
1
LUTOUT1
LUT OUT
0
LUTOUT0
LUT OUT
41.11.303
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_1)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2720h offset = 21C_E720h
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
LUTOUT63
LUTOUT62
LUTOUT61
LUTOUT60
LUTOUT59
LUTOUT58
LUTOUT57
LUTOUT56
LUTOUT55
LUTOUT54
LUTOUT53
LUTOUT52
LUTOUT51
LUTOUT50
LUTOUT49
LUTOUT48
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
LUTOUT47
LUTOUT46
LUTOUT45
LUTOUT44
LUTOUT43
LUTOUT42
LUTOUT41
LUTOUT40
LUTOUT39
LUTOUT38
LUTOUT37
LUTOUT36
LUTOUT35
LUTOUT34
LUTOUT33
LUTOUT32
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2919

<!-- page 2920 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_1 field descriptions
Field
Description
31
LUTOUT63
LUT OUT
30
LUTOUT62
LUT OUT
29
LUTOUT61
LUT OUT
28
LUTOUT60
LUT OUT
27
LUTOUT59
LUT OUT
26
LUTOUT58
LUT OUT
25
LUTOUT57
LUT OUT
24
LUTOUT56
LUT OUT
23
LUTOUT55
LUT OUT
22
LUTOUT54
LUT OUT
21
LUTOUT53
LUT OUT
20
LUTOUT52
LUT OUT
19
LUTOUT51
LUT OUT
18
LUTOUT50
LUT OUT
17
LUTOUT49
LUT OUT
16
LUTOUT48
LUT OUT
15
LUTOUT47
LUT OUT
14
LUTOUT46
LUT OUT
13
LUTOUT45
LUT OUT
12
LUTOUT44
LUT OUT
11
LUTOUT43
LUT OUT
10
LUTOUT42
LUT OUT
9
LUTOUT41
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2920
NXP Semiconductors

<!-- page 2921 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_1 field descriptions (continued)
Field
Description
8
LUTOUT40
LUT OUT
7
LUTOUT39
LUT OUT
6
LUTOUT38
LUT OUT
5
LUTOUT37
LUT OUT
4
LUTOUT36
LUT OUT
3
LUTOUT35
LUT OUT
2
LUTOUT34
LUT OUT
1
LUTOUT33
LUT OUT
0
LUTOUT32
LUT OUT
41.11.304
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_2)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2730h offset = 21C_E730h
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
LUTOUT95
LUTOUT94
LUTOUT93
LUTOUT92
LUTOUT91
LUTOUT90
LUTOUT89
LUTOUT88
LUTOUT87
LUTOUT86
LUTOUT85
LUTOUT84
LUTOUT83
LUTOUT82
LUTOUT81
LUTOUT80
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
LUTOUT79
LUTOUT78
LUTOUT77
LUTOUT76
LUTOUT75
LUTOUT74
LUTOUT73
LUTOUT72
LUTOUT71
LUTOUT70
LUTOUT69
LUTOUT68
LUTOUT67
LUTOUT66
LUTOUT65
LUTOUT64
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2921

<!-- page 2922 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_2 field descriptions
Field
Description
31
LUTOUT95
LUT OUT
30
LUTOUT94
LUT OUT
29
LUTOUT93
LUT OUT
28
LUTOUT92
LUT OUT
27
LUTOUT91
LUT OUT
26
LUTOUT90
LUT OUT
25
LUTOUT89
LUT OUT
24
LUTOUT88
LUT OUT
23
LUTOUT87
LUT OUT
22
LUTOUT86
LUT OUT
21
LUTOUT85
LUT OUT
20
LUTOUT84
LUT OUT
19
LUTOUT83
LUT OUT
18
LUTOUT82
LUT OUT
17
LUTOUT81
LUT OUT
16
LUTOUT80
LUT OUT
15
LUTOUT79
LUT OUT
14
LUTOUT78
LUT OUT
13
LUTOUT77
LUT OUT
12
LUTOUT76
LUT OUT
11
LUTOUT75
LUT OUT
10
LUTOUT74
LUT OUT
9
LUTOUT73
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2922
NXP Semiconductors

<!-- page 2923 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_2 field descriptions (continued)
Field
Description
8
LUTOUT72
LUT OUT
7
LUTOUT71
LUT OUT
6
LUTOUT70
LUT OUT
5
LUTOUT69
LUT OUT
4
LUTOUT68
LUT OUT
3
LUTOUT67
LUT OUT
2
LUTOUT66
LUT OUT
1
LUTOUT65
LUT OUT
0
LUTOUT64
LUT OUT
41.11.305
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_3)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2740h offset = 21C_E740h
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
LUTOUT127
LUTOUT126
LUTOUT125
LUTOUT124
LUTOUT123
LUTOUT122
LUTOUT121
LUTOUT120
LUTOUT119
LUTOUT118
LUTOUT117
LUTOUT116
LUTOUT115
LUTOUT114
LUTOUT113
LUTOUT112
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
LUTOUT111
LUTOUT110
LUTOUT109
LUTOUT108
LUTOUT107
LUTOUT106
LUTOUT105
LUTOUT104
LUTOUT103
LUTOUT102
LUTOUT101
LUTOUT100
LUTOUT99
LUTOUT98
LUTOUT97
LUTOUT96
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2923

<!-- page 2924 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_3 field descriptions
Field
Description
31
LUTOUT127
LUT OUT
30
LUTOUT126
LUT OUT
29
LUTOUT125
LUT OUT
28
LUTOUT124
LUT OUT
27
LUTOUT123
LUT OUT
26
LUTOUT122
LUT OUT
25
LUTOUT121
LUT OUT
24
LUTOUT120
LUT OUT
23
LUTOUT119
LUT OUT
22
LUTOUT118
LUT OUT
21
LUTOUT117
LUT OUT
20
LUTOUT116
LUT OUT
19
LUTOUT115
LUT OUT
18
LUTOUT114
LUT OUT
17
LUTOUT113
LUT OUT
16
LUTOUT112
LUT OUT
15
LUTOUT111
LUT OUT
14
LUTOUT110
LUT OUT
13
LUTOUT109
LUT OUT
12
LUTOUT108
LUT OUT
11
LUTOUT107
LUT OUT
10
LUTOUT106
LUT OUT
9
LUTOUT105
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2924
NXP Semiconductors

<!-- page 2925 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_3 field descriptions (continued)
Field
Description
8
LUTOUT104
LUT OUT
7
LUTOUT103
LUT OUT
6
LUTOUT102
LUT OUT
5
LUTOUT101
LUT OUT
4
LUTOUT100
LUT OUT
3
LUTOUT99
LUT OUT
2
LUTOUT98
LUT OUT
1
LUTOUT97
LUT OUT
0
LUTOUT96
LUT OUT
41.11.306
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_4)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2750h offset = 21C_E750h
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
LUTOUT159
LUTOUT158
LUTOUT157
LUTOUT156
LUTOUT155
LUTOUT154
LUTOUT153
LUTOUT152
LUTOUT151
LUTOUT150
LUTOUT149
LUTOUT148
LUTOUT147
LUTOUT146
LUTOUT145
LUTOUT144
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
LUTOUT143
LUTOUT142
LUTOUT141
LUTOUT140
LUTOUT139
LUTOUT138
LUTOUT137
LUTOUT136
LUTOUT135
LUTOUT134
LUTOUT133
LUTOUT132
LUTOUT131
LUTOUT130
LUTOUT129
LUTOUT128
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2925

<!-- page 2926 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_4 field descriptions
Field
Description
31
LUTOUT159
LUT OUT
30
LUTOUT158
LUT OUT
29
LUTOUT157
LUT OUT
28
LUTOUT156
LUT OUT
27
LUTOUT155
LUT OUT
26
LUTOUT154
LUT OUT
25
LUTOUT153
LUT OUT
24
LUTOUT152
LUT OUT
23
LUTOUT151
LUT OUT
22
LUTOUT150
LUT OUT
21
LUTOUT149
LUT OUT
20
LUTOUT148
LUT OUT
19
LUTOUT147
LUT OUT
18
LUTOUT146
LUT OUT
17
LUTOUT145
LUT OUT
16
LUTOUT144
LUT OUT
15
LUTOUT143
LUT OUT
14
LUTOUT142
LUT OUT
13
LUTOUT141
LUT OUT
12
LUTOUT140
LUT OUT
11
LUTOUT139
LUT OUT
10
LUTOUT138
LUT OUT
9
LUTOUT137
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2926
NXP Semiconductors

<!-- page 2927 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_4 field descriptions (continued)
Field
Description
8
LUTOUT136
LUT OUT
7
LUTOUT135
LUT OUT
6
LUTOUT134
LUT OUT
5
LUTOUT133
LUT OUT
4
LUTOUT132
LUT OUT
3
LUTOUT131
LUT OUT
2
LUTOUT130
LUT OUT
1
LUTOUT129
LUT OUT
0
LUTOUT128
LUT OUT
41.11.307
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_5)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2760h offset = 21C_E760h
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
LUTOUT191
LUTOUT190
LUTOUT189
LUTOUT188
LUTOUT187
LUTOUT186
LUTOUT185
LUTOUT184
LUTOUT183
LUTOUT182
LUTOUT181
LUTOUT180
LUTOUT179
LUTOUT178
LUTOUT177
LUTOUT176
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
LUTOUT175
LUTOUT174
LUTOUT173
LUTOUT172
LUTOUT171
LUTOUT170
LUTOUT169
LUTOUT168
LUTOUT167
LUTOUT166
LUTOUT165
LUTOUT164
LUTOUT163
LUTOUT162
LUTOUT161
LUTOUT160
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2927

<!-- page 2928 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_5 field descriptions
Field
Description
31
LUTOUT191
LUT OUT
30
LUTOUT190
LUT OUT
29
LUTOUT189
LUT OUT
28
LUTOUT188
LUT OUT
27
LUTOUT187
LUT OUT
26
LUTOUT186
LUT OUT
25
LUTOUT185
LUT OUT
24
LUTOUT184
LUT OUT
23
LUTOUT183
LUT OUT
22
LUTOUT182
LUT OUT
21
LUTOUT181
LUT OUT
20
LUTOUT180
LUT OUT
19
LUTOUT179
LUT OUT
18
LUTOUT178
LUT OUT
17
LUTOUT177
LUT OUT
16
LUTOUT176
LUT OUT
15
LUTOUT175
LUT OUT
14
LUTOUT174
LUT OUT
13
LUTOUT173
LUT OUT
12
LUTOUT172
LUT OUT
11
LUTOUT171
LUT OUT
10
LUTOUT170
LUT OUT
9
LUTOUT169
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2928
NXP Semiconductors

<!-- page 2929 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_5 field descriptions (continued)
Field
Description
8
LUTOUT168
LUT OUT
7
LUTOUT167
LUT OUT
6
LUTOUT166
LUT OUT
5
LUTOUT165
LUT OUT
4
LUTOUT164
LUT OUT
3
LUTOUT163
LUT OUT
2
LUTOUT162
LUT OUT
1
LUTOUT161
LUT OUT
0
LUTOUT160
LUT OUT
41.11.308
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_6)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2770h offset = 21C_E770h
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
LUTOUT223
LUTOUT222
LUTOUT221
LUTOUT220
LUTOUT219
LUTOUT218
LUTOUT217
LUTOUT216
LUTOUT215
LUTOUT214
LUTOUT213
LUTOUT212
LUTOUT211
LUTOUT210
LUTOUT209
LUTOUT208
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
LUTOUT207
LUTOUT206
LUTOUT205
LUTOUT204
LUTOUT203
LUTOUT202
LUTOUT201
LUTOUT200
LUTOUT199
LUTOUT198
LUTOUT197
LUTOUT196
LUTOUT195
LUTOUT194
LUTOUT193
LUTOUT192
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2929

<!-- page 2930 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_6 field descriptions
Field
Description
31
LUTOUT223
LUT OUT
30
LUTOUT222
LUT OUT
29
LUTOUT221
LUT OUT
28
LUTOUT220
LUT OUT
27
LUTOUT219
LUT OUT
26
LUTOUT218
LUT OUT
25
LUTOUT217
LUT OUT
24
LUTOUT216
LUT OUT
23
LUTOUT215
LUT OUT
22
LUTOUT214
LUT OUT
21
LUTOUT213
LUT OUT
20
LUTOUT212
LUT OUT
19
LUTOUT211
LUT OUT
18
LUTOUT210
LUT OUT
17
LUTOUT209
LUT OUT
16
LUTOUT208
LUT OUT
15
LUTOUT207
LUT OUT
14
LUTOUT206
LUT OUT
13
LUTOUT205
LUT OUT
12
LUTOUT204
LUT OUT
11
LUTOUT203
LUT OUT
10
LUTOUT202
LUT OUT
9
LUTOUT201
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2930
NXP Semiconductors

<!-- page 2931 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_6 field descriptions (continued)
Field
Description
8
LUTOUT200
LUT OUT
7
LUTOUT199
LUT OUT
6
LUTOUT198
LUT OUT
5
LUTOUT197
LUT OUT
4
LUTOUT196
LUT OUT
3
LUTOUT195
LUT OUT
2
LUTOUT194
LUT OUT
1
LUTOUT193
LUT OUT
0
LUTOUT192
LUT OUT
41.11.309
This register defines the output values (new flag) for
the 8x1 LUTs in stage 3.
(PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_7)
The 5x1 LUT output value for input value n. This output value results in a flag that is
added to the flag array.
Address: 21C_C000h base + 2780h offset = 21C_E780h
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
LUTOUT255
LUTOUT254
LUTOUT253
LUTOUT252
LUTOUT251
LUTOUT250
LUTOUT249
LUTOUT248
LUTOUT247
LUTOUT246
LUTOUT245
LUTOUT244
LUTOUT243
LUTOUT242
LUTOUT241
LUTOUT240
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
LUTOUT239
LUTOUT238
LUTOUT237
LUTOUT236
LUTOUT235
LUTOUT234
LUTOUT233
LUTOUT232
LUTOUT231
LUTOUT230
LUTOUT229
LUTOUT228
LUTOUT227
LUTOUT226
LUTOUT225
LUTOUT224
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2931

<!-- page 2932 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_7 field descriptions
Field
Description
31
LUTOUT255
LUT OUT
30
LUTOUT254
LUT OUT
29
LUTOUT253
LUT OUT
28
LUTOUT252
LUT OUT
27
LUTOUT251
LUT OUT
26
LUTOUT250
LUT OUT
25
LUTOUT249
LUT OUT
24
LUTOUT248
LUT OUT
23
LUTOUT247
LUT OUT
22
LUTOUT246
LUT OUT
21
LUTOUT245
LUT OUT
20
LUTOUT244
LUT OUT
19
LUTOUT243
LUT OUT
18
LUTOUT242
LUT OUT
17
LUTOUT241
LUT OUT
16
LUTOUT240
LUT OUT
15
LUTOUT239
LUT OUT
14
LUTOUT238
LUT OUT
13
LUTOUT237
LUT OUT
12
LUTOUT236
LUT OUT
11
LUTOUT235
LUT OUT
10
LUTOUT234
LUT OUT
9
LUTOUT233
LUT OUT
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2932
NXP Semiconductors

<!-- page 2933 -->

PXP_HW_PXP_WFE_B_STG3_F8X1_OUT3_7 field descriptions (continued)
Field
Description
8
LUTOUT232
LUT OUT
7
LUTOUT231
LUT OUT
6
LUTOUT230
LUT OUT
5
LUTOUT229
LUT OUT
4
LUTOUT228
LUT OUT
3
LUTOUT227
LUT OUT
2
LUTOUT226
LUT OUT
1
LUTOUT225
LUT OUT
0
LUTOUT224
LUT OUT
41.11.310
Each set mask bit enables one of the corresponding
flag input bits. There is one mask per 8x1 LUT.
(PXP_HW_PXP_WFE_B_STG3_F8X1_MASKS)
Each set mask bit enables one of the corresponding flag input bits. There is one mask per
8x1 LUT.
Address: 21C_C000h base + 2790h offset = 21C_E790h
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
MASK3
MASK2
MASK1
MASK0
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
PXP_HW_PXP_WFE_B_STG3_F8X1_MASKS field descriptions
Field
Description
31–24
MASK3
This field selects the input flags that are valid for 8x1 LUT 1. Bit 0 = input 1, Bit 1 = input 2 and so on.
23–16
MASK2
This field selects the input flags that are valid for 8x1 LUT 0. Bit 0 = input 1, Bit 1 = input 2 and so on.
15–8
MASK1
This field selects the input flags that are valid for 8x1 LUT 1. Bit 0 = input 1, Bit 1 = input 2 and so on.
MASK0
This field selects the input flags that are valid for 8x1 LUT 0. Bit 0 = input 1, Bit 1 = input 2 and so on.
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2933

<!-- page 2934 -->

41.11.311
This register defines the control bits for the pxp alu
sub-block. (PXP_HW_PXP_ALU_B_CTRLn)
Address: 21C_C000h base + 28A0h offset + (4d × i), where i=0d to 3d
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
DONE
0
DONE_IRQ_EN
0
DONE_IRQ_FLAG
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
BYPASS
0
SW_RESET
0
START
0
ENABLE
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
0
0
0
0
0
0
PXP_HW_PXP_ALU_B_CTRLn field descriptions
Field
Description
31–29
Reserved
This read-only field is reserved and always has the value 0.
28
DONE
This bit will be set when the processing for a frame is done.
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2934
NXP Semiconductors

<!-- page 2935 -->

PXP_HW_PXP_ALU_B_CTRLn field descriptions (continued)
Field
Description
27–21
Reserved
This read-only field is reserved and always has the value 0.
20
DONE_IRQ_EN
Enable the done irq
19–17
Reserved
This read-only field is reserved and always has the value 0.
16
DONE_IRQ_
FLAG
Done IRQ flag, it will be set when done is set, it will be cleared by write 1 to it.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12
BYPASS
Bypass
11–9
Reserved
This read-only field is reserved and always has the value 0.
8
SW_RESET
Write to 1 to do a software reset to the alu, self-clear.
7–5
Reserved
This read-only field is reserved and always has the value 0.
4
START
Write 1 to start operation, self-clear
3–1
Reserved
This read-only field is reserved and always has the value 0.
0
ENABLE
Enable
41.11.312
This register defines the size of the buffer to be
processed by the alu engine.
(PXP_HW_PXP_ALU_B_BUF_SIZE)
Address: 21C_C000h base + 28B0h offset = 21C_E8B0h
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
BUF_HEIGHT
0
BUF_WIDTH
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
PXP_HW_PXP_ALU_B_BUF_SIZE field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2935

<!-- page 2936 -->

PXP_HW_PXP_ALU_B_BUF_SIZE field descriptions (continued)
Field
Description
27–16
BUF_HEIGHT
This indicate the buffer height in pixels
15–12
Reserved
This read-only field is reserved and always has the value 0.
BUF_WIDTH
This indicate the buffer width in pixels
41.11.313
This register defines the Entry Address for the
Instruction Memory of the ALU.
(PXP_HW_PXP_ALU_B_INST_ENTRY)
Address: 21C_C000h base + 28C0h offset = 21C_E8C0h
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
ENTRY_ADDR
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
PXP_HW_PXP_ALU_B_INST_ENTRY field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
ENTRY_ADDR
Entry address for the instruction memory of ALU
41.11.314
This register defines the parameter used by SW
running on ALU. (PXP_HW_PXP_ALU_B_PARAM)
Address: 21C_C000h base + 28D0h offset = 21C_E8D0h
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
PARAM1
PARAM0
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2936
NXP Semiconductors

<!-- page 2937 -->

PXP_HW_PXP_ALU_B_PARAM field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15–8
PARAM1
Parameter1 used for the SW running on ALU
PARAM0
Parameter0 used for the SW running on ALU
41.11.315
This register defines the hw configuration options for
the alu core. (PXP_HW_PXP_ALU_B_CONFIG)
Address: 21C_C000h base + 28E0h offset = 21C_E8E0h
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
BUF_ADDR
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
PXP_HW_PXP_ALU_B_CONFIG field descriptions
Field
Description
BUF_ADDR
Configuration for the ALU core
41.11.316
This register defines the hw configuration options for
the LUT (PXP_HW_PXP_ALU_B_LUT_CONFIGn)
Address: 21C_C000h base + 28F0h offset + (4d × i), where i=0d to 3d
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
MODE
0
EN
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2937

<!-- page 2938 -->

PXP_HW_PXP_ALU_B_LUT_CONFIGn field descriptions
Field
Description
31–6
Reserved
This read-only field is reserved and always has the value 0.
5–4
MODE
LUT operation mode setting
3–1
Reserved
This read-only field is reserved and always has the value 0.
0
EN
Enable LUT function
41.11.317
This register defines the lower 32-bit data for the LUT
(PXP_HW_PXP_ALU_B_LUT_DATA0)
Address: 21C_C000h base + 2900h offset = 21C_E900h
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
LUT_DATA_L
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
PXP_HW_PXP_ALU_B_LUT_DATA0 field descriptions
Field
Description
LUT_DATA_L
Lower 32-bit Data for the LUT
41.11.318
This register defines the higher 32-bit data for the LUT
(PXP_HW_PXP_ALU_B_LUT_DATA1)
Address: 21C_C000h base + 2910h offset = 21C_E910h
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
LUT_DATA_H
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
PXP_HW_PXP_ALU_B_LUT_DATA1 field descriptions
Field
Description
LUT_DATA_H
Higher 32-bit Data for the LUT
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2938
NXP Semiconductors

<!-- page 2939 -->

41.11.319
This register is used for debugging alu block
(PXP_HW_PXP_ALU_B_DBG)
Address: 21C_C000h base + 2920h offset = 21C_E920h
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
DEBUG_SEL
DEBUG_VALUE
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
PXP_HW_PXP_ALU_B_DBG field descriptions
Field
Description
31–24
DEBUG_SEL
Select the signal to be monitored
DEBUG_VALUE Value of the signals to be monitored
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2939

<!-- page 2940 -->

41.11.320
Histogram Control Register.
(PXP_HW_PXP_HIST_A_CTRL)
Address: 21C_C000h base + 2A00h offset = 21C_EA00h
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
PIXEL_WIDTH
0
PIXEL_OFFSET
W
Reset
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
STATUS
0
CLEAR
0
ENABLE
W
Reset
0
0
0
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
PXP_HW_PXP_HIST_A_CTRL field descriptions
Field
Description
31–27
Reserved
This read-only field is reserved and always has the value 0.
26–24
PIXEL_WIDTH
The width of the pixel to be used for histogram calculation
23
Reserved
This read-only field is reserved and always has the value 0.
22–16
PIXEL_OFFSET
The offset of the pixel to be used for histogram calculation
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
STATUS
Indicates which histogram matched the processed bitmap. Bit[0] indicates that the bitmap pixels were fully
contained within the HIST2 (black / white) histogram. Bit[1] indicates that the bitmap pixels were fully
contained within the HIST4 (2-bit grayscale) histogram. Bit[2] indicates that the bitmap pixels were fully
contained within the HIST8 (3-bit grayscale) histogram. Bit[3] indicates that the bitmap pixels were fully
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2940
NXP Semiconductors

<!-- page 2941 -->

PXP_HW_PXP_HIST_A_CTRL field descriptions (continued)
Field
Description
contained within the HIST16 (4-bit grayscale) histogram. Bit[4] indicates that the bitmap pixels were fully
contained within the HIST32 (5-bit grayscale) histogram.
7–5
Reserved
This read-only field is reserved and always has the value 0.
4
CLEAR
Write 1 to clear the histogram result and will be self-clear after clear function finished
3–1
Reserved
This read-only field is reserved and always has the value 0.
0
ENABLE
Enable the Histogram Engine
41.11.321
Histogram Pixel Mask Register.
(PXP_HW_PXP_HIST_A_MASK)
Address: 21C_C000h base + 2A10h offset = 21C_EA10h
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
MASK_VALUE1
MASK_VALUE0
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
MASK_WIDTH
MASK_OFFSET
MASK_
MODE
0
MASK_EN
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
PXP_HW_PXP_HIST_A_MASK field descriptions
Field
Description
31–24
MASK_VALUE1
The value1 for mask condition checking
23–16
MASK_VALUE0
The value0 for mask condition checking
15–13
MASK_WIDTH
The width of the field to be checked against mask condition
12–6
MASK_OFFSET
The offset of the field to be checked against mask condition
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2941

<!-- page 2942 -->

PXP_HW_PXP_HIST_A_MASK field descriptions (continued)
Field
Description
5–4
MASK_MODE
Operation mode of pixel mask function
3–1
Reserved
This read-only field is reserved and always has the value 0.
0
MASK_EN
Enable the Pixel Mask Function in Histogram
41.11.322
Histogram Pixel Buffer Size Register.
(PXP_HW_PXP_HIST_A_BUF_SIZE)
Address: 21C_C000h base + 2A20h offset = 21C_EA20h
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
HEIGHT
0
WIDTH
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
PXP_HW_PXP_HIST_A_BUF_SIZE field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27–16
HEIGHT
This indicate the buffer height in pixels
15–12
Reserved
This read-only field is reserved and always has the value 0.
WIDTH
This indicate the buffer width in pixels
41.11.323
Total Number of Pixels Used by Histogram Engine.
(PXP_HW_PXP_HIST_A_TOTAL_PIXEL)
Address: 21C_C000h base + 2A30h offset = 21C_EA30h
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
TOTAL_PIXEL
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2942
NXP Semiconductors

<!-- page 2943 -->

PXP_HW_PXP_HIST_A_TOTAL_PIXEL field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
TOTAL_PIXEL
Total number of pixels used by histogram engine, the pixels got masked will be skipped
41.11.324
The X Coordinate Offset for Active Area.
(PXP_HW_PXP_HIST_A_ACTIVE_AREA_X)
Address: 21C_C000h base + 2A40h offset = 21C_EA40h
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
MAX_X_OFFSET
0
MIN_X_OFFSET
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
PXP_HW_PXP_HIST_A_ACTIVE_AREA_X field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27–16
MAX_X_OFFSET
Maximum X coordinate offset for the active area in histogram processing
15–12
Reserved
This read-only field is reserved and always has the value 0.
MIN_X_OFFSET Minimul X coordinate offset for the active area in histogram processing
41.11.325
The Y Coordinate Offset for Active Area.
(PXP_HW_PXP_HIST_A_ACTIVE_AREA_Y)
Address: 21C_C000h base + 2A50h offset = 21C_EA50h
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
MAX_Y_OFFSET
0
MIN_Y_OFFSET
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2943

<!-- page 2944 -->

PXP_HW_PXP_HIST_A_ACTIVE_AREA_Y field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27–16
MAX_Y_OFFSET
Maximum Y coordinate offset for the active area in histogram processing
15–12
Reserved
This read-only field is reserved and always has the value 0.
MIN_Y_OFFSET Minimul Y coordinate offset for the active area in histogram processing
41.11.326
Histogram Result Based on RAW Pixel Value.
(PXP_HW_PXP_HIST_A_RAW_STAT0)
Address: 21C_C000h base + 2A60h offset = 21C_EA60h
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
STAT0
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
PXP_HW_PXP_HIST_A_RAW_STAT0 field descriptions
Field
Description
STAT0
Lower 32-bit result fo the histogram calculation
41.11.327
Histogram Result Based on RAW Pixel Value.
(PXP_HW_PXP_HIST_A_RAW_STAT1)
Address: 21C_C000h base + 2A70h offset = 21C_EA70h
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
STAT1
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
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2944
NXP Semiconductors

<!-- page 2945 -->

PXP_HW_PXP_HIST_A_RAW_STAT1 field descriptions
Field
Description
STAT1
Higher 32-bit result fo the histogram calculation
41.11.328
Histogram Control Register.
(PXP_HW_PXP_HIST_B_CTRL)
Address: 21C_C000h base + 2A80h offset = 21C_EA80h
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
PIXEL_WIDTH
0
PIXEL_OFFSET
W
Reset
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
STATUS
0
CLEAR
0
ENABLE
W
Reset
0
0
0
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
PXP_HW_PXP_HIST_B_CTRL field descriptions
Field
Description
31–27
Reserved
This read-only field is reserved and always has the value 0.
26–24
PIXEL_WIDTH
The width of the pixel to be used for histogram calculation
23
Reserved
This read-only field is reserved and always has the value 0.
22–16
PIXEL_OFFSET
The offset of the pixel to be used for histogram calculation
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2945

<!-- page 2946 -->

PXP_HW_PXP_HIST_B_CTRL field descriptions (continued)
Field
Description
15–13
Reserved
This read-only field is reserved and always has the value 0.
12–8
STATUS
Indicates which histogram matched the processed bitmap. Bit[0] indicates that the bitmap pixels were fully
contained within the HIST2 (black / white) histogram. Bit[1] indicates that the bitmap pixels were fully
contained within the HIST4 (2-bit grayscale) histogram. Bit[2] indicates that the bitmap pixels were fully
contained within the HIST8 (3-bit grayscale) histogram. Bit[3] indicates that the bitmap pixels were fully
contained within the HIST16 (4-bit grayscale) histogram. Bit[4] indicates that the bitmap pixels were fully
contained within the HIST32 (5-bit grayscale) histogram.
7–5
Reserved
This read-only field is reserved and always has the value 0.
4
CLEAR
Write 1 to clear the histogram result and will be self-clear after clear function finished
3–1
Reserved
This read-only field is reserved and always has the value 0.
0
ENABLE
Enable the Histogram Engine
41.11.329
Histogram Pixel Mask Register.
(PXP_HW_PXP_HIST_B_MASK)
Address: 21C_C000h base + 2A90h offset = 21C_EA90h
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
MASK_VALUE1
MASK_VALUE0
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
MASK_WIDTH
MASK_OFFSET
MASK_
MODE
0
MASK_EN
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
PXP_HW_PXP_HIST_B_MASK field descriptions
Field
Description
31–24
MASK_VALUE1
The value1 for mask condition checking
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2946
NXP Semiconductors

<!-- page 2947 -->

PXP_HW_PXP_HIST_B_MASK field descriptions (continued)
Field
Description
23–16
MASK_VALUE0
The value0 for mask condition checking
15–13
MASK_WIDTH
The width of the field to be checked against mask condition
12–6
MASK_OFFSET
The offset of the field to be checked against mask condition
5–4
MASK_MODE
Operation mode of pixel mask function
3–1
Reserved
This read-only field is reserved and always has the value 0.
0
MASK_EN
Enable the Pixel Mask Function in Histogram
41.11.330
Histogram Pixel Buffer Size Register.
(PXP_HW_PXP_HIST_B_BUF_SIZE)
Address: 21C_C000h base + 2AA0h offset = 21C_EAA0h
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
HEIGHT
0
WIDTH
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
PXP_HW_PXP_HIST_B_BUF_SIZE field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27–16
HEIGHT
This indicate the buffer height in pixels
15–12
Reserved
This read-only field is reserved and always has the value 0.
WIDTH
This indicate the buffer width in pixels
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2947

<!-- page 2948 -->

41.11.331
Total Number of Pixels Used by Histogram Engine.
(PXP_HW_PXP_HIST_B_TOTAL_PIXEL)
Address: 21C_C000h base + 2AB0h offset = 21C_EAB0h
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
TOTAL_PIXEL
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
PXP_HW_PXP_HIST_B_TOTAL_PIXEL field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
TOTAL_PIXEL
Total number of pixels used by histogram engine, the pixels got masked will be skipped
41.11.332
The X Coordinate Offset for Active Area.
(PXP_HW_PXP_HIST_B_ACTIVE_AREA_X)
Address: 21C_C000h base + 2AC0h offset = 21C_EAC0h
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
MAX_X_OFFSET
0
MIN_X_OFFSET
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
PXP_HW_PXP_HIST_B_ACTIVE_AREA_X field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27–16
MAX_X_OFFSET
Maximum X coordinate offset for the active area in histogram processing
15–12
Reserved
This read-only field is reserved and always has the value 0.
MIN_X_OFFSET Minimul X coordinate offset for the active area in histogram processing
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2948
NXP Semiconductors

<!-- page 2949 -->

41.11.333
The Y Coordinate Offset for Active Area.
(PXP_HW_PXP_HIST_B_ACTIVE_AREA_Y)
Address: 21C_C000h base + 2AD0h offset = 21C_EAD0h
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
MAX_Y_OFFSET
0
MIN_Y_OFFSET
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
PXP_HW_PXP_HIST_B_ACTIVE_AREA_Y field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27–16
MAX_Y_OFFSET
Maximum Y coordinate offset for the active area in histogram processing
15–12
Reserved
This read-only field is reserved and always has the value 0.
MIN_Y_OFFSET Minimul Y coordinate offset for the active area in histogram processing
41.11.334
Histogram Result Based on RAW Pixel Value.
(PXP_HW_PXP_HIST_B_RAW_STAT0)
Address: 21C_C000h base + 2AE0h offset = 21C_EAE0h
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
STAT0
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
PXP_HW_PXP_HIST_B_RAW_STAT0 field descriptions
Field
Description
STAT0
Lower 32-bit result fo the histogram calculation
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2949

<!-- page 2950 -->

41.11.335
Histogram Result Based on RAW Pixel Value.
(PXP_HW_PXP_HIST_B_RAW_STAT1)
Address: 21C_C000h base + 2AF0h offset = 21C_EAF0h
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
STAT1
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
PXP_HW_PXP_HIST_B_RAW_STAT1 field descriptions
Field
Description
STAT1
Higher 32-bit result fo the histogram calculation
41.11.336
2-level Histogram Parameter Register.
(PXP_HW_PXP_HIST2_PARAM)
Address: 21C_C000h base + 2B00h offset = 21C_EB00h
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
VALUE1
0
VALUE0
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
PXP_HW_PXP_HIST2_PARAM field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE1
White value for 2-level histogram
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE0
Black value for 2-level histogram
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2950
NXP Semiconductors

<!-- page 2951 -->

41.11.337
4-level Histogram Parameter Register.
(PXP_HW_PXP_HIST4_PARAM)
Address: 21C_C000h base + 2B10h offset = 21C_EB10h
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
VALUE3
0
VALUE2
0
VALUE1
0
VALUE0
W
Reset 0
0
0
0
1
1
1
1
0
0
0
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
PXP_HW_PXP_HIST4_PARAM field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE3
GRAY3 (White) value for 4-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE2
GRAY2 value for 4-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE1
GRAY1 value for 4-level histogram
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE0
GRAY0 (Black) value for 4-level histogram
41.11.338
8-level Histogram Parameter 0 Register.
(PXP_HW_PXP_HIST8_PARAM0)
Address: 21C_C000h base + 2B20h offset = 21C_EB20h
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
VALUE3
0
VALUE2
0
VALUE1
0
VALUE0
W
Reset 0
0
0
0
0
1
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
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2951

<!-- page 2952 -->

PXP_HW_PXP_HIST8_PARAM0 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE3
GRAY3 value for 8-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE2
GRAY2 value for 8-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE1
GRAY1 value for 8-level histogram
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE0
GRAY0 (Black) value for 8-level histogram
41.11.339
8-level Histogram Parameter 1 Register.
(PXP_HW_PXP_HIST8_PARAM1)
Address: 21C_C000h base + 2B30h offset = 21C_EB30h
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
VALUE7
0
VALUE6
0
VALUE5
0
VALUE4
W
Reset 0
0
0
0
1
1
1
1
0
0
0
0
1
1
0
1
0
0
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
1
0
0
1
PXP_HW_PXP_HIST8_PARAM1 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE7
GRAY7 (White) value for 8-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE6
GRAY6 value for 8-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE5
GRAY5 value for 8-level histogram
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2952
NXP Semiconductors

<!-- page 2953 -->

PXP_HW_PXP_HIST8_PARAM1 field descriptions (continued)
Field
Description
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE4
GRAY4 value for 8-level histogram
41.11.340
16-level Histogram Parameter 0 Register.
(PXP_HW_PXP_HIST16_PARAM0)
Address: 21C_C000h base + 2B40h offset = 21C_EB40h
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
VALUE3
0
VALUE2
0
VALUE1
0
VALUE0
W
Reset 0
0
0
0
0
0
1
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
PXP_HW_PXP_HIST16_PARAM0 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE3
GRAY3 value for 16-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE2
GRAY2 value for 16-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE1
GRAY1 value for 16-level histogram
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE0
GRAY0 (Black) value for 16-level histogram
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2953

<!-- page 2954 -->

41.11.341
16-level Histogram Parameter 1 Register.
(PXP_HW_PXP_HIST16_PARAM1)
Address: 21C_C000h base + 2B50h offset = 21C_EB50h
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
VALUE7
0
VALUE6
0
VALUE5
0
VALUE4
W
Reset 0
0
0
0
0
1
1
1
0
0
0
0
0
1
1
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
0
0
0
1
0
0
PXP_HW_PXP_HIST16_PARAM1 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE7
GRAY7 value for 16-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE6
GRAY6 value for 16-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE5
GRAY5 value for 16-level histogram
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE4
GRAY4 value for 16-level histogram
41.11.342
16-level Histogram Parameter 2 Register.
(PXP_HW_PXP_HIST16_PARAM2)
Address: 21C_C000h base + 2B60h offset = 21C_EB60h
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
VALUE11
0
VALUE10
0
VALUE9
0
VALUE8
W
Reset 0
0
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
1
0
1
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
0
0
0
1
0
0
0
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2954
NXP Semiconductors

<!-- page 2955 -->

PXP_HW_PXP_HIST16_PARAM2 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE11
GRAY11 value for 16-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE10
GRAY10 value for 16-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE9
GRAY9 value for 16-level histogram
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE8
GRAY8 value for 16-level histogram
41.11.343
16-level Histogram Parameter 3 Register.
(PXP_HW_PXP_HIST16_PARAM3)
Address: 21C_C000h base + 2B70h offset = 21C_EB70h
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
VALUE15
0
VALUE14
0
VALUE13
0
VALUE12
W
Reset 0
0
0
0
1
1
1
1
0
0
0
0
1
1
1
0
0
0
0
0
1
1
0
1
0
0
0
0
1
1
0
0
PXP_HW_PXP_HIST16_PARAM3 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE15
GRAY15 (White) value for 16-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE14
GRAY14 value for 16-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE13
GRAY13 value for 16-level histogram
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2955

<!-- page 2956 -->

PXP_HW_PXP_HIST16_PARAM3 field descriptions (continued)
Field
Description
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE12
GRAY12 value for 16-level histogram
41.11.344
32-level Histogram Parameter 0 Register.
(PXP_HW_PXP_HIST32_PARAM0)
Address: 21C_C000h base + 2B80h offset = 21C_EB80h
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
VALUE3
0
VALUE2
0
VALUE1
0
VALUE0
W
Reset 0
0
0
0
0
0
1
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
PXP_HW_PXP_HIST32_PARAM0 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE3
GRAY3 value for 32-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE2
GRAY2 value for 32-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE1
GRAY1 value for 32-level histogram
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE0
GRAY0 (Black) value for 32-level histogram
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2956
NXP Semiconductors

<!-- page 2957 -->

41.11.345
32-level Histogram Parameter 1 Register.
(PXP_HW_PXP_HIST32_PARAM1)
Address: 21C_C000h base + 2B90h offset = 21C_EB90h
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
VALUE7
0
VALUE6
0
VALUE5
0
VALUE4
W
Reset 0
0
0
0
0
1
1
1
0
0
0
0
0
1
1
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
0
0
0
1
0
0
PXP_HW_PXP_HIST32_PARAM1 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE7
GRAY7 value for 32-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE6
GRAY6 value for 32-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE5
GRAY5 value for 32-level histogram
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE4
GRAY4 value for 32-level histogram
41.11.346
32-level Histogram Parameter 2 Register.
(PXP_HW_PXP_HIST32_PARAM2)
Address: 21C_C000h base + 2BA0h offset = 21C_EBA0h
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
VALUE11
0
VALUE10
0
VALUE9
0
VALUE8
W
Reset 0
0
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
1
0
1
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
0
0
0
1
0
0
0
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2957

<!-- page 2958 -->

PXP_HW_PXP_HIST32_PARAM2 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE11
GRAY11 value for 32-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE10
GRAY10 value for 32-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE9
GRAY9 value for 32-level histogram
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE8
GRAY8 value for 32-level histogram
41.11.347
32-level Histogram Parameter 3 Register.
(PXP_HW_PXP_HIST32_PARAM3)
Address: 21C_C000h base + 2BB0h offset = 21C_EBB0h
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
VALUE15
0
VALUE14
0
VALUE13
0
VALUE12
W
Reset 0
0
0
0
1
1
1
1
0
0
0
0
1
1
1
0
0
0
0
0
1
1
0
1
0
0
0
0
1
1
0
0
PXP_HW_PXP_HIST32_PARAM3 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE15
GRAY15 (White) value for 32-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE14
GRAY14 value for 32-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE13
GRAY13 value for 32-level histogram
Table continues on the next page...
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2958
NXP Semiconductors

<!-- page 2959 -->

PXP_HW_PXP_HIST32_PARAM3 field descriptions (continued)
Field
Description
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE12
GRAY12 value for 32-level histogram
41.11.348
32-level Histogram Parameter 0 Register.
(PXP_HW_PXP_HIST32_PARAM4)
Address: 21C_C000h base + 2BC0h offset = 21C_EBC0h
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
VALUE19
0
VALUE18
0
VALUE17
0
VALUE16
W
Reset 0
0
0
0
0
0
1
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
PXP_HW_PXP_HIST32_PARAM4 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE19
GRAY19 value for 32-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE18
GRAY18 value for 32-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE17
GRAY17 value for 32-level histogram
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE16
GRAY16 (Black) value for 32-level histogram
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2959

<!-- page 2960 -->

41.11.349
32-level Histogram Parameter 1 Register.
(PXP_HW_PXP_HIST32_PARAM5)
Address: 21C_C000h base + 2BD0h offset = 21C_EBD0h
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
VALUE23
0
VALUE22
0
VALUE21
0
VALUE20
W
Reset 0
0
0
0
0
1
1
1
0
0
0
0
0
1
1
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
0
0
0
1
0
0
PXP_HW_PXP_HIST32_PARAM5 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE23
GRAY23 value for 32-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE22
GRAY22 value for 32-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE21
GRAY21 value for 32-level histogram
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE20
GRAY20 value for 32-level histogram
41.11.350
32-level Histogram Parameter 2 Register.
(PXP_HW_PXP_HIST32_PARAM6)
Address: 21C_C000h base + 2BE0h offset = 21C_EBE0h
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
VALUE27
0
VALUE26
0
VALUE25
0
VALUE24
W
Reset 0
0
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
1
0
1
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
0
0
0
1
0
0
0
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2960
NXP Semiconductors

<!-- page 2961 -->

PXP_HW_PXP_HIST32_PARAM6 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE27
GRAY27 value for 32-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE26
GRAY26 value for 32-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE25
GRAY25 value for 32-level histogram
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE24
GRAY24 value for 32-level histogram
41.11.351
32-level Histogram Parameter 3 Register.
(PXP_HW_PXP_HIST32_PARAM7)
Address: 21C_C000h base + 2BF0h offset = 21C_EBF0h
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
VALUE31
0
VALUE30
0
VALUE29
0
VALUE28
W
Reset 0
0
0
0
1
1
1
1
0
0
0
0
1
1
1
0
0
0
0
0
1
1
0
1
0
0
0
0
1
1
0
0
PXP_HW_PXP_HIST32_PARAM7 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
VALUE31
GRAY31 (White) value for 32-level histogram
23–22
Reserved
This read-only field is reserved and always has the value 0.
21–16
VALUE30
GRAY30 value for 32-level histogram
15–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
VALUE29
GRAY29 value for 32-level histogram
Table continues on the next page...
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2961

<!-- page 2962 -->

PXP_HW_PXP_HIST32_PARAM7 field descriptions (continued)
Field
Description
7–6
Reserved
This read-only field is reserved and always has the value 0.
VALUE28
GRAY28 value for 32-level histogram
41.11.352
This register defines the pxp subblock handshake
signals ready mux on top level.
(PXP_HW_PXP_HANDSHAKE_READY_MUX0)
Address: 21C_C000h base + 2CF0h offset = 21C_ECF0h
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
-
HSK0
W
Reset 0
1
1
1
0
1
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
1
1
0
0
1
0
0
0
0
1
0
0
0
0
PXP_HW_PXP_HANDSHAKE_READY_MUX0 field descriptions
Field
Description
31–4
-
Reserved
HSK0
Subblock double buffer handshake signals MUX 0: Ready signal source is from pxp_control; 1: Ready
signal source is from pxp_store_wfe_b CH0; 2: Ready signal source is from pxp_store_wfe_b CH1;
41.11.353
This register defines the pxp subblock handshake
signals done mux on top level.
(PXP_HW_PXP_HANDSHAKE_DONE_MUX0)
Address: 21C_C000h base + 2D10h offset = 21C_ED10h
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
-
HSK0
W
Reset 0
1
1
1
0
1
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
1
1
0
0
1
0
0
0
0
1
0
0
0
0
PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2962
NXP Semiconductors

<!-- page 2963 -->

PXP_HW_PXP_HANDSHAKE_DONE_MUX0 field descriptions
Field
Description
31–4
-
Reserved
HSK0
Subblock double buffer handshake signals MUX 0: Done signal source is from LCDIF; 1: Done signal
source is from pxp_fetch_wfe_b CH0; 2: Done signal source is from pxp_fetch_wfe_b CH1;
Chapter 41 Pixel Pipeline (PXP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2963

<!-- page 2964 -->

PXP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2964
NXP Semiconductors

