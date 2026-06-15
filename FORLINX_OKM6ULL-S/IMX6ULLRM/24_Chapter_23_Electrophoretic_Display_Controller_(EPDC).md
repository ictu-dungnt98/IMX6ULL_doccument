# Chapter 23: Electrophoretic Display Controller (EPDC)

> Nguồn: `IMX6ULLRM.pdf` — trang 1035–1166

<!-- page 1035 -->

Chapter 23
Electrophoretic Display Controller (EPDC)
23.1
Overview
This chapter describes the architecture of the EPDC. It provides a detailed description of
the block for digital design and software driver development.
The EPDC is a feature-rich, low power and high performance direct drive active matrix
EPD controller. It is specifically designed to drive E•INKTM EPD panels supporting a
wide variety of TFT backplanes. The goal of the EPDC is to provide an efficient SoC
integration of this functionality for e-paper applications, allowing a significant BOM cost
saving over an external solution, while reaching much higher levels of performance at
lower power. The EPDC module is defined in the context of an optimized HW/SW
partitioning and works in conjunction with the PXP IP module to form a complete display
processing solution.
The key features of the EPDC are as follows:
• TFT resolutions up to 4096 x 4096 pixels with 20 Hz refresh (programmable up to
8191 x 8191)
• TFT resolutions up to 1650 x 2332 pixels at 106 Hz refresh
• Industry standard bus interfaces (AMBA AXI and APB)
• Up to 5-bit pixel representation for up to 32 greyscale levels
• Up to 64 concurrent updates with partial update support, except for 32(5-bit) grey
level panel for which only 16 concurrent updates can be used
• Automatic collision handling when used in conjunction with the i.MX device driver
• Flexible direct drive TFT interface supporting next generation source driver, gate
driver and panel architectures, including LVDS, DDR and multi-level source drivers
• Unified generic configurable timing mode (Pigeon Mode) available on most panel
timing control signals
• High performance pixel pipeline architecture to guarantee refresh performance at
high pixel rates without the need for high internal clocking
• Ability to process multiple updates asynchronously to refresh/update operations with
ability to intercept each frame scan will multiple update requests
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1035

<!-- page 1036 -->

• Performance tuning capabilities which can interface with SoC level memory
arbitration mechanisms further guaranteeing frame refresh operation
• Decoupled clocking architecture allowing for independent and asynchronous clock
sources for memory bus, peripheral bus and pixel clock domains
• Full and partial update mode support
• Support for up to 256 waveform modes, also support optimal waveform auto-
selection based on grey level of the pixels being updated
• Low power mode operation via architectural clock gating
• Update buffer analysis functions to get information like collision rectangle, grey
level
23.1.1
EPDC Block Diagram
The top-level view of the EPDC is shown in the following figure.
Memory & Buffer
Manager (aclk)
Timing Controller
Engine (pixclk)
Control/Status Registers (pclk)
IRQ
QoS Req
WB/UPD
Processor
+
Collision
Detection
Pixel Refresh
Engine
Wave Engine
Frame Control
Sequencing
PIX_FIFO_0
Regions
+
Active LUTs
X-Y Region
Mask Active LUT
Comparators
64-bit Dual-Channel AXI Bus Master I/F
Pixel Fetch & Decode
Variable Pipeline
LU Sequencer
Data Capture / Format
Var Pipe
SDCLK/Control
Generation
H - FSM
V - FSM
OE - FSM
APBv3
AXIW-64
AXIR-64
WB
UPD
4 Pixels/PIXCLK
LUT x 16
Bank0
LUT x 16
BANK 1
LUT x 16
BANK 2
LUT x 16
BANK 3
DATA[15:0]
OR
2 x DATA[7:0]
Source/Gate
Clocks/Control
Figure 23-1. EPDC Top-Level Block Diagram
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1036
NXP Semiconductors

<!-- page 1037 -->

The EPD function can be separated into two major asynchronous processes. The first is
the front end portion which is responsible for processing display updates. The second is
the function of driving waveforms to the TFT panel in order to update the screen contents
(the refresh operation). The EPDC is comprised of two major submodules (MBM and
TCE) which mirror the architectural split in the EPD algorithm. These submodules
communicate through a number of control/sequencing signals and data (through the pixel
FIFOs and LUT memories):
• Memory and Buffer Manager (MBM): This submodule is responsible for all
memory-related operations and LUT life cycle control, which involves the frame
count management for all updates. This module is clocked by both aclk and pixclk. It
also encapsulates the APB register interface which is clocked by aclk too.
• Timing Control Engine (TCE): This submodule is responsible for performing TFT
scan frame refreshes. It is clocked by pixclk. It also houses the LUT memory system.
23.2
External Signals
The following table describes the external signals of EPDC:
23.3
Programming Model
From an application perspective, the EPDC HW/SW solution aims to abstract much of
the details of driving an EPD display from the user space.
This is achieved through a blend of HW features and the kernel-level SW driver
implementation of the EPD frame buffer. The scope of this chapter mostly pertains to
EPDC HW but in order to correctly define the context of the programming model, certain
assumptions about the driver architecture (including use of the ePXP IP) are described
below.
23.3.1
Assumptions
The scope of the EPDC does not include certain functions performed by the driver and
application layer.
These features are as follows:
• Maintenance of update and collision lists. This includes, but is not limited to,
responsibility for managing update order. Updates are processed in the order they are
received by the EPDC. Actual start times of multiple updates can occur on the same
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1037

<!-- page 1038 -->

frame scan. All pixels contained within an update will always begin on the same
frame scan.
• Border control. This function is assumed to be performed by a GPIO functionality.
• EPD Panel Power Management. It is assumed that the driver and application layers
will control the panel PMIC functions including relevant interfaces such as I2C and
4-wire power sequencing signals.
• Reading and decompression of the waveform file. This is assumed to be unpacked,
reformatted and written to system memory into a form that is easily accessed by the
EPDC.
• Waveform mode selection. The EPDC provides a mechanism through its histogram
analysis feature (which can be run as part of any frame/region processing operations)
to allow the SW driver to characterize the region/buffer in terms of gray-map
content. For example, EPDC can determine if the update region (considering only
those pixels undergoing a transition) contains only 2, 4, 8 or 16 gray levels, HW can
automatically select waveform mode according to a programmed LUT holding
mapping between grey level and waveform mode. SW driver can also manually
choose the appropriate waveform update mode (e.g., when doing an update to repair
ghosting artifacts).
23.3.2
Register Space (Write/Set/Clear/Toggle)
The EPDC registers utilize four word address locations per 32-bit register.
For control registers (especially interrupts), this provides for a unique address for the
following operations:
• Write (0x0). The base address of the register allows full writes to the 32-bit register.
• Set (0x4). This address allows a set operation on the register or its fields; writing a 1
to a register bit/field with the set address will set that bit. Writing a 0 to the set
address has no effect.
• Clear (0x8). This address allows a clear operation on the register or its fields; writing
a 1 to a register bit/field with the clear address will clear that bit or field.
NOTE
Interrupt status bits (such as those contained in EPDC_IRQ)
must be cleared with the clear address only. Writing to the
EPDC_IRQ register with a 0 will not clear the interrupt status/
source. Writing a 0 to the clear address has no effect.
• Toggle (0xc). This address allows a toggle operation on the register or its fields;
writing a 1 to a register bit/field with the toggle address will invert the state of that
bit/field. This address is especially useful because it provides the ability to perform a
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1038
NXP Semiconductors

<!-- page 1039 -->

read-modify-write operation with a single write operation. Writing a 0 to the toggle
address has no effect.
23.3.3
Interrupts
23.3.3.1
Interrupt Sources
The EPDC contains 72 ( 64 of LUT completes IRQs and 8 of common IRQs ) unique
interrupt sources. Each interrupt source has an interrupt status bit captured in
EPDC_IRQ /EPDC_IRQ1/EPDC_IRQ2 .
When an interrupt event occurs, the appropriate bit within the EPDC_IRQ* register is set
by the EPDC. Each of the bits in EPDC_IRQ is first AND'ed with its enable bit (in
EPDC_IRQ_MASK*), and then the masked bits are logically OR'ed together to generate
the final output.
23.3.3.2
Enabling/Masking Interrupts
Each of the EPDC interrupt sources can be individually enabled through the bits in the
EPDC_IRQ_MASK* register.
Even if an interrupt source is masked out (IRQ_EN bit set to 0), its status will still be
available in the EPDC_IRQ* register. The difference is that it does not result in the
interrupt line being asserted.
23.3.3.3
Handling/Clearing Interrupts
When the software driver is entered as a result of an EPDC interrupt it should read the
EPDC_IRQ* interrupt status register.
Because multiple interrupts may have fired, in the case of a collision for example, both
WB_CMPLT_IRQ and LUT_COL IRQ fields of EPDC_IRQ will be set. Once the
interrupt has been handled, the driver should clear the interrupt source by writing to the
CLEAR address (see Register Space (Write/Set/Clear/Toggle) for details).
When collision has occurred and the LUT_COL_IRQ bit is set, SW will handle the
collision and clear LUT_COL_IRQ. Please note HW will also clear the entire
EPDC_STATUS_COL* register at the sametime on LUT_COL_IRQ clearing by SW.
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1039

<!-- page 1040 -->

23.3.4
Controller Setup
Before screen update operations can be performed, the EPDC should be configured
appropriately.
These rudimentary setup operations include:
• Waveform data must be present in memory (in a format that is consistent with the
method in which the EPDC accesses it). Because the format of the waveform data is
supplier proprietary information, it is not discussed in this chapter.
• Configuring the panel architecture parameters (source and gate-driver configuration)
• Configuring line and frame timing parameters
• Initializing the working buffer and panel
23.3.4.1
Memory Requirements
EPDC requires continuous access to the unpacked waveform data, the update region
buffer, and its working buffer.
These are all expected to reside in system memory (typically external DRAM). As such,
each has particular requirements:
• The Working Buffer (WB), which is pointed to by EPDC_WB_ADDR, must have
EPDC_RES[HORIZONTAL] x EPDC_RES[VERTICAL] x 2 bytes allocated. This
buffer is used by the EPDC to process updates and perform TFT refresh operations.
• EPDC_RES[HORIZONTAL] mod 4 must equal to 0 for memory allocation
calculations because the EPDC constructs each line of the working buffer at a
64-bit boundary.
• The Update Buffer, which is pointed to by EPDC_UPD_ADDR (and can be
redefined with a different address for each update), must have the following
allocation in memory:
a. when stride feature not enabled
• EPDC_UPD_SIZE[HEIGHT] x EPDC_UPD_SIZE[WIDTH] bytes
• Note that EPDC_UPD_SIZE[WIDTH] mod 8 must equal to 0 for memory
allocation purposes. This means that for the address size allocation, the
WIDTH field must be rounded up to the nearest number so that it can be
divided by 8. This is because the EPDC reads each line of the update buffer
at a 64-bit boundary (it should be noted that this is consistent with the ePXP
IP output). The actual value programmed for the update can be at the pixel
granularity.
b. when stride feature enabled
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1040
NXP Semiconductors

<!-- page 1041 -->

• EPDC_UPD_SIZE[HEIGHT] x EPDC_UPD_STRIDE bytes
• EPDC_UPD_SIZE[WIDTH] is used to reflect valid bytes in a line with
EPDC_UPD_STRIDE pixels, STRIDE >= WIDTH
• no alignment requirement on line start or end, no padding necessary unless
STRIDE > WIDTH
• The waveform data set size is a function of mode count, number of temperature
tables and number of frames required for each temperature-compensated mode.
In summary, the memory requirements are as follows (in bytes):
• WB-roundup4(EPDC_RES[HORIZONTAL]) x EPDC_RES[VERTICAL] x 2
• when stride feature not eanbled: UPD-N x roundup8(EPDC_UPD_SIZE[WIDTH]) x
EPDC_UPD_SIZE[HEIGHT]
• N = the number of update requests currently being managed by the i.MX EPD
driver (that is, the driver may maintain a list of updates in memory which it uses
to feed the EPDC).
• when stride feature enabled: UPD-N x EPDC_UPD_STRIDE x
EPDC_UPD_SIZE[HEIGHT]
23.3.4.2
Panel Architecture Configuration
The EPDC is designed to directly drive EPD panels which typically expose the source
and gate driver IC interfaces (these are often abstracted in traditional displays such as
TFT-LCD).
The source and gate driver ICs are responsible for driving the TFT matrix. There are
variations in both the panel architectures and the underlying source and gate driver IC
functionality.
All the key configuration parameters are defined in the EDPC_RES, EPDC_FORMAT,
EPDC_TCE_CTRL, EPDC_TCE_SDCFG and EPDC_TCE_GDCFG registers as
follows.
• EPDC_RES:
• HORIZONTAL: The panel horizontal resolution (in pixels). The horizontal
resolution must be an integer multiple of the source driver
PIXELS_PER_SDCLK value. It also must be an integer multiple of the
PIXELS_PER_CE value.
• VERTICAL: The panel vertical resolution (in pixels). This can be any integer
value.
• EPDC_FORMAT:
• DEFAULT_TFT_PIXEL: This field should almost always be left at 0x00. This
register field is used as the value for the TFT pixel during a frame scan when a
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1041

<!-- page 1042 -->

pixel is not being updated. This condition is commonplace especially when using
partial updates or updates which do not encompass the entire screen resolution.
This value must always correspond to the state the source driver should see when
no voltage change is needed. Incorrectly setting this value will damage the EPD
material.
• TFT_PIXEL_FORMAT: This enumerated field defines the width of the TFT
pixel. The TFT pixel is defined as the per-pixel voltage control value. The most
common pixel format is 2B (2 bits per pixel). Panels which support source driver
voltage modulation (multi-level voltage control) should use the 4B format. For
source drivers that support 7 levels, the 4B format can be used and the unused
DATA output pins should be left floating at the board level connection
(specifically DATA3, 7, 11, 15). The 2BV and 4BV are variations which require
the waveform data to supply a 2-bit VCOM value for each pixel.
• EPDC_TCE_CTRL:
• SDDO_WIDTH: This selects 8- or 16-bit DATA operation using enumerations
8-bit and 16-bit. This field is used to describe useful data for panels that support
LVDS. DATA[15:8] would be used to drive differential data. In these modes,
SDDO_WIDTH would be set to 8-bit.
• VCOM_MODE, VCOM_VAL: This VCOM_MODE bit allows the EPDC to
either use the VCOM value supplied in the waveform or a software
programmable value defined in the VCOM_VAL field, for panels which support
VCOM modulation.
• DDR_MODE: This mode-bit should be set for panels which expect source-driver
data to be available on both edges of the SDCLK. This is common place for
panels that support differential signaling, but the feature is not limited to LVDS
panels. For example, the EPDC supports DDR modes which make full use of
DATA[15:0]. In these modes, DDR_MODE = 1 and LVDS_MODE = 0.
• LVDS_MODE: This mode always requires DDR_MODE to be set. When this
mode bit is set, differential signaling is enabled such that DATA[15:8] always
drives the inverse of the pixel data which is presented on DATA[7:0]. Because
LVDS source-drivers use 2 pins per data-bit, they are typically configured to
work in DDR mode. Differential signaling is also supported on the SDCE pins
(as an option selected by LVDS_MODE_CE). In this mode SDCE[9:5] are used
to drive the inverse differential signals for SDCE[4:0].
• LVDS_MODE_CE: When LVDS_MODE is set, this bit can also be set to allow
SDCE[9:5] to act as differential pairs for each SDCE[4:0].
• PIXELS_PER_SDCLK: This is a key configuration and timing parameter. Each
source driver latches a number of TFT pixels per shift clock period (SDCLK).
This register defines how many pixels are driven per SDCLK period. When
DDR_MODE = 1, pixels are driven on both edges of the clock, so this value
must be adjusted accordingly. See for the required values per mode.
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1042
NXP Semiconductors

<!-- page 1043 -->

• EPDC_TCE_SDCFG:
• SDCLK_HOLD: Holds the SDCLK low during the LINE_BEGIN time. The
purpose of this field is to allow the user to set a LINE_BEGIN time which is not
an integer multiple of SDCLKs (for fine tuning the line-time).
• SDSHR: Defines the value of the SDSHR output signal which determines the
source driver output order mapping.
• NUM_CE: Defines the total number of source driver chip-enables (must be
1-10). This number doesn't always correspond to the number of source drivers in
the panel. Many panels require only a single chip-enable signal which is active
during the entire line data time. This signal is often called SPH (Horizontal Start
Pulse) in such cases.
• PIXELS_PER_CE: This register defines the span of each chip-enable expressed
in pixels. For panels that utilize a single global CE, this value should be set to the
horizontal resolution of the panel.
• SDDO_REFORMAT: This enumerated field allows for TFT-pixel level
reordering within DATA. For most panels it is recommended to set
SDDO_REFORMAT to the REVERSE_PIXELS enumeration.
• SDDO_INVERT: When this field is set, the values on DATA are inverted
relative to the values extracted from the waveform LUT operations.
• EPDC_TCE_GDCFG:
• GDRL: Defines the value of the GDRL output signal which determines the gate
driver pulse shift direction.
• GDOE_MODE: This field selects between two possible methods for driving the
GDOE signal. When GDOE_MODE = 0, the GDOE output is always driven
during the frame scan time, except during FRAME_SYNC when it is driven low.
When GDOE_MODE = 1, the GDOE signal mimics the GDCLK signal but is
only active during the frame-data time (FD). For most panels the recommended
setting is 0.
• GDSP_MODE: This field selects between two possible methods for driving the
GDSP signal. When GDSP_MODE = 0, the GDSP signal is driven on the first
line clock time of the FRAME_BEGIN time. The signal is driven for one
GDCLK period (same as line time), and can be shifted using the
GDSP_OFFSET control. When GDSP_MODE = 1, GDSP is active during the
entire FRAME_SYNC time, and GDSP_OFFSET has not effect in this mode.
23.3.4.3
TFT Panel Timing Configuration
The EPDC provides a simple primary set of registers to define TFT line and frame
(refresh) timing.
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1043

<!-- page 1044 -->

In addition to these, there are also low-level timing and polarity registers to provide
additional flexibility in dealing with future TFT architectures.
The following figure shows how the horizontal and vertical timing is defined in terms of
the various timing parameters. When configuring the TFT timing, the following goals
should be met:
• Arrive at a refresh rate that matches the waveform requirement (for example, 50 Hz
for 50 Hz waveform). The refresh rate is defined as the time between each frame
sync event and can be expressed as a multiple of the line timing and the total number
of vertical lines.
• Meet the various timing requirements of the gate and source driver clock and control
signals (the blanking period provide an infrastructure for controlling these).
• Stay below the maximum source-driver clock (usually referred to as CL) frequency.
• Arrive at a source driver clock frequency which in turn defines the exact pixclk
frequency. In most cases, E-INK™ provides the expected SDCLK frequency.
• Meet the line-timing (LT) requirements of the E-INK panels and their associated
waveforms.
For proper waveform performance, it is critical to match the refresh frequency to that
required by the waveform and associated panel. Deviation from this frequency results in
short term inaccuracy of color and in the long term, complete loss of coherency between
the EPDC's internal representation of color and the physical representation on the screen.
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1044
NXP Semiconductors

<!-- page 1045 -->

Active Region
VSCAN_HOLDOFF
Line
Data
Line
End
Line
Begin
Line
Sync
Frame
Sync
Frame
Begin
Frame
Data
Frame
End
Figure 23-2. Frame Timing
The following equations define the timing of the panel scan frame (where LT = line-
timing and FT = frame-timing):
LT  =  TPIXCLK (LS + LB + (HRES x              Ratio                + LE)
PIXELSPERSDCLK
    
 
    
 
FT = LT x (FS + FB + VRES + LE)
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1045

<!-- page 1046 -->

Ratio is defined between the internal PIXCLK and the external source driver clock
SDCLK. The ratio is automatically determined by the EPDC according to . A simple
method to determine the ratio is as follows:
• When DDR_MODE = 1, RATIO = 4
• When DDR_MODE = 0
• If PIXELS_PER_SDCLK = 8, RATIO = 4
• Else, RATIO = 2
Typically it is recommended to seed these equations with an estimated (or provided)
SDCLK frequency and adjust the various timings until the desired refresh rate is attained.
The following figure shows line timing for cases, where DDR_MODE = 0 (those cases
where data is only sampled by the source driver on the rising edge of SDCLK).
Depending on the mode (see ), the ratio is a function of TFT pixel width and
PIXELS_PER_SDCLK, so the timings are shown generically. For the purposes of this
diagram, RATIO can either be 2 or 4.
RATIO x tpixclk
LS x tpixclk
LB x tpixclk
LD = HRES x (RATIO / PIXELS_PER_SDCLK) x tpixclk
LE x tpixclk
SDCLK
SDLE
SDCE
DATA
SDLE_WIDTH x tpixclk
SDCLK held low if
SDCLK_HOLD=1
(RATIO/2) x tpixclk
tpixclk
(RATIO/2) x tpixclk
Figure 23-3. Line Timing (DDR_MODE = 0)
As per , when DDR_MODE=1 (for example, for source drivers that require data to be
driven on each edge of SDCLK), the RATIO is always set to 4. The timing for such cases
is shown in the figure below.
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1046
NXP Semiconductors

<!-- page 1047 -->

4 x tpixclk
LS x tpixclk
LB x tpixclk
LD = HRES x (4 / PIXELS_PER_SDCLK) x tpixclk
LE x tpixclk
SDCLK
SDLE
SDCE
DATA
SDLE_WIDTH x tpixclk
SDCLK held low if
SDCLK_HOLD=1
tpixclk
tpixclk
tpixclk
tpixclk
tpixclk
tpixclk
tpixclk
tpixclk
Figure 23-4. Line Timing (DDR_MODE = 1) - RATIO = 4
Vertical timing or frame timing (FT) is always expressed in terms of line timing (LT).
This is shown in the following figure, followed by a detailed view of the GDCLK timing
(which has programmable duty cycle to allow programming of gate-on/gate-off time) in
Figure 23-6. The following important points should be noted in regard to gate driver
timing:
• All gate driver timing signals are independently referenced to the LINE_SYNC
leading edge (this includes GDCLK_OFFSET, GDSP_OFFSET, and
GDOE_OFFSET).
• GDSP_OFFSET is only supported for GDSP_MODE = 1
• For GDOE_MODE = 1, if GDOE is expected to be delayed relative to GDCLK, the
GDOE_OFFSET value should be set at a value appropriately greater than
GDCLK_OFFSET.
• All offset settings are programmed in terms of PIXCLK cycles.
• By default, if all offset values are set to 0, the gate driver signals are always one
PIXCLK cycle delayed from the LINE_SYNC leading edge.
• The LINE_SYNC leading edge doesn't depend on the LINE_SYNC_WIDTH value.
In cases where LINE_SYNC_WIDTH is set to some value that is less than
LINE_SYNC, a virtual leading edge which determines the line start time still exists.
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1047

<!-- page 1048 -->

sdle(FS)
GDCLK_OFFSET x tpixclk
LT
FS
GDCLK_HP x tpixclk
FB
FD = VRES x LT
FE
LT
tpixclk
GDSP_OFFSET x tpixclk
(if GDSP_MODE=0)
gdclk
(with GDCLK_OFFSET)
gdsp (mode 0)
(with GDSP_OFFSET)
gdsp (mode 1)
gdoe (mode 0)
(GDOE_OFFSET=0)
gdoe (mode 1)
(with GDOE)OFFSET
GDOE_OFFSET x tpixclk
Figure 23-5. Frame Timing (Vertical)
gdclk
LT
GDCLK_HP x tPIXCLK
Figure 23-6. GDCLK Duty Cycle
An example calculation based on the 800 x 600 E-INK 6" panel with 50 Hz waveforms is
shown be:
• PIXELS_PER_SDCLK = 4
• Ratio = 2 (2 bpp, 8-bit single-ended, SDR per )
• tPIXCLK = 17.64 MHz (assuming available chip clock frequency)
• LS = 20 x tPIXCLK
• LB = 8 x tPIXCLK
• LD = 800 x (2/4) x tPIXCLK = 400 x tPIXCLK
• LE = 142 x tPIXCLK
• LT = (20 + 8 + 400 + 142) x tPIXCLK = 32.31293 uS
LINE_SYNC_WIDTH does not affect line timing. It should be set to the same value as
LINE_SYNC, unless LB and LE are short and it is used to shorten the width of SDLE
whilst still maintaining the same line-timing.
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1048
NXP Semiconductors

<!-- page 1049 -->

It is important to meet the target line time of the panel which was 32.312 uS. Then the
frame-rate can be calculated and given the vertical timings:
• FS = 4 x LT
• FB = 4 x LT
• FD = 600 x LT
• FE = 10 x LT
• FT = (4 + 4 + 600 + 10) x LT = 50.07665 Hz
In addition to this, E-INK panels require a particular duty cycle for the GDCLK signal
which is specified as gate-on-time and gate-off-time. The sum of gate-off and gate-on
should equal LT and the value of gate-on can be programmed through
HW_EPDC_TCE_TIMING2[GDCLK_HP], or GDCLK High-Pulse time.
23.3.4.4
Source Driver and Pixel Clock Configuration
The EPDC supports a number of source driver architectures. Each architecture forces a
particular shift clock pixel rate.
In addition to this, the selection of the architecture requires a particular clock ratio
between the internal pixel clock (pixclk) and external shift clock EPDC_SDCLK. The
table below outlines the various configurations and clock ratios. It also lists the relevant
register settings for this configuration.
Table 23-1. Interface Modes
High-Level
Mode
EPDC_DATA
pins used
HW_EPDC_F
ORMAT
[TFT_PIXEL_
FORMAT]
HW_EPDC_T
CE_CTRL
[PIXELS_PE
R_SDCLK]
HW_EPDC_T
CE_CTRL
[LVDS_MOD
E]
HW_EPDC_T
CE_CTRL
[DDR_MODE
]
HW_EPDC_T
CE_CTRL
[SDDO_WID
TH]
Required
PIXCLK
(RATIO)
2bpp, 8-bit
single-ended,
SDR
[7:0]
2B[V]
FOUR
0
0
8BIT
SDCLK x 2
2bpp, 16-bit
single-ended,
SDR
[15:0]
2B[V]
EIGHT
0
0
16BIT
SDCLK x 4
2bpp, 8-bit,
DDR (LVDS
option)
[7:0],[15:8]
2B[V]
EIGHT
1|0
1
8BIT
SDCLK x 4
4bpp, 8-bit
single-ended,
SDR
[7:0]
4B[V]
TWO
0
0
8BIT
SDCLK x 2
4bpp, 16-bit,
single-ended
SDR
[15:0]
4B[V]
FOUR
0
0
16BIT
SDCLK x 2
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1049

<!-- page 1050 -->

Table 23-1. Interface Modes (continued)
High-Level
Mode
EPDC_DATA
pins used
HW_EPDC_F
ORMAT
[TFT_PIXEL_
FORMAT]
HW_EPDC_T
CE_CTRL
[PIXELS_PE
R_SDCLK]
HW_EPDC_T
CE_CTRL
[LVDS_MOD
E]
HW_EPDC_T
CE_CTRL
[DDR_MODE
]
HW_EPDC_T
CE_CTRL
[SDDO_WID
TH]
Required
PIXCLK
(RATIO)
4bpp, 8-bit,
DDR (LVDS
option)
[7:0],[15:8]
4B[V]
FOUR
1|0
1
8BIT
SDCLK x 4
4bpp, 16-bit,
single-ended,
DDR
[15:0]
4B[V]
EIGHT
0
1
16BIT
SDCLK x 4
23.3.4.5
Initializing the Display
Because of the nature of the EPD technology, a typical scenario would involve the
EPDC's working buffer (WB) being maintained in system memory. In such power states
(where memory is maintained), it is not required to initialize the display (even if the EPD
panel had been powered off for example).
In low-power modes where system memory is not maintained, there are two possible
methods to initialize the display.
The first method includes initialization from an unknown state and the second mode
simply requires software to load the last state of the WB into memory and configure the
EPDC to point to it.
23.3.4.5.1
Reset/Clocks and Buffer Preparation
In cases in which the user wants to initialize the screen to a new known state, the
following sequence should be followed. Assume that all relevant display power supplies
are active.
First, the user must complete a soft reset sequence which includes enabling the main
EPDC block-level clock gate. This sequence is described in the example code below.
Setting SFTRST enables the CLKGATE. In order to correctly cycle reset values through
pipeline registers, the CLKGATE bit stays asserted for some finite amount of time before
it sets. After this time, it is safe to clear both the SFTRST and CLKGATE. The example
below shows a typical use of these registers.
         EPDC_CTRL_SET(BM_EPDC_CTRL_SFTRST);
         while (!EPDC_CTRL.B.CLKGATE);  
         EPDC_CTRL_CLR(BM_EPDC_CTRL_SFTRST | BM_EPDC_CTRL_CLKGATE);
         while (EPDC_CTRL_RD() & (BM_EPDC_CTRL_SFTRST | BM_EPDC_CTRL_CLKGATE));
      
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1050
NXP Semiconductors

<!-- page 1051 -->

Before any display update is performed, the waveform address and working buffer (WB)
pointers must be set (both must be aligned to a 64-bit double long word address):
• EPDC_WVADDR: Must point to the base address of the waveform data (managed
by the i.MX driver)
• EPDC_WB_ADDR: An area of memory must be assigned for the EPDC's working
buffer (WB). Once assigned, this memory space should be reserved purely for the
use of the EPDC. The requirements for the memory allocation are described in
Memory Requirements.
After this, the various panel configuration parameters must be set including resolutions,
source and gate driver formats, TFT and buffer pixel formats.
23.3.4.5.2
Performing an Initialization Display Update
Once all the panel timing and format parameters are defined, a command sequence must
be sent to the EPDC with the properties found here.
• Update size must be full screen resolution
• HW_EPDC_UPD_CTRL[UPDATE_MODE] must be set to FULL
• HW_EPDC_UPD_CTRL[WAVEFORM_MODE] must be set to the INIT waveform
(typically 0x00)
• HW_EPDC_UPD_CTRL[USE_FIXED] must be set
• HW_EPDC_UPD_FIXED[FIXNP_EN], FIXCP_EN must be set to 1, and FIXNP
and FIXCP must be set to 0xFF
The use of HW_EPDC_UPD_FIXED allows the EPDC working buffer to be primed to a
state that matches the result of the initialization waveform.
If the application loads the previous WB of the EPDC, these steps are not necessary.
23.3.5
Update Buffer Analysis Functions
EPDC can perform several analyses on the update buffer.
The information collected during processing will be reported to the register after update
buffer processing is complete.
• Collision Rectangle Detection
For a collided update buffer, this function will report a minimal rectangle that can
cover all collided pixels.
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1051

<!-- page 1052 -->

When a collision occurs, it's possible that not all, but only part of that update buffer
generate a collision, so only the pixels inside a minimal collision rectangle need to be
re-submited.
Details of minimal collision rectangle reported in UPD_COL_CORD/
UPD_COL_SIZE.
• Grey Level Detection (histogram)
This function reports the minimal grey level that covers all pixels and which must be
updated. This histogram differs from that of PXP; here we ignore those pixels which
need no update, while the PXP histogram is calculated on the whole update buffer.
The histogram feature is capable of reporting a histogram for 1, 2, 4, 8, or 16 grey
levels. The valid grey levels value should be programmed into the
HIST(1/2/4/8/16)_PARAM registers before using this functionality.
• Dry-Run Mode
Dry-Run mode allows the user to run an update for the purpose of obtaining
information without performing any real action. This mode is enabled by setting
UPD_CTRL[DRY_RUN] = 1 when writing UPD_CTRL register .
In this mode, Update Buffer will be read and checked against the current Working
Buffer. As with a normal update, an interrupt will be generated when the Working
Buffer processing completes.
Several pieces of information about the update can then be acquired from the EPDC
registers: whether a collision occurred, the minimal collision area, and histogram
data.. However, the result (Next Pixel, LUT info) will not be written back into the
Working Buffer for further panel scan operation, nor will the LUT waveform be
loaded.
The LUT resource specified by UPD_CTRL[LUT_SEL] is not used here; the user
can start this dry-run update when no LUTs are available.
23.3.6
Waveform Mode Selection (AUTOWV)
This function is provided to support waveform selection based on the grey level
(histogram) information collected during the update buffer processing stage.
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1052
NXP Semiconductors

<!-- page 1053 -->

Then AUTOWV LUT is provided to hold a mapping between the grey level of NP(pixel
value from update buffer) and optimal waveform mode. This LUT mapping should be
programmed before using this function by writing into the AUTOWV_LUT register with
AUTOWV_LUT[ADDR]="grey level", AUTOWV_LUT[DATA]="waveform mode" for
each possible grey level reported by the EPDC histogram.
After AUTOWV_LUT is programmed, AUTOWV mode can be enabled by setting
UPD_CTRL[AUTOWV]=1. When enabling AUTOWV, the waveform mode written into
UPD_CTRL[WAVEFORM_MODE] will be ignored and the loading waveform will
initially be put on hold.
After the Update Buffer processing completes, EPDC reports the minimal grey level,
retrieves the mapped waveform mode from AUTOWV LUT, and writes it back into
UPD_CTRL[WAVEFORM_MODE].
If the user also sets UPD_CTRL[DRY_RUN], EPDC will be finished at this point.
Otherwise, EPDC continues with the following, depending upon the
UPD_CTRL[AUTOWV_PAUSE] setting:
1. UPD_CTRL[AUTOWV_PAUSE] = 0, AUTO MODE)
EPDC will begin waveform loading immediately without any software interaction
2. UPD_CTRL[AUTOWV_PAUSE] = 1, MANUAL MODE)
EPDC waits for software to decide whether the selected waveform is ok, then if
necessary software can use some other criteria to select a waveform mode. After
software selects the waveform mode, it writes again into UPD_CTRL with final
waveform mode, and waveform loading then panel scan will start.
NOTE
AUTOWV_PAUSE is extended for general use so that it can be
used independent of AUTOWV feature. Regardless of whether
AUTOWV is enabled or not, the user can send updates with
AUTOWV_PAUSE=1. EPDC will stop after WB processing
and pause before LUT loading and panel scan. Software can
explicitly do that latter by writing to UPD_CTRL with
AUTOWV_PAUSE=0. EPDC will ignore the Update Buffer
for this time, and kick off the LUT loading and panel scanning.
This feature allows SW modification to the working buffer after
EPDC hardware has finished processing it.
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1053

<!-- page 1054 -->

23.3.7
Panel Interface Generator (Pigeon Mode)
There are seventeen panel interface signal outputs (DATA/SDCLK not included), each of
them with dedicated timing purpose as default. This is called "Legacy Mode".
Pigeon Mode is a timing mode which can be independently enabled on any of the
seventeen timing signals, with a unified flexible configuration. Signals within pigeon
mode can be programmed into any supported signals, and are interchangable.
The following are the legecy timing signals which support pigeon mode:
• PIGEON[00] - SDCE0
• PIGEON[01] - SDCE1
• PIGEON[02] - SDCE2
• PIGEON[03] - SDCE3
• PIGEON[04] - SDCE4
• PIGEON[05] - SDCE5
• PIGEON[06] - SDCE6
• PIGEON[07] - SDCE7
• PIGEON[08] - SDCE8
• PIGEON[09] - SDCE9
• PIGEON[10] - SDOE
• PIGEON[11] - SDL3
• PIGEON[12] - SDOEZ
• PIGEON[13] - SDOED
• PIGEON[14] - GDSP
• PIGEON[15] - GDOE
Working Theory
Each pigeon signal has one local counter with a configurable start point and incremental
condition. It will be compared to configuration register value for signal assertion/de-
assertion control, plus delta offset for data alignment and other options like polarity/logic
operation. A detailed running scenario is as follows:
1. Start local counter on the MASK rising edge (reference point/start point)
2. Increment on event selected through INC_SEL
3. Count and match SET_CNT: assert signal, reset counter
( SET_CNT==0 means assert immediately on MASK's rising edge )
4. Count and match CLR_CNT: de-assert signal, stop counter
(CLR_CNT==0 means de-assert on MASK's falling edge)
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1054
NXP Semiconductors

<!-- page 1055 -->

NOTE
When local counter is running, further changes to MASK are
not cared unless CLR_CNT==0
MASK - start point for local counter
Created using any combination of below options (ANDed)
1. STATE_MASK = (FS|FB|FD|FE) AND (LS|LB|LD|LE)
8 bits to select in which vertical/horizontal state your counter starts ticking. This is
the most common use-case because timing signals generally relate to scan states.
For example, for a line timing signal start on Line Begin phase during Frame Begin/
Frame Data lines, use the configuration below:
Table 23-2. STATE_MASK
combinations
STATE_MASK
LS
LB =1
LD
LE
FS
FB =1
X
FD =1
X
FE
2. MASK_CNT/MASK_CNT_SEL(global counter)
Sometimes a more accurate reference point is required, such as" line 20 in a frame",
or "line 12 in Frame Begin state" or "pixel 23 in LD phase". For such use-cases,
several Global Counters shared by all pigeons are provided. Global counter type (line
counter/frame counter/state counter, etc.) is selected using MASK_CNT_SEL, when
global counter matches the MASK_CNT value. The pigeon local counter will start
ticking.
3. Use another pigeon signal as mask (SIG_LOGIC=MASK)
For some tightly coupled signals it is possible to use one as a reference to generate
another.
INC_SEL- select local counter tick event
1. pclk - pixel clk
2. line - line start pulse
3. frame - frame start pulse
4. another - another pigeon signal
OFFSET- offset on pclk basis
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1055

<!-- page 1056 -->

Some signals need to come out slightly earlier or later than programmed. For example,
the CE type signal usually aligns with the Line Data phase, but some panels need it as
one cycle pulse before Line Data. The user can set OFFSET to a negative value to
achieve this.
Global Counters (selectable through MASK_CNT_SEL)
• HCNT / VCNT
normal pclk counter / line counter
• HSTATE_CNT / VSTATE_CNT
similar to above, but reset when state changes
• HSTATE_CYCLE / VSTATE_CYCLE
(see figure below for definition of CYCLE/PERIOD/CNT)
Some panels have multiple Gate Drivers/Source Drivers, so Frame Data / Line Data
state may be further split to match each driver, and signals such as CE[n] are only
valid during part n of Line Data. For such signals, use
HW_EPDC_PIGEON_CTRL.*_PERIOD to specify PERIOD where CNT is reset
and CYCLE is included. Then the user can select CYCLE as MASK_CNT to
generate mask for CE[n].
• FRAME_CNT / FRAME_CYCLE (only for frame-crossing signals)
frame cycle counter doesn't have a reset condition; use
HW_EPDC_PIGEON_CTRL1.FRAME_CNT_CYCLES to reset it.
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1056
NXP Semiconductors

<!-- page 1057 -->

1
2
1
2
1
2
1
2
3
LINE_DATA
PERIOD=2
CYCLES=3
clock
hscan state
CNT
CYCLE
CE[1] mask_cnt=1
CE[2] mask_cnt=2
Figure 23-7. Definition of CNT, CYCLE, PERIOD
The following are register settings for the figure above:
• HW_EPDC_PIGEON_CTRL0.LD_PERIOD=2
• MASK_CNT_SEL = 1 // HSTATE_CYCLE
• MASK_CNT = 1 // CE[1]
• MASK_CNT = 2 // CE[2]
23.3.8
Display Update Programming
The EPDC is designed to communicate with the kernel driver through the interrupts and
status registers.
The driver entry is always assumed to occur as a result of an interrupt.
23.3.8.1
Initiating a Display Update
The typical flow for performing a display update involves the following:
• EPDC_STATUS[WB_BUSY] must be 0. The EPDC cannot process new updates if
it is currently processing an update.
• EPDC_STATUS[LUTS_BUSY] must be 0. The EPDC cannot accept new updates if
all LUT resources are currently active.
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1057

<!-- page 1058 -->

Assuming both conditions above are met, an update request is programmed in the
following manner (it is important to note that the last step must be writing to
EPDC_UPD_CTRL which initiates the display update).
The following steps can be performed before WB_BUSY and LUTS_BUSY are clear:
• At this time it is assumed that the correct temperature is selected and written to
EPDC_TEMP.
• EPDC_UPD_ADDR must be set to the 8-bit buffer for the update if stride feature
not enabled (when enabled stride feature, no requirement on align ). This buffer
must be aligned to a 64-bit word address. In addition, each line address must begin at
a 64-bit word address. Both criteria can be met by utilizing the PXP pixel processing
engine which always aligns lines at a 64-bit raster (see Memory Requirements for
details).
• EPDC_UPD_CORD defines the insertion co-ordinate into the panel resolution.
• EPDC_UPD_SIZE defines the dimension of the update (pixels).
• EPDC_UPD_FIXED is used for panel initialization or rectangular fill operations.
Writing the EPDC_UPD_CTRL register initiates a display update:
• USE_FIXED-This field is set when EPDC_UPD_FIXED is used.
• LUT_SEL-The driver should read EPDC_STATUS_NEXLUT[NEXT_LUT]
(qualified by NEXT_LUT_VALID) to select an available LUT to assign this update.
• WAVEFORM_MODE selects the E-INK waveform mode (for example, INIT, DU,
GC16 and so on). The number corresponds to the waveform number in the waveform
specification document.
• UPDATE_MODE selects one of two enumerated updated modes.
• FULL-In this mode, all pixels defined in the update rectangle have the waveform
applied.
• PARTIAL-In this mode, the EPDC shall only apply the waveform to pixels
which are changing, otherwise the EPDC_FORMAT[DEFAULT_TFT_PIXEL]
is applied to the pixels which are not changing.
23.3.8.2
Update Processing and Collisions
After the update is initiated (by writing EPDC_UPD_CTRL), the EPDC performs update-
buffer processing. This involves processing this update region into its working buffer
(WB).
During this time, the EPDC also performs collision detection. At the end of the WB
processing, the EPDC asserts the WB_CMPLT_IRQ interrupt. If a collision is detected,
the LUT_COL_IRQ interrupt status bit will also be asserted.
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1058
NXP Semiconductors

<!-- page 1059 -->

The EPDC performs image updates to the EPD by applying waveforms to individual
pixels. Waveforms are applied to groups of pixels (ranging from a single pixel to the
entire display). Each individual update request is bound to a rectangle. Each pixel within
this rectangle has a waveform applied to it using the waveform and update mode
specified in EPDC_UPD_CTRL. After this process is initiated, a waveform takes an
amount of time to complete which is usually determined by the specifications of the
waveform mode. For proper display operation and optimum performance, a waveform
must not be interrupted once it has begun.
A collision is defined simply as the interruption of the application of waveform to a pixel
or group of pixels. As such, it must be avoided. Because the waveforms take a finite
amount of time to complete, the EPDC provides a mechanism to automatically manage
collisions, which allows the application to perform multiple updates resulting in a richer
user experience without having to be cognizant of the panel and waveform
characteristics.
Depending on the update mode (FULL or PARTIAL) a collision is defined as follows:
• For a full-update mode, a collision is defined as the temporal and spatial union of
rectangles pertaining to active unique update requests. An active update is one which
is still in the process of being updated (that is, a waveform is being applied).
• For a partial-update mode, a collision is defined as the temporal, spatial and
differential union of pixels pertaining to unique update requests which are active.
The difference between a full-updated and a partial-updated collision is that in the
latter case, the collision state occurs only if the next-pixel states differ between the
updates. Thus, two partial-update rectangles may intersect, but if all of the pixels in
the intersecting update regions are being updated to the same gray-state, the original
update and associated LUT/waveform are not disturbed and the intersection does not
constitute a collision.
• It should be noted that collisions may be a one-to-many effect. In the case of partial
updates, there may be a spatial and temporal union of rectangles with no differential
pixel-level union. A subsequent update however might form such a pixel-level
differential union to all active updates. Since each update pertains to an active LUT,
these many collided updates are refered to as victim LUTs. The update/LUT that
caused the collision is referred to as the aggressor LUT.
An example of a partial-update mode collision is shown in the following figure. Each
update encompasses the outer rectangle which meets the criteria of the spatial union. The
red areas show the pixels which are currently transitioning to gray (from update 1) but
need to transition to white (in update 2). These pixels meet the criteria of the differential
union and lastly in the temporal domain, the period of time where LUT0 and LUT1
overlap is the temporal union. The pixels that did not change (grey and green areas in the
LUT assignment box) are not part of the collision area. In the case of the gray
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1059

<!-- page 1060 -->

overlapping pixels, LUT0 can continue to update. In the case of the white pixels (which
were previously inactive) a new LUT (if available can be assigned) and forms the green
region. Note that a subsequent update could potentially collide with the green pixels in
update 2.
Update 1
Update 2
Differential union
Differential union
Spatial
union
LUT
assignment
LUT0
Violation window
LUT1
Temporal union
Quiescent pixels within the update region
Assigned to LUT0 (Update 2 leaves these overlapping pixels unchanged in the WB)
Assigned to LUT1
Collision (pixels updating by LUT0 which is active)
Figure 23-8. Partial Update Collision Handling
NOTE
For FULL update modes, a collision occurs at any intersection
of active rectangles/LUTs because in FULL update mode, all
pixels within the update rectangle have the waveform applied
(even if pixel values are not changing).
It can be seen that when collision is detected (during the WB update process), the EPDC
will "block" the collided pixels being updated, and any pixels which are not collided will
be assigned to the requested LUT process. When a collision occurs, the EPDC will raise
the LUT_COL_IRQ interrupt status bit (this will always happen in conjunction with
WB_CMPLT_IRQ).
Because the driver is always entered via an interrupt, when the EPDC interrupt fires,
driver should not only check for WB_CMPLT_IRQ but also for the LUT_COL_IRQ
status bit within the EPDC_IRQ register. If LUT_COL_IRQ is set, this means that a
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1060
NXP Semiconductors

<!-- page 1061 -->

collision has occurred. If this is the case the driver should check the value of the
EPDC_STATUS_COL register. This register contains one bit for each LUT that has been
collided with, that is, it holds the vector of the victim LUTs as a result of the last update
LUT. Since the driver knows the value of the LUT of the last update, it can store this
update LUT value along with this associated victim LUT vector in a collision list.
Because the EPDC can drive up to 16 concurrent updates (which can be overlapping
when using PARTIAL mode updates), a unique interrupt status bit is provided per LUT
so that when an update completes (physically completes the waveform), the SW driver
can know which LUT completed. In addition to the LUT completion interrupts (which
are mapped into the EPDC_IRQ[LUTn_CMPLT_IRQ] interrupt status bits), the current
state of each LUT can also be read from the EPDC_STATUS_LUTS status register.
The driver can use the LUT status interrupts in conjunction with EPDC_STATUS_LUTS
to perform regular checks on the completion of victim LUTs against the vectors stored
for each colliding LUT in the collision list. The driver may also choose to serialize
updates such that it might wait until all victim LUTs have completed before re-issuing the
colliding update.
The figure below shows a more extended sequence of a collision. In this case there are a
series of updates coming from the application layer. They are A, B, C and D. Updates A,
B, and C are set without any collision. When update D is requested a collision is detected.
Using the interrupt status collision registers, the SW-driver stores D in a collision-list.
For that list entry it also store B which is the victim LUT. It uses this information to
check when a LUT completes to see if the victim LUTs for any update in the collision list
have completed. If they have completed (through a LUT completion interrupt), the SW-
driver then sends this update (D in this case) again to the EPDC. It should be noted that
from the application perspective it appears that all updates A, B, C and D have been
accepted, that is, the collision handling is completely hidden from user-space. Using the
collision detection and LUT status interrupts, the application (in conjunction with the
driver) could also choose to completely serialize the requests (such that between the first
and second D update, no other update is accepted).
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1061

<!-- page 1062 -->

A
Partial
Partial
Partial
Partial
Retry
B Complete
Collision
with B
WB
WB
WB
LUT0
LUT1
LUT0
LUT2
LUT1
LUT0
LUT2
B
D
D
LUT0
LUT1
LUT2
WB
C
TFT
LUT0
LUT1
WB
LUT2
Time
LUT1
Figure 23-9. Collision Sequence
23.3.8.3
Multiple Update Flow
In most applications, such as e-book readers, besides full-screen page turns, user
interfaces require multiple updates to be performed.
Examples of this include cursors, pen input, drop-down menus (with highlighting) and
other movable graphical objects. Each update takes such a limited amount of time to
complete (up to 1 second depending on the waveform mode) that it would be too
prohibitive to only process updates serially.
As described in Initiating a Display Update, there are two conditions that must be met
before the SW driver can issue a new update request:
• The Working buffer (WB) update process must be complete.
• There must be an available LUT.
Assuming a free LUT is available, the EPDC is designed to have the capability to start
new updates at each TFT frame scan (even being able to commence multiple updates
within a frame scan blanking period). The general flow for sequential updates (concurrent
or serialized) is shown in the following figure.
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1062
NXP Semiconductors

<!-- page 1063 -->

LUTS_BUSY
DRIVER
ENTRY
All LUTs
active
(BUSY)
WB
Processing
(BUSY)
WB_CMPLT_IRQ
LUT_COL_IRQ
If (!(WB_BUSY || LUTS_BUSY)) {
Update Req()
}
WB_BUSY
Activated last free LUT
Update request from application
EPDC_IRQ[LUTn_CMPLT_IRQ]
Figure 23-10. Driver Update Flow
This flow assumes that the driver is entered via interrupts. The two busy states are shown
to illustrate the conditions under which the driver will not issue new updates. In general,
the driver should be throttled by the WB_CMPLT_IRQ interrupt. Because the EPDC can
support up to 64 concurrent updates, it is possible to re-enter the update-request (show as
Update_Req() in the figure above) any-time that the WB is not busy (even though LUTs
are active and the display is being updated). It is possible that when there are 63 LUTs
currently active and a new update is sent, there will be a WB_CMPLT_IRQ interrupt
issued, but the driver at that time would be in a busy state (because LUTS_BUSY is
signaled). The driver will be re-entered on the next LUTn_CMPLT_IRQ interrupt during
which time it can issue a new update (since WB_BUSY and LUTS_BUSY status bits are
low).
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1063

<!-- page 1064 -->

The update-processing process (which is controlled by the MBM module) is
asynchronous to the actual TFT refresh operations (which carry out the physical screen
updates), so there is no particular relationship between the WB_BUSY status and the
state of the screen update. In contrast, the LUTn_CMPLT_IRQ interrupt status and
EPDC_STATUS_LUTS provide the status of the physical waveform update. This means
that when LUTn_CMPLT_IRQ interrupt fires, it means that the last physical TFT frame
scan just completed for that update/LUT.
The EPDC implements proprietary methods to efficiently process the WB such that the
WB processing time (the time from the SW driver writing EPDC_UPD_CTRL to
EPDC_IRQ[WB_CMPLT_IRQ] fires), is dependent on the size of the update rectangle.
This allows smaller updates to be processed faster. In most EPD applications, this is ideal
because it's typically smaller sprites that require the fastest performance. In addition, the
EPDC implements methods to allow store pending updates and activate them on the next
available frame-scan. For example, if the TFT scanning is currently in the active region
and during this time a series of small update requests are sent, the EPDC can begin all of
those updates on the next available blanking period.
The figure below shows an example of two larger update requests, one to LUT4 and one
to LUT5. These update requests are shown in the context of active LUTs and thus active
frame scan times. The time when both WB_BUSY and LUT_BUSY is high are defined
as "blocking" because no new updates can be accepted. It should also be noted that new
updates are physically commenced by the EPDC on blanking periods. From a SW
programming model perspective, the EPDC_STATUS_LUTS[LUTn_STATUS] is
activated immediately upon the update request being written to the EPDC. The physical
frame-scanning for this particular update does not being commenced until the next
available frame scan.
It should be noted that updates and WB processing can actually occur during the blanking
period (or can begin in the active scan time and continue into the blanking period). For
this reason, the EPDC provides some tuning controls via
EPDC_TCE_CTRL[VSCAN_HOLDOFF] such that more time can be given to finish
processing update request and less time "locking down" the set of LUTs that will be
activated for the upcoming active scan. The EPDC will start to pre-fill its refresh pixel
FIFOs after the VSCAN_HOLDOFF period. Its possible to tune this value to allow the
minimum time for the pixel FIFO pre-fill operation (making sure that refresh under-runs
do not occur). If a pixel-FIFO under-run occurs, EPDC_IRQ[TCE_UNDERRUN_IRQ]
will fire.
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1064
NXP Semiconductors

<!-- page 1065 -->

Blank
SW
Operation
HW
Operation
Update Request to LUT4 Issued
Set HW_EPDC_STATUS[LUTS_BUSY] = 1
Set HW_EPDC_STATUS[WB_BUSY] = 1
WB Update by EPDC (includes collision detection)
Blocking since WB Busy
Set HW_EPDC_STATUS[WB_BUSY] = 0
Blocking Period Since all LUTs full
LUT5_CMPLT_IRQ fires
Set HW_EPDC_STATUS[LUTS_BUSY] = 0
Set HW_EPDC_STATUS[LUTS_BUSY] = 1
Set HW_EPDC_STATUS[WB_BUSY] = 1
Update Request to LUT5 Issued
Blank
Blank
Frame N
Frame N+1
Frame N+2
Set HW_EPDC_STATUS[WB_BUSY] = 0
WB Update by EPDC (includes collision detection)
Blocking since WB Busy
Blocking Period Since all LUTs full
LUT4 - Dormant
LUT5 - Active
LUT4 Activated
LUT5 - Dormant
LUT5 
Activated
LUT0,1,2,3,6,7,8,9,10,11,12,13,14,15 All Active
Time
Figure 23-11. Temporal Flow of Update Processing
23.3.9
Architectural Clock Gating (Low Power Mode)
As with most modern IP, the EPDC contains low-level hardware controlled automatic
clock gating throughout the design.
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1065

<!-- page 1066 -->

These clock gating elements typically gate clocks locally for individual or groups of
sequential elements (flip flops) when these registers are not currently active.
This tier of clock gating is useful for reducing power during active operation of the
EPDC.
Most e-paper applications utilizing EPDs involve the processor and display controller to
be a low-power inactive state in most of the time. This is because EPDs only require
refresh operations when the display content is being updated. As such, in between update
operations, the EPDC provides a module level clock-gating feature that can be controlled
by the SW driver as part of a higher-level power management solution.
The EPDC module can have all its clocks completely gated-off by the setting of
EPDC_CTRL[CLKGATE]. There are a couple of considerations that the SW driver must
adhere to before placing the EPDC into this low power state:
• All active LUTs (updates) must complete
• Any TFT operations must be complete (including any final blanking operations)
In order to maximize display update frequency (the ability accept new updates during
each frame scan), the LUT completion interrupts fire on the end of the last frame's active
scan period for that update. This means that the TCE still must compete the final
FRAME_END blanking time to guarantee coherency of its state machines with the panel
state (receiving the final LUT completion IRQ is not enough to determine that the EPDC
can have all of its clocks shut down). Based on this, the EPDC provides the necessary
interrupt and status bits to allow the driver to correctly perform the clock-gating
operation by using the following method:
• Once the final EPDC_IRQ[LUTn_CMPLT_IRQ] is reached, the driver should enable
the TCE_IDLE interrupt mask bit via EPDC_IRQ_MASK[TCE_IDLE_IRQ_EN],
unmask other interrupts and return.
• Once the final blanking time of the last LUT (FRAME_END time) is completed and
the TCE reaches its idle state, the EPDC will assert the
EPDC_IRQ[TCE_IDLE_IRQ] interrupt which will cause the driver to re-enter. At
this point, the SW knows that the EPDC is in a completely idle state and can perform
a set on EPDC_CTRL[CLKGATE].
Alternative implementations of the driver could simply involve polling for the
EPDC_IRQ[TCE_IDLE_IRQ] interrupt status bit (which operates regardless of the
interrupt being masked or not) before setting the clock gate (this prevents two iterations
of interrupt based driver-entry, but requires a wait loop in the interrupt handler which
might be undesirable).
It should be noted that the time interval between the last LUTs LUTn_CMPLT_IRQ time
and TCE_IDLE_IRQ interrupt is equal to the FRAME_END time.
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1066
NXP Semiconductors

<!-- page 1067 -->

When the application is ready to send more updates, the driver can immediately re-enable
the EPDC by un-gating the module-level clock by clearing the
EPDC_CTRL[CLKGATE] field. This un-gating of the clock is instant and the driver is
free to immediately send update requests.
23.3.10
Performance Tuning and Considerations
The EPDC is designed to meet the performance requirements of the most demanding e-
paper applications. These performance targets must be met in the context of highly
integrated SoCs.
In such a context, system memory is typically shared across multiple masters including
the Arm platform. Because of this, there is no guarantee of latency from system memory.
EPDC provides a number of mechanisms to deal with this as well as some ability to tune
various parameters allowing the user to trade-off between update processing performance
and refresh functionality.
23.3.10.1
Memory and Bus Bandwidth Requirements
The EPDC MBM module contains up to 6 internal AXI requesting functions (5 read and
1 write). These are arbitrated internally before being sent to the SoC memory system.
The EPDC interfaces to the SoC bus system via a dual-channel 64-bit AXI bus master
port. The following table shows the various internal requesters and their properties. Note
that there are two round-robin (RR) loops. Because there is only one write source, and the
EPDC supports dual-channel AXI, there is no arbitration on the WB write operations.
Table 23-3. EPDC Bus Requestor Profiles
Operation
Priority
Burst Length
(x8 Bytes)
Maximum
Outstanding
Transactions
FIFO size
Waveform LUT read
0
8
2
16x68
WB pixel read FIFO0 (refresh)
RR 1
8 or 16
8
256x64
WB pixel read FIFO1 (refresh)
RR 1
8 or 16
8
256x64
WB read for update processing
RR 2
8
2
16x64
WB write for update processing
N/A
8
2
16x64
UPD read for update processing
RR 2
8
2
16x64
As described in Memory Requirements, it can be seen that all lines in a buffer are padded
to the nearest 8 byte boundary. This is important to be noted for the bandwidth
calculations. The maximum bandwidth scenario involves processing a full-screen update
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1067

<!-- page 1068 -->

while performing refresh operations, but refresh operations always have the highest
priority. Based on this, the memory bandwidth required by the EPDC is a function of the
refresh pixel rate which in turn is a function of resolution, frame-rate and blanking/active
time.
The refresh bandwidth can be calculated as follows:
Active Time = Active time of the frame-scan time as a fraction (for example, 0.8)
Frame Rate = TFT frame refresh rate (Hz) (for example, 106 Hz)
Bandwidth (MB/s) = roundup4(EPDC_RES[HORIZONTAL]) x
EPDC_RES[VERTICAL] x Frame Rate x (1/Active Time) x 2 x(1/10242)
For example, a panel with resolution 2048 x 1536 with 106 Hz refresh and estimated 80%
active time, 20% blanking time, the refresh bandwidth is:
BW (MB/S) = 2048 x1536 x 106 x (1/0.8) x 2 x (1/10242) = 795 MB/s
(Note that 2048 mod 4 = 0.)
The WB requires 2 bytes per pixel.
Remaining bandwidth is used for other operations. Because update processing operations
are not real-time (they do not necessarily have to occur at the refresh frame-rate), the time
required to perform the update can be calculated as a function of the available bandwidth
(actual bandwidth minus refresh bandwidth) and the update size.
23.3.10.2
Pixel Latency FIFO
The EPDC contains one working buffer latency FIFO which is used to load working
buffer pixel data which is used by the TCE to perform the panel refresh operations.
The FIFO is sized at 1024 pixels each in order to provide significant system memory
latency tolerance. The pixel FIFO is dedicated for the main screen.
Under no circumstance should the EPDC pixel FIFO reach an under-run condition. The
EPDC provides an interrupt status bit to flag such a condition (TCE_UNDERRUN_IRQ).
During development, this interrupt must be enabled. The pixel values stored in the FIFO
are using by the TCE to perform look-up operations (from the LUTs) to generate TFT
voltage control pixels. If an under-run occurs, the result will be unknown data being used
as the source for the look-ups, which can damage the panel.
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1068
NXP Semiconductors

<!-- page 1069 -->

23.3.10.3
Basic Watermarking Control
The EPDC provides a basic pixel pre-fetching control mechanism that is applied to the
beginning of a new update (from an idle state). This control is provided by
EPDC_FIFOCTRL[FIFO_INIT_LEVEL].
The control allows the value to be set between 0-255, with a reset value of 128. Because
the internal width of the FIFO holds 4-pixels per entry, the actual number of pixels is
(FIFO_INIT_LEVEL+1) x 4.
The EPDC uses this value to pre-fill the pixel latency FIFO(s) to this level before the
TCE commences the refresh operations which drive the update to the panel. This control
has no effect on the FIFO(s) when the EPDC is performing sequential frame-scans.
It must be noted that this value must be set less than (EPDC_RES[VERTICAL] x
EPDC_RE[HORIZONTAL]) /4.
23.3.10.4
Update/Refresh Tuning (VSCAN_HOLDOFF)
During active frame-scan time, the EPDC provides the ability to process and display new
update requests, because all pixels in the WB pertaining to a particular update are bound
to a single LUT.
Until all pixels pertaining to that update have been processed in the WB, its LUT cannot
be activated. As shown in Figure 23-11, the blanking period provides time to pre-load the
pixel FIFOs and for completing WB processing updates and loading the associated frame
of waveform data into LUT memories.
The EPDC_TCE_CTRL[VSCAN_HOLDOFF] control field allows control over the
vertical blanking period allotment for working buffer processing and pre-loading of the
pixel FIFO. The time window defined by VSCAN_HOLDOFF is allotted for working-
buffer processing and LUT loading (of newly processed updates). The remainder of the
time is allotted for pre-filling the pixel FIFO.
Note that aggressive use of VSCAN_HOLDOFF can result in pixel FIFO under-run as
the FIFO pre-fill time is compromised.
23.3.10.5
System-Level Arbitration Control
As previously mentioned, the TCE refresh operation is time critical.
Because the EPDC is designed to be integrated into a multimaster SoC, system memory
is shared between multiple requesters in the system.
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1069

<!-- page 1070 -->

The EPDC provides a dynamic Quality of Service (QoS) priority elevation mechanism
that can be leveraged at the SoC level.
The EPDC_FIFOCTRL registers can be used to drive the epdc_panic output signal
during times when the EPDC requests require priority elevation. As long as epdc_panic is
asserted, transaction requests from the EPDC will have their priority elevated at the SoC-
level bus arbitration control points.
The registers and associated functionality are as follows:
• EPDC_FIFOCTRL[ENABLE_PRIORITY] must be set to enable epdc_panic
functionality.
• EPDC_FIFOCTRL[FIFO_L_LEVEL] determines FIFO threshold which causes
epdc_panic to assert when crossed.
• EPDC_FIFOCTRL[FIFO_H_LEVEL] once epdc_panic has been asserted due to the
pixel FIFO(s) crossing FIFO_L_LEVEL, this value, which must be set higher than
FIFO_L_LEVEL, determines the point at which epdc_panic will de-assert as the
FIFO(s) fills.
Note that the delta between FIFO_H_LEVEL and FIFO_L_LEVEL is intended as a de-
bounce mechanism. The purpose is to avoid a constant panic situation, which would
cause thrashing of the epdc_panic signal.
Programming Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1070
NXP Semiconductors

<!-- page 1071 -->

epdc_panic = 0
epdc_panic = 0
epdc_panic = 1
"de-bounce"
region
FIFO_H_LEVEL
FIFO_L_LEVEL
Figure 23-12. FIFO Priority Elevation
23.4
EPDC Memory Map/Register Definition
EPDC Register Format Summary
EPDC memory map
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
228_C000
EPDC Control Register (EPDC_CTRL)
32
R/W
C000_0000h
23.4.1/1080
228_C004
EPDC Control Register (EPDC_CTRL_SET)
32
R/W
C000_0000h
23.4.1/1080
228_C008
EPDC Control Register (EPDC_CTRL_CLR)
32
R/W
C000_0000h
23.4.1/1080
228_C00C
EPDC Control Register (EPDC_CTRL_TOG)
32
R/W
C000_0000h
23.4.1/1080
228_C010
EPDC Working Buffer Address for TCE
(EPDC_WB_ADDR_TCE)
32
R/W
0000_0000h
23.4.2/1082
228_C020
EPDC Waveform Address Pointer (EPDC_WVADDR)
32
R/W
0000_0000h
23.4.3/1082
228_C030
EPDC Working Buffer Address (EPDC_WB_ADDR)
32
R/W
0000_0000h
23.4.4/1083
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1071

<!-- page 1072 -->

EPDC memory map (continued)
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
228_C040
EPDC Screen Resolution (EPDC_RES)
32
R/W
0000_0000h
23.4.5/1083
228_C050
EPDC Format Control Register (EPDC_FORMAT)
32
R/W
0000_0000h
23.4.6/1084
228_C054
EPDC Format Control Register (EPDC_FORMAT_SET)
32
R/W
0000_0000h
23.4.6/1084
228_C058
EPDC Format Control Register (EPDC_FORMAT_CLR)
32
R/W
0000_0000h
23.4.6/1084
228_C05C
EPDC Format Control Register (EPDC_FORMAT_TOG)
32
R/W
0000_0000h
23.4.6/1084
228_C060
Working Buffer Field Setting (EPDC_WB_FIELD0)
32
R/W
0000_8AA5h
23.4.7/1086
228_C070
Working Buffer Field Setting (EPDC_WB_FIELD1)
32
R/W
0000_A003h
23.4.8/1087
228_C080
Working Buffer Field Setting (EPDC_WB_FIELD2)
32
R/W
0000_C443h
23.4.9/1088
228_C090
Working Buffer Field Setting (EPDC_WB_FIELD3)
32
R/W
0000_6880h
23.4.10/
1089
228_C0A0
EPDC FIFO control register (EPDC_FIFOCTRL)
32
R/W
0080_0000h
23.4.11/
1089
228_C0A4
EPDC FIFO control register (EPDC_FIFOCTRL_SET)
32
R/W
0080_0000h
23.4.11/
1089
228_C0A8
EPDC FIFO control register (EPDC_FIFOCTRL_CLR)
32
R/W
0080_0000h
23.4.11/
1089
228_C0AC
EPDC FIFO control register (EPDC_FIFOCTRL_TOG)
32
R/W
0080_0000h
23.4.11/
1089
228_C100
EPDC Update Region Address (EPDC_UPD_ADDR)
32
R/W
0000_0000h
23.4.12/
1090
228_C110
EPDC Update Region Stride (EPDC_UPD_STRIDE)
32
R/W
0000_0000h
23.4.13/
1091
228_C120
EPDC Update Command Co-ordinate (EPDC_UPD_CORD)
32
R/W
0000_0000h
23.4.14/
1092
228_C140
EPDC Update Command Size (EPDC_UPD_SIZE)
32
R/W
0000_0000h
23.4.15/
1092
228_C160
EPDC Update Command Control (EPDC_UPD_CTRL)
32
R/W
0000_0000h
23.4.16/
1093
228_C164
EPDC Update Command Control (EPDC_UPD_CTRL_SET)
32
R/W
0000_0000h
23.4.16/
1093
228_C168
EPDC Update Command Control (EPDC_UPD_CTRL_CLR)
32
R/W
0000_0000h
23.4.16/
1093
228_C16C
EPDC Update Command Control
(EPDC_UPD_CTRL_TOG)
32
R/W
0000_0000h
23.4.16/
1093
228_C180
EPDC Update Fixed Pixel Control (EPDC_UPD_FIXED)
32
R/W
0000_0000h
23.4.17/
1094
228_C184
EPDC Update Fixed Pixel Control
(EPDC_UPD_FIXED_SET)
32
R/W
0000_0000h
23.4.17/
1094
228_C188
EPDC Update Fixed Pixel Control
(EPDC_UPD_FIXED_CLR)
32
R/W
0000_0000h
23.4.17/
1094
228_C18C
EPDC Update Fixed Pixel Control
(EPDC_UPD_FIXED_TOG)
32
R/W
0000_0000h
23.4.17/
1094
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1072
NXP Semiconductors

<!-- page 1073 -->

EPDC memory map (continued)
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
228_C1A0
EPDC Temperature Register (EPDC_TEMP)
32
R/W
0000_0000h
23.4.18/
1095
228_C1C0
Waveform Mode Lookup Table Control Register.
(EPDC_AUTOWV_LUT)
32
R/W
0000_0000h
23.4.19/
1095
228_C1E0
EPDC LUT Standby Register for LUT 31~0
(EPDC_LUT_STANDBY1)
32
R/W
0000_0000h
23.4.20/
1096
228_C1E4
EPDC LUT Standby Register for LUT 31~0
(EPDC_LUT_STANDBY1_SET)
32
R/W
0000_0000h
23.4.20/
1096
228_C1E8
EPDC LUT Standby Register for LUT 31~0
(EPDC_LUT_STANDBY1_CLR)
32
R/W
0000_0000h
23.4.20/
1096
228_C1EC
EPDC LUT Standby Register for LUT 31~0
(EPDC_LUT_STANDBY1_TOG)
32
R/W
0000_0000h
23.4.20/
1096
228_C1F0
EPDC LUT Standby Registerr for LUT 63~32
(EPDC_LUT_STANDBY2)
32
R/W
0000_0000h
23.4.21/
1096
228_C1F4
EPDC LUT Standby Registerr for LUT 63~32
(EPDC_LUT_STANDBY2_SET)
32
R/W
0000_0000h
23.4.21/
1096
228_C1F8
EPDC LUT Standby Registerr for LUT 63~32
(EPDC_LUT_STANDBY2_CLR)
32
R/W
0000_0000h
23.4.21/
1096
228_C1FC
EPDC LUT Standby Registerr for LUT 63~32
(EPDC_LUT_STANDBY2_TOG)
32
R/W
0000_0000h
23.4.21/
1096
228_C200
EPDC Timing Control Engine Control Register
(EPDC_TCE_CTRL)
32
R/W
0000_0010h
23.4.22/
1096
228_C204
EPDC Timing Control Engine Control Register
(EPDC_TCE_CTRL_SET)
32
R/W
0000_0010h
23.4.22/
1096
228_C208
EPDC Timing Control Engine Control Register
(EPDC_TCE_CTRL_CLR)
32
R/W
0000_0010h
23.4.22/
1096
228_C20C
EPDC Timing Control Engine Control Register
(EPDC_TCE_CTRL_TOG)
32
R/W
0000_0010h
23.4.22/
1096
228_C220
EPDC Timing Control Engine Source-Driver Config Register
(EPDC_TCE_SDCFG)
32
R/W
0000_0000h
23.4.23/
1099
228_C224
EPDC Timing Control Engine Source-Driver Config Register
(EPDC_TCE_SDCFG_SET)
32
R/W
0000_0000h
23.4.23/
1099
228_C228
EPDC Timing Control Engine Source-Driver Config Register
(EPDC_TCE_SDCFG_CLR)
32
R/W
0000_0000h
23.4.23/
1099
228_C22C
EPDC Timing Control Engine Source-Driver Config Register
(EPDC_TCE_SDCFG_TOG)
32
R/W
0000_0000h
23.4.23/
1099
228_C240
EPDC Timing Control Engine Gate-Driver Config Register
(EPDC_TCE_GDCFG)
32
R/W
0000_0000h
23.4.24/
1100
228_C244
EPDC Timing Control Engine Gate-Driver Config Register
(EPDC_TCE_GDCFG_SET)
32
R/W
0000_0000h
23.4.24/
1100
228_C248
EPDC Timing Control Engine Gate-Driver Config Register
(EPDC_TCE_GDCFG_CLR)
32
R/W
0000_0000h
23.4.24/
1100
228_C24C
EPDC Timing Control Engine Gate-Driver Config Register
(EPDC_TCE_GDCFG_TOG)
32
R/W
0000_0000h
23.4.24/
1100
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1073

<!-- page 1074 -->

EPDC memory map (continued)
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
228_C260
EPDC Timing Control Engine Horizontal Timing Register 1
(EPDC_TCE_HSCAN1)
32
R/W
0000_0000h
23.4.25/
1101
228_C264
EPDC Timing Control Engine Horizontal Timing Register 1
(EPDC_TCE_HSCAN1_SET)
32
R/W
0000_0000h
23.4.25/
1101
228_C268
EPDC Timing Control Engine Horizontal Timing Register 1
(EPDC_TCE_HSCAN1_CLR)
32
R/W
0000_0000h
23.4.25/
1101
228_C26C
EPDC Timing Control Engine Horizontal Timing Register 1
(EPDC_TCE_HSCAN1_TOG)
32
R/W
0000_0000h
23.4.25/
1101
228_C280
EPDC Timing Control Engine Horizontal Timing Register 2
(EPDC_TCE_HSCAN2)
32
R/W
0000_0000h
23.4.26/
1101
228_C284
EPDC Timing Control Engine Horizontal Timing Register 2
(EPDC_TCE_HSCAN2_SET)
32
R/W
0000_0000h
23.4.26/
1101
228_C288
EPDC Timing Control Engine Horizontal Timing Register 2
(EPDC_TCE_HSCAN2_CLR)
32
R/W
0000_0000h
23.4.26/
1101
228_C28C
EPDC Timing Control Engine Horizontal Timing Register 2
(EPDC_TCE_HSCAN2_TOG)
32
R/W
0000_0000h
23.4.26/
1101
228_C2A0
EPDC Timing Control Engine Vertical Timing Register
(EPDC_TCE_VSCAN)
32
R/W
0000_0000h
23.4.27/
1102
228_C2A4
EPDC Timing Control Engine Vertical Timing Register
(EPDC_TCE_VSCAN_SET)
32
R/W
0000_0000h
23.4.27/
1102
228_C2A8
EPDC Timing Control Engine Vertical Timing Register
(EPDC_TCE_VSCAN_CLR)
32
R/W
0000_0000h
23.4.27/
1102
228_C2AC
EPDC Timing Control Engine Vertical Timing Register
(EPDC_TCE_VSCAN_TOG)
32
R/W
0000_0000h
23.4.27/
1102
228_C2C0
EPDC Timing Control Engine OE timing control Register
(EPDC_TCE_OE)
32
R/W
0000_0000h
23.4.28/
1102
228_C2C4
EPDC Timing Control Engine OE timing control Register
(EPDC_TCE_OE_SET)
32
R/W
0000_0000h
23.4.28/
1102
228_C2C8
EPDC Timing Control Engine OE timing control Register
(EPDC_TCE_OE_CLR)
32
R/W
0000_0000h
23.4.28/
1102
228_C2CC
EPDC Timing Control Engine OE timing control Register
(EPDC_TCE_OE_TOG)
32
R/W
0000_0000h
23.4.28/
1102
228_C2E0
EPDC Timing Control Engine Driver Polarity Register
(EPDC_TCE_POLARITY)
32
R/W
0000_001Eh
23.4.29/
1103
228_C2E4
EPDC Timing Control Engine Driver Polarity Register
(EPDC_TCE_POLARITY_SET)
32
R/W
0000_001Eh
23.4.29/
1103
228_C2E8
EPDC Timing Control Engine Driver Polarity Register
(EPDC_TCE_POLARITY_CLR)
32
R/W
0000_001Eh
23.4.29/
1103
228_C2EC
EPDC Timing Control Engine Driver Polarity Register
(EPDC_TCE_POLARITY_TOG)
32
R/W
0000_001Eh
23.4.29/
1103
228_C300
EPDC Timing Control Engine Timing Register 1
(EPDC_TCE_TIMING1)
32
R/W
0000_0000h
23.4.30/
1104
228_C304
EPDC Timing Control Engine Timing Register 1
(EPDC_TCE_TIMING1_SET)
32
R/W
0000_0000h
23.4.30/
1104
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1074
NXP Semiconductors

<!-- page 1075 -->

EPDC memory map (continued)
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
228_C308
EPDC Timing Control Engine Timing Register 1
(EPDC_TCE_TIMING1_CLR)
32
R/W
0000_0000h
23.4.30/
1104
228_C30C
EPDC Timing Control Engine Timing Register 1
(EPDC_TCE_TIMING1_TOG)
32
R/W
0000_0000h
23.4.30/
1104
228_C310
EPDC Timing Control Engine Timing Register 2
(EPDC_TCE_TIMING2)
32
R/W
0000_0001h
23.4.31/
1105
228_C314
EPDC Timing Control Engine Timing Register 2
(EPDC_TCE_TIMING2_SET)
32
R/W
0000_0001h
23.4.31/
1105
228_C318
EPDC Timing Control Engine Timing Register 2
(EPDC_TCE_TIMING2_CLR)
32
R/W
0000_0001h
23.4.31/
1105
228_C31C
EPDC Timing Control Engine Timing Register 2
(EPDC_TCE_TIMING2_TOG)
32
R/W
0000_0001h
23.4.31/
1105
228_C320
EPDC Timing Control Engine Timing Register 3
(EPDC_TCE_TIMING3)
32
R/W
0000_0001h
23.4.32/
1106
228_C324
EPDC Timing Control Engine Timing Register 3
(EPDC_TCE_TIMING3_SET)
32
R/W
0000_0001h
23.4.32/
1106
228_C328
EPDC Timing Control Engine Timing Register 3
(EPDC_TCE_TIMING3_CLR)
32
R/W
0000_0001h
23.4.32/
1106
228_C32C
EPDC Timing Control Engine Timing Register 3
(EPDC_TCE_TIMING3_TOG)
32
R/W
0000_0001h
23.4.32/
1106
228_C380
EPDC Pigeon Mode Control Register 0
(EPDC_PIGEON_CTRL0)
32
R/W
0000_0000h
23.4.33/
1106
228_C384
EPDC Pigeon Mode Control Register 0
(EPDC_PIGEON_CTRL0_SET)
32
R/W
0000_0000h
23.4.33/
1106
228_C388
EPDC Pigeon Mode Control Register 0
(EPDC_PIGEON_CTRL0_CLR)
32
R/W
0000_0000h
23.4.33/
1106
228_C38C
EPDC Pigeon Mode Control Register 0
(EPDC_PIGEON_CTRL0_TOG)
32
R/W
0000_0000h
23.4.33/
1106
228_C390
EPDC Pigeon Mode Control Register 1
(EPDC_PIGEON_CTRL1)
32
R/W
0000_0000h
23.4.34/
1107
228_C394
EPDC Pigeon Mode Control Register 1
(EPDC_PIGEON_CTRL1_SET)
32
R/W
0000_0000h
23.4.34/
1107
228_C398
EPDC Pigeon Mode Control Register 1
(EPDC_PIGEON_CTRL1_CLR)
32
R/W
0000_0000h
23.4.34/
1107
228_C39C
EPDC Pigeon Mode Control Register 1
(EPDC_PIGEON_CTRL1_TOG)
32
R/W
0000_0000h
23.4.34/
1107
228_C3C0
EPDC IRQ Mask Register for LUT 0~31
(EPDC_IRQ_MASK1)
32
R/W
0000_0000h
23.4.35/
1107
228_C3C4
EPDC IRQ Mask Register for LUT 0~31
(EPDC_IRQ_MASK1_SET)
32
R/W
0000_0000h
23.4.35/
1107
228_C3C8
EPDC IRQ Mask Register for LUT 0~31
(EPDC_IRQ_MASK1_CLR)
32
R/W
0000_0000h
23.4.35/
1107
228_C3CC
EPDC IRQ Mask Register for LUT 0~31
(EPDC_IRQ_MASK1_TOG)
32
R/W
0000_0000h
23.4.35/
1107
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1075

<!-- page 1076 -->

EPDC memory map (continued)
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
228_C3D0
EPDC IRQ Mask Register for LUT 32~63
(EPDC_IRQ_MASK2)
32
R/W
0000_0000h
23.4.36/
1108
228_C3D4
EPDC IRQ Mask Register for LUT 32~63
(EPDC_IRQ_MASK2_SET)
32
R/W
0000_0000h
23.4.36/
1108
228_C3D8
EPDC IRQ Mask Register for LUT 32~63
(EPDC_IRQ_MASK2_CLR)
32
R/W
0000_0000h
23.4.36/
1108
228_C3DC
EPDC IRQ Mask Register for LUT 32~63
(EPDC_IRQ_MASK2_TOG)
32
R/W
0000_0000h
23.4.36/
1108
228_C3E0
EPDC Interrupt Register for LUT 0~31 (EPDC_IRQ1)
32
R/W
0000_0000h
23.4.37/
1108
228_C3E4
EPDC Interrupt Register for LUT 0~31 (EPDC_IRQ1_SET)
32
R/W
0000_0000h
23.4.37/
1108
228_C3E8
EPDC Interrupt Register for LUT 0~31 (EPDC_IRQ1_CLR)
32
R/W
0000_0000h
23.4.37/
1108
228_C3EC
EPDC Interrupt Register for LUT 0~31 (EPDC_IRQ1_TOG)
32
R/W
0000_0000h
23.4.37/
1108
228_C3F0
EPDC Interrupt Registerr for LUT 32~63 (EPDC_IRQ2)
32
R/W
0000_0000h
23.4.38/
1108
228_C3F4
EPDC Interrupt Registerr for LUT 32~63 (EPDC_IRQ2_SET)
32
R/W
0000_0000h
23.4.38/
1108
228_C3F8
EPDC Interrupt Registerr for LUT 32~63
(EPDC_IRQ2_CLR)
32
R/W
0000_0000h
23.4.38/
1108
228_C3FC
EPDC Interrupt Registerr for LUT 32~63
(EPDC_IRQ2_TOG)
32
R/W
0000_0000h
23.4.38/
1108
228_C400
EPDC IRQ Mask Register (EPDC_IRQ_MASK)
32
R/W
0000_0000h
23.4.39/
1109
228_C404
EPDC IRQ Mask Register (EPDC_IRQ_MASK_SET)
32
R/W
0000_0000h
23.4.39/
1109
228_C408
EPDC IRQ Mask Register (EPDC_IRQ_MASK_CLR)
32
R/W
0000_0000h
23.4.39/
1109
228_C40C
EPDC IRQ Mask Register (EPDC_IRQ_MASK_TOG)
32
R/W
0000_0000h
23.4.39/
1109
228_C420
EPDC Interrupt Register (EPDC_IRQ)
32
R/W
0000_0000h
23.4.40/
1110
228_C424
EPDC Interrupt Register (EPDC_IRQ_SET)
32
R/W
0000_0000h
23.4.40/
1110
228_C428
EPDC Interrupt Register (EPDC_IRQ_CLR)
32
R/W
0000_0000h
23.4.40/
1110
228_C42C
EPDC Interrupt Register (EPDC_IRQ_TOG)
32
R/W
0000_0000h
23.4.40/
1110
228_C440
EPDC Status Register - LUTs (EPDC_STATUS_LUTS1)
32
R/W
0000_0000h
23.4.41/
1111
228_C444
EPDC Status Register - LUTs
(EPDC_STATUS_LUTS1_SET)
32
R/W
0000_0000h
23.4.41/
1111
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1076
NXP Semiconductors

<!-- page 1077 -->

EPDC memory map (continued)
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
228_C448
EPDC Status Register - LUTs
(EPDC_STATUS_LUTS1_CLR)
32
R/W
0000_0000h
23.4.41/
1111
228_C44C
EPDC Status Register - LUTs
(EPDC_STATUS_LUTS1_TOG)
32
R/W
0000_0000h
23.4.41/
1111
228_C450
EPDC Status Register - LUTs (EPDC_STATUS_LUTS2)
32
R/W
0000_0000h
23.4.42/
1112
228_C454
EPDC Status Register - LUTs
(EPDC_STATUS_LUTS2_SET)
32
R/W
0000_0000h
23.4.42/
1112
228_C458
EPDC Status Register - LUTs
(EPDC_STATUS_LUTS2_CLR)
32
R/W
0000_0000h
23.4.42/
1112
228_C45C
EPDC Status Register - LUTs
(EPDC_STATUS_LUTS2_TOG)
32
R/W
0000_0000h
23.4.42/
1112
228_C460
EPDC Status Register - Next Available LUT
(EPDC_STATUS_NEXTLUT)
32
R/W
0000_013Fh
23.4.43/
1112
228_C480
EPDC LUT Collision Status (EPDC_STATUS_COL1)
32
R/W
0000_0000h
23.4.44/
1114
228_C484
EPDC LUT Collision Status (EPDC_STATUS_COL1_SET)
32
R/W
0000_0000h
23.4.44/
1114
228_C488
EPDC LUT Collision Status (EPDC_STATUS_COL1_CLR)
32
R/W
0000_0000h
23.4.44/
1114
228_C48C
EPDC LUT Collision Status (EPDC_STATUS_COL1_TOG)
32
R/W
0000_0000h
23.4.44/
1114
228_C490
EPDC LUT Collision Status (EPDC_STATUS_COL2)
32
R/W
0000_0000h
23.4.45/
1114
228_C494
EPDC LUT Collision Status (EPDC_STATUS_COL2_SET)
32
R/W
0000_0000h
23.4.45/
1114
228_C498
EPDC LUT Collision Status (EPDC_STATUS_COL2_CLR)
32
R/W
0000_0000h
23.4.45/
1114
228_C49C
EPDC LUT Collision Status (EPDC_STATUS_COL2_TOG)
32
R/W
0000_0000h
23.4.45/
1114
228_C4A0
EPDC General Status Register (EPDC_STATUS)
32
R
0000_0008h
23.4.46/
1115
228_C4A4
EPDC General Status Register (EPDC_STATUS_SET)
32
R
0000_0008h
23.4.46/
1115
228_C4A8
EPDC General Status Register (EPDC_STATUS_CLR)
32
R
0000_0008h
23.4.46/
1115
228_C4AC
EPDC General Status Register (EPDC_STATUS_TOG)
32
R
0000_0008h
23.4.46/
1115
228_C4C0
EPDC Collision Region Co-ordinate
(EPDC_UPD_COL_CORD)
32
R/W
0000_0000h
23.4.47/
1116
228_C4E0
EPDC Collision Region Size (EPDC_UPD_COL_SIZE)
32
R/W
0000_0000h
23.4.48/
1117
228_C600
1-level Histogram Parameter Register.
(EPDC_HIST1_PARAM)
32
R/W
0000_0000h
23.4.49/
1117
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1077

<!-- page 1078 -->

EPDC memory map (continued)
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
228_C610
2-level Histogram Parameter Register.
(EPDC_HIST2_PARAM)
32
R/W
0000_0F00h
23.4.50/
1118
228_C620
4-level Histogram Parameter Register.
(EPDC_HIST4_PARAM)
32
R/W
0F0A_0500h
23.4.51/
1119
228_C630
8-level Histogram Parameter 0 Register.
(EPDC_HIST8_PARAM0)
32
R/W
0604_0200h
23.4.52/
1119
228_C640
8-level Histogram Parameter 1 Register.
(EPDC_HIST8_PARAM1)
32
R/W
0F0D_0B09h
23.4.53/
1120
228_C650
16-level Histogram Parameter 0 Register.
(EPDC_HIST16_PARAM0)
32
R/W
0302_0100h
23.4.54/
1121
228_C660
16-level Histogram Parameter Register.
(EPDC_HIST16_PARAM1)
32
R/W
0706_0504h
23.4.55/
1122
228_C670
16-level Histogram Parameter Register.
(EPDC_HIST16_PARAM2)
32
R/W
0B0A_0908h
23.4.56/
1122
228_C680
16-level Histogram Parameter Register.
(EPDC_HIST16_PARAM3)
32
R/W
0F0E_0D0Ch
23.4.57/
1123
228_C700
EPDC General Purpose I/O Debug register (EPDC_GPIO)
32
R/W
0000_0000h
23.4.58/
1124
228_C704
EPDC General Purpose I/O Debug register
(EPDC_GPIO_SET)
32
R/W
0000_0000h
23.4.58/
1124
228_C708
EPDC General Purpose I/O Debug register
(EPDC_GPIO_CLR)
32
R/W
0000_0000h
23.4.58/
1124
228_C70C
EPDC General Purpose I/O Debug register
(EPDC_GPIO_TOG)
32
R/W
0000_0000h
23.4.58/
1124
228_C7F0
EPDC Version Register (EPDC_VERSION)
32
R/W
0300_0000h
23.4.59/
1125
228_C800
Panel Interface Signal Generator Register 0_0
(EPDC_PIGEON_0_0)
32
R/W
0000_0F00h
23.4.60/
1126
228_C810
Panel Interface Signal Generator Register 0_1
(EPDC_PIGEON_0_1)
32
R/W
0000_0000h
23.4.61/
1127
228_C820
Panel Interface Signal Generator Register 0_1
(EPDC_PIGEON_0_2)
32
R/W
0000_0000h
23.4.62/
1127
228_C840
Panel Interface Signal Generator Register 1_0
(EPDC_PIGEON_1_0)
32
R/W
0000_0F00h
23.4.63/
1128
228_C850
Panel Interface Signal Generator Register 1_1
(EPDC_PIGEON_1_1)
32
R/W
0000_0000h
23.4.64/
1129
228_C860
Panel Interface Signal Generator Register 1_1
(EPDC_PIGEON_1_2)
32
R/W
0000_0000h
23.4.65/
1130
228_C880
Panel Interface Signal Generator Register 2_0
(EPDC_PIGEON_2_0)
32
R/W
0000_0F00h
23.4.66/
1130
228_C890
Panel Interface Signal Generator Register 2_1
(EPDC_PIGEON_2_1)
32
R/W
0000_0000h
23.4.67/
1132
228_C8A0
Panel Interface Signal Generator Register 2_1
(EPDC_PIGEON_2_2)
32
R/W
0000_0000h
23.4.68/
1132
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1078
NXP Semiconductors

<!-- page 1079 -->

EPDC memory map (continued)
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
228_C8C0
Panel Interface Signal Generator Register 3_0
(EPDC_PIGEON_3_0)
32
R/W
0000_0F00h
23.4.69/
1133
228_C8D0
Panel Interface Signal Generator Register 3_1
(EPDC_PIGEON_3_1)
32
R/W
0000_0000h
23.4.70/
1134
228_C8E0
Panel Interface Signal Generator Register 3_1
(EPDC_PIGEON_3_2)
32
R/W
0000_0000h
23.4.71/
1134
228_C900
Panel Interface Signal Generator Register 4_0
(EPDC_PIGEON_4_0)
32
R/W
0000_0F00h
23.4.72/
1135
228_C910
Panel Interface Signal Generator Register 4_1
(EPDC_PIGEON_4_1)
32
R/W
0000_0000h
23.4.73/
1136
228_C920
Panel Interface Signal Generator Register 4_1
(EPDC_PIGEON_4_2)
32
R/W
0000_0000h
23.4.74/
1137
228_C940
Panel Interface Signal Generator Register 5_0
(EPDC_PIGEON_5_0)
32
R/W
0000_0F00h
23.4.75/
1137
228_C950
Panel Interface Signal Generator Register 5_1
(EPDC_PIGEON_5_1)
32
R/W
0000_0000h
23.4.76/
1139
228_C960
Panel Interface Signal Generator Register 5_1
(EPDC_PIGEON_5_2)
32
R/W
0000_0000h
23.4.77/
1139
228_C980
Panel Interface Signal Generator Register 6_0
(EPDC_PIGEON_6_0)
32
R/W
0000_0F00h
23.4.78/
1140
228_C990
Panel Interface Signal Generator Register 6_1
(EPDC_PIGEON_6_1)
32
R/W
0000_0000h
23.4.79/
1141
228_C9A0
Panel Interface Signal Generator Register 6_1
(EPDC_PIGEON_6_2)
32
R/W
0000_0000h
23.4.80/
1141
228_C9C0
Panel Interface Signal Generator Register 7_0
(EPDC_PIGEON_7_0)
32
R/W
0000_0F00h
23.4.81/
1142
228_C9D0
Panel Interface Signal Generator Register 7_1
(EPDC_PIGEON_7_1)
32
R/W
0000_0000h
23.4.82/
1143
228_C9E0
Panel Interface Signal Generator Register 7_1
(EPDC_PIGEON_7_2)
32
R/W
0000_0000h
23.4.83/
1144
228_CA00
Panel Interface Signal Generator Register 8_0
(EPDC_PIGEON_8_0)
32
R/W
0000_0F00h
23.4.84/
1144
228_CA10
Panel Interface Signal Generator Register 8_1
(EPDC_PIGEON_8_1)
32
R/W
0000_0000h
23.4.85/
1146
228_CA20
Panel Interface Signal Generator Register 8_1
(EPDC_PIGEON_8_2)
32
R/W
0000_0000h
23.4.86/
1146
228_CA40
Panel Interface Signal Generator Register 9_0
(EPDC_PIGEON_9_0)
32
R/W
0000_0F00h
23.4.87/
1147
228_CA50
Panel Interface Signal Generator Register 9_1
(EPDC_PIGEON_9_1)
32
R/W
0000_0000h
23.4.88/
1148
228_CA60
Panel Interface Signal Generator Register 9_1
(EPDC_PIGEON_9_2)
32
R/W
0000_0000h
23.4.89/
1148
228_CA80
Panel Interface Signal Generator Register 10_0
(EPDC_PIGEON_10_0)
32
R/W
0000_0F00h
23.4.90/
1149
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1079

<!-- page 1080 -->

EPDC memory map (continued)
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
228_CA90
Panel Interface Signal Generator Register 10_1
(EPDC_PIGEON_10_1)
32
R/W
0000_0000h
23.4.91/
1150
228_CAA0
Panel Interface Signal Generator Register 10_1
(EPDC_PIGEON_10_2)
32
R/W
0000_0000h
23.4.92/
1151
228_CAC0
Panel Interface Signal Generator Register 11_0
(EPDC_PIGEON_11_0)
32
R/W
0000_0F00h
23.4.93/
1151
228_CAD0
Panel Interface Signal Generator Register 11_1
(EPDC_PIGEON_11_1)
32
R/W
0000_0000h
23.4.94/
1153
228_CAE0
Panel Interface Signal Generator Register 11_1
(EPDC_PIGEON_11_2)
32
R/W
0000_0000h
23.4.95/
1153
228_CB00
Panel Interface Signal Generator Register 12_0
(EPDC_PIGEON_12_0)
32
R/W
0000_0F00h
23.4.96/
1154
228_CB10
Panel Interface Signal Generator Register 12_1
(EPDC_PIGEON_12_1)
32
R/W
0000_0000h
23.4.97/
1155
228_CB20
Panel Interface Signal Generator Register 12_1
(EPDC_PIGEON_12_2)
32
R/W
0000_0000h
23.4.98/
1155
228_CB40
Panel Interface Signal Generator Register 13_0
(EPDC_PIGEON_13_0)
32
R/W
0000_0F00h
23.4.99/
1156
228_CB50
Panel Interface Signal Generator Register 13_1
(EPDC_PIGEON_13_1)
32
R/W
0000_0000h
23.4.100/
1157
228_CB60
Panel Interface Signal Generator Register 13_1
(EPDC_PIGEON_13_2)
32
R/W
0000_0000h
23.4.101/
1158
228_CB80
Panel Interface Signal Generator Register 14_0
(EPDC_PIGEON_14_0)
32
R/W
0000_0F00h
23.4.102/
1158
228_CB90
Panel Interface Signal Generator Register 14_1
(EPDC_PIGEON_14_1)
32
R/W
0000_0000h
23.4.103/
1160
228_CBA0
Panel Interface Signal Generator Register 14_1
(EPDC_PIGEON_14_2)
32
R/W
0000_0000h
23.4.104/
1160
228_CBC0
Panel Interface Signal Generator Register 15_0
(EPDC_PIGEON_15_0)
32
R/W
0000_0F00h
23.4.105/
1161
228_CBD0
Panel Interface Signal Generator Register 15_1
(EPDC_PIGEON_15_1)
32
R/W
0000_0000h
23.4.106/
1162
228_CBE0
Panel Interface Signal Generator Register 15_1
(EPDC_PIGEON_15_2)
32
R/W
0000_0000h
23.4.107/
1162
228_CC00
Panel Interface Signal Generator Register 16_0
(EPDC_PIGEON_16_0)
32
R/W
0000_0F00h
23.4.108/
1163
228_CC10
Panel Interface Signal Generator Register 16_1
(EPDC_PIGEON_16_1)
32
R/W
0000_0000h
23.4.109/
1164
228_CC20
Panel Interface Signal Generator Register 16_1
(EPDC_PIGEON_16_2)
32
R/W
0000_0000h
23.4.110/
1165
23.4.1
EPDC Control Register (EPDC_CTRLn)
EPDC Main control register
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1080
NXP Semiconductors

<!-- page 1081 -->

This register controls various high-level functions of the EPDC
EXAMPLE
/* Reset */
    __raw_writel(EPDC_CTRL_SFTRST, EPDC_CTRL_SET);
    while (!(__raw_readl(EPDC_CTRL) & EPDC_CTRL_CLKGATE))
        ;
    __raw_writel(EPDC_CTRL_SFTRST, EPDC_CTRL_CLEAR);
    /* Enable clock gating (clear to enable) */
    __raw_writel(EPDC_CTRL_CLKGATE, EPDC_CTRL_CLEAR);
    while (__raw_readl(EPDC_CTRL) & (EPDC_CTRL_SFTRST | EPDC_CTRL_CLKGATE))
        ;
    /* EPDC_CTRL */
    reg_val = __raw_readl(EPDC_CTRL);
    reg_val &= ~EPDC_CTRL_UPD_DATA_SWIZZLE_MASK;
    reg_val |= EPDC_CTRL_UPD_DATA_SWIZZLE_NO_SWAP;
    reg_val &= ~EPDC_CTRL_LUT_DATA_SWIZZLE_MASK;
    reg_val |= EPDC_CTRL_LUT_DATA_SWIZZLE_NO_SWAP;
    __raw_writel(reg_val, EPDC_CTRL_SET);
Address: 228_C000h base + 0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
Reserved
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
Reserved
UPD_DATA_
SWIZZLE
LUT_DATA_
SWIZZLE
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
EPDC_CTRLn field descriptions
Field
Description
31
SFTRST
Set this bit to zero to enable normal EPDC operation. Set this bit to one (default) to disable clocking with
the EPDC and hold it in its reset (lowest power) state. This bit can be turned on and then off to reset the
EPDC block to its default state.
30
CLKGATE
This bit must be set to zero for normal operation. When set to one it gates off the clocks to the block.
29–8
-
This field is reserved.
Reserved.
7–6
UPD_DATA_
SWIZZLE
Specifies how to swap the bytes for the UPD data before the WB construction. Plesae note this swizzle
operate right after data fetch from bus, no matter it's aligned access or not. Supported configurations:
0x0
NO_SWAP — No byte swapping.(Little endian)
0x1
ALL_BYTES_SWAP — Swizzle all bytes, swap bytes 0,3 and 1,2 (aka Big Endian).
0x2
HWD_SWAP — Swap half-words.
0x3
HWD_BYTE_SWAP — Swap bytes within each half-word.
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1081

<!-- page 1082 -->

EPDC_CTRLn field descriptions (continued)
Field
Description
5–4
LUT_DATA_
SWIZZLE
Specifies how to swap the bytes for the LUT data before store to LUTRAM. Supported configurations:
0x0
NO_SWAP — No byte swapping.(Little endian)
0x1
ALL_BYTES_SWAP — Swizzle all bytes, swap bytes 0,3 and 1,2 (aka Big Endian).
0x2
HWD_SWAP — Swap half-words.
0x3
HWD_BYTE_SWAP — Swap bytes within each half-word.
-
This field is reserved.
Reserved.
23.4.2
EPDC Working Buffer Address for TCE
(EPDC_WB_ADDR_TCE)
EPDC Working Buffer Address for TCE
Address: 228_C000h base + 10h offset = 228_C010h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
EPDC_WB_ADDR_TCE field descriptions
Field
Description
ADDR
Address for EPDC working buffer. This address must be a aligned to a 64-bit double-word boundary.
23.4.3
EPDC Waveform Address Pointer (EPDC_WVADDR)
EPDC Waveform Address Pointer
EXAMPLE
/* Reset */
    __raw_writel(EPDC_CTRL_SFTRST, EPDC_CTRL_SET);
    while (!(__raw_readl(EPDC_CTRL) & EPDC_CTRL_CLKGATE))
        ;
    __raw_writel(EPDC_CTRL_SFTRST, EPDC_CTRL_CLEAR);
    /* Enable clock gating (clear to enable) */
    __raw_writel(EPDC_CTRL_CLKGATE, EPDC_CTRL_CLEAR);
    while (__raw_readl(EPDC_CTRL) & (EPDC_CTRL_SFTRST | EPDC_CTRL_CLKGATE))
        ;
    /* EPDC_CTRL */
    reg_val = __raw_readl(EPDC_CTRL);
    reg_val &= ~EPDC_CTRL_UPD_DATA_SWIZZLE_MASK;
    reg_val |= EPDC_CTRL_UPD_DATA_SWIZZLE_NO_SWAP;
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1082
NXP Semiconductors

<!-- page 1083 -->

    reg_val &= ~EPDC_CTRL_LUT_DATA_SWIZZLE_MASK;
    reg_val |= EPDC_CTRL_LUT_DATA_SWIZZLE_NO_SWAP;
    __raw_writel(reg_val, EPDC_CTRL_SET);
Address: 228_C000h base + 20h offset = 228_C020h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
EPDC_WVADDR field descriptions
Field
Description
ADDR
Start address of waveform tables. This address needs to be aligned to a 64-bit word boundary.
23.4.4
EPDC Working Buffer Address (EPDC_WB_ADDR)
EPDC Working Buffer Address
This register points to the address of current working buffer.
Address: 228_C000h base + 30h offset = 228_C030h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
EPDC_WB_ADDR field descriptions
Field
Description
ADDR
Address for EPDC working buffer. This address must be a aligned to a 64-bit double-word boundary.
23.4.5
EPDC Screen Resolution (EPDC_RES)
EPDC Screen Resolution.
This register defines the horizontal and vertical resolution of the target display panel
Address: 228_C000h base + 40h offset = 228_C040h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
VERTICAL
Reserved
HORIZONTAL
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
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1083

<!-- page 1084 -->

EPDC_RES field descriptions
Field
Description
31–29
-
This field is reserved.
Reserved.
28–16
VERTICAL
Vertical Resoltion (in pixels)
15–13
-
This field is reserved.
Reserved.
HORIZONTAL
Horizontal Resolution (in pixels)
23.4.6
EPDC Format Control Register (EPDC_FORMATn)
EPDC Pixel format control register. Defines formats for buffer and TFT pixels.
This register controls various functions throughout the digital portion of the chip.
EXAMPLE
/* EPDC_FORMAT - 2bit TFT and 4bit Buf pixel format */
    reg_val = EPDC_FORMAT_TFT_PIXEL_FORMAT_2BIT
        | EPDC_FORMAT_BUF_PIXEL_FORMAT_P4N
        | ((0x0 << EPDC_FORMAT_DEFAULT_TFT_PIXEL_OFFSET) &
           EPDC_FORMAT_DEFAULT_TFT_PIXEL_MASK);
    __raw_writel(reg_val, EPDC_FORMAT);
Address: 228_C000h base + 50h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
BUF_PIXEL_SCALE
DEFAULT_TFT_PIXEL
W
Reset
0
0
0
0
0
0
0
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
WB_ADDR_NO_COPY
WB_TYPE
WB_COMPRESS
BUF_PIXEL_
FORMAT
Reserved
TFT_PIXEL_FORMAT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1084
NXP Semiconductors

<!-- page 1085 -->

EPDC_FORMATn field descriptions
Field
Description
31–25
-
This field is reserved.
Reserved.
24
BUF_PIXEL_
SCALE
Selects method of conversion from 8-bit input
0x0
TRUNCATE — Use Truncate method (LSB)
0x1
ROUND — Use rounding method (with saturation)
23–16
DEFAULT_TFT_
PIXEL
Default TFT pixel value. This value is used as the source-driver voltage value (TFT-pixel) for either partial-
updates where a pixel has not changed or for any part of the screen which is not being updated during
active frame scans.
15
-
This field is reserved.
Reserved.
14
WB_ADDR_NO_
COPY
1 means do not automatically copy WB_ADDR to WB_ADDR_TCE before starting every frame
13–12
WB_TYPE
00
WB_INTERNAL — internal Working Buffer written by EPDC itself
01
WB_WAVEFORM — working buffer is actually holding waveform
10
WB_EXTERNAL16 — 16bit working buffer written by PXP or CPU
11
WB_EXTERNAL32 — 32bit working buffer written by PXP or CPU
11
WB_COMPRESS
whether the working buffer is compressed, only avilable on WB_FORMAT=EXTERNAL16/32 mode
10–8
BUF_PIXEL_
FORMAT
this field is deprecated in EPDCv3, replaced by WB_FIELDx where we can specify width for each field
EPDC Input Buffer Pixel format. All update buffers are expected to have 8-bit grayscale pixels. This
register defines which MSB's of those pixels are used. It must be noted that this format must match the
waveform (e.g. P4N is not compatible with 3-bit waveforms)
0x2
P2N — 2-bit pixel
0x3
P3N — 3-bit pixel
0x4
P4N — 4-bit pixel
0x5
P5N — 5-bit pixel
7–2
-
This field is reserved.
Reserved.
TFT_PIXEL_
FORMAT
EPDC TFT Pixel Format. This defines how many bits of the SDDO bus are required per pixel. This field
must be consistent with the waveform and panel architecture.
0x0
2B — 2-bit
0x1
2BV — 2-bit and VCOM
0x2
4B — 4-bit
0x3
4BV — 4-bit and VCOM
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1085

<!-- page 1086 -->

23.4.7
Working Buffer Field Setting (EPDC_WB_FIELD0)
specify the pixel fields mapping from working buffer to lut index : WB[FROM
+LEN:FROM] =>LUT [TO+LEN:TO]
Address: 228_C000h base + 60h offset = 228_C060h
Bit
31
30
29
28
27
26
25
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
FIXED
Reserved
USE_FIXED
W
Reset
0
0
0
0
0
0
0
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
USAGE
FROM
TO
LEN
W
Reset
1
0
0
0
1
0
1
0
1
0
1
0
0
1
0
1
EPDC_WB_FIELD0 field descriptions
Field
Description
31–24
FIXED
used to either force field into a fixed value, or compare to wb field to mask off the pixel
23–18
-
This field is reserved.
Reserved
17–16
USE_FIXED
usage of the FIXED value
00
NO_FIXED — not using FIXED field
01
USE_FIXED — set this field to a FIXED value which specified by FIXED[31:24]
10
NE_FIXED — mask off this pixel if this field is non equal to FIXED[31:24]
11
EQ_FIXED — mask off this pixel if this field is equal to FIXED[31:24]
15–13
USAGE
000
NOT_USED — NOT USED
011
PARTIAL — PARTIAL (won't contribute to lut lookup index)
100
LUT — LUT
101
CP — CP
110
NP — NP
111
PTS — PTS
12–8
FROM
Source Field's LSB
7–4
TO
Target Field's LSB
LEN
Field length minus 1 (0x0 means length=1, 0xf means length=16)
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1086
NXP Semiconductors

<!-- page 1087 -->

23.4.8
Working Buffer Field Setting (EPDC_WB_FIELD1)
specify the pixel fields mapping from working buffer to lut index : WB[FROM
+LEN:FROM] =>LUT [TO+LEN:TO]
Address: 228_C000h base + 70h offset = 228_C070h
Bit
31
30
29
28
27
26
25
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
FIXED
Reserved
USE_FIXED
W
Reset
0
0
0
0
0
0
0
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
USAGE
FROM
TO
LEN
W
Reset
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
1
1
EPDC_WB_FIELD1 field descriptions
Field
Description
31–24
FIXED
used to either force field into a fixed value, or compare to wb field to mask off the pixel
23–18
-
This field is reserved.
Reserved
17–16
USE_FIXED
usage of the FIXED value
00
NO_FIXED — not using FIXED field
01
USE_FIXED — set this field to a FIXED value which specified by FIXED[31:24]
10
NE_FIXED — mask off this pixel if this field is non equal to FIXED[31:24]
11
EQ_FIXED — mask off this pixel if this field is equal to FIXED[31:24]
15–13
USAGE
000
NOT_USED — NOT USED
011
PARTIAL — PARTIAL
100
LUT — LUT
101
CP — CP
110
NP — NP
111
PTS — PTS
12–8
FROM
Source Field's LSB
7–4
TO
Target Field's LSB
LEN
Field length minus 1 (0x0 means length=1, 0xf means length=16)
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1087

<!-- page 1088 -->

23.4.9
Working Buffer Field Setting (EPDC_WB_FIELD2)
specify the pixel fields mapping from working buffer to lut index : WB[FROM
+LEN:FROM] =>LUT [TO+LEN:TO]
Address: 228_C000h base + 80h offset = 228_C080h
Bit
31
30
29
28
27
26
25
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
FIXED
Reserved
USE_FIXED
W
Reset
0
0
0
0
0
0
0
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
USAGE
FROM
TO
LEN
W
Reset
1
1
0
0
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
1
1
EPDC_WB_FIELD2 field descriptions
Field
Description
31–24
FIXED
used to either force field into a fixed value, or compare to wb field to mask off the pixel
23–18
-
This field is reserved.
Reserved
17–16
USE_FIXED
usage of the FIXED value
00
NO_FIXED — not using FIXED field
01
USE_FIXED — set this field to a FIXED value which specified by FIXED[31:24]
10
NE_FIXED — mask off this pixel if this field is non equal to FIXED[31:24]
11
EQ_FIXED — mask off this pixel if this field is equal to FIXED[31:24]
15–13
USAGE
000
NOT_USED — NOT USED
011
PARTIAL — PARTIAL
100
LUT — LUT
101
CP — CP
110
NP — NP
111
PTS — PTS
12–8
FROM
Source Field's LSB
7–4
TO
Target Field's LSB
LEN
Field length minus 1 (0x0 means length=1, 0xf means length=16)
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1088
NXP Semiconductors

<!-- page 1089 -->

23.4.10
Working Buffer Field Setting (EPDC_WB_FIELD3)
specify the pixel fields mapping from working buffer to lut index : WB[FROM
+LEN:FROM] =>LUT [TO+LEN:TO]
Address: 228_C000h base + 90h offset = 228_C090h
Bit
31
30
29
28
27
26
25
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
FIXED
Reserved
USE_FIXED
W
Reset
0
0
0
0
0
0
0
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
USAGE
FROM
TO
LEN
W
Reset
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
0
0
EPDC_WB_FIELD3 field descriptions
Field
Description
31–24
FIXED
used to either force field into a fixed value, or compare to wb field to mask off the pixel
23–18
-
This field is reserved.
Reserved
17–16
USE_FIXED
usage of the FIXED value
00
NO_FIXED — not using FIXED field
01
USE_FIXED — set this field to a FIXED value which specified by FIXED[31:24]
10
NE_FIXED — mask off this pixel if this field is non equal to FIXED[31:24]
11
EQ_FIXED — mask off this pixel if this field is equal to FIXED[31:24]
15–13
USAGE
000
NOT_USED — NOT USED
011
PARTIAL — PARTIAL
100
LUT — LUT
101
CP — CP
110
NP — NP
111
PTS — PTS
12–8
FROM
Source Field's LSB
7–4
TO
Target Field's LSB
LEN
Field length minus 1 (0x0 means length=1, 0xf means length=16)
23.4.11
EPDC FIFO control register (EPDC_FIFOCTRLn)
Allows for programmability of pixel FIFO watermarks used in conjunction with system
arbitration hardware
This register houses FIFO control bits
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1089

<!-- page 1090 -->

EXAMPLE
/* EPDC_FIFOCTRL (disabled) */
    reg_val =
        ((100 << EPDC_FIFOCTRL_FIFO_INIT_LEVEL_OFFSET) &
         EPDC_FIFOCTRL_FIFO_INIT_LEVEL_MASK)
        | ((200 << EPDC_FIFOCTRL_FIFO_H_LEVEL_OFFSET) &
           EPDC_FIFOCTRL_FIFO_H_LEVEL_MASK)
        | ((100 << EPDC_FIFOCTRL_FIFO_L_LEVEL_OFFSET) &
           EPDC_FIFOCTRL_FIFO_L_LEVEL_MASK);
    __raw_writel(reg_val, EPDC_FIFOCTRL);
Address: 228_C000h base + A0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
ENABLE_
PRIORITY
Reserved
FIFO_INIT_LEVEL
W
Reset
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
FIFO_H_LEVEL
FIFO_L_LEVEL
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
EPDC_FIFOCTRLn field descriptions
Field
Description
31
ENABLE_
PRIORITY
Enable watermark-based priority elevation mechanism. 1=Enabled, 0=Disabled. (Only applies to
FIFO_H_LEVEL and FIFO_L_LEVEL)
30–24
-
This field is reserved.
Reserved.
23–16
FIFO_INIT_
LEVEL
This register sets the watermark for the pixel-fifo.
15–8
FIFO_H_LEVEL
Upper level value of FIFO watermark. Must be greater than FIFO_L_LEVEL. When the pixel FIFO reaches
this level or above, the priority elevation request is negated
FIFO_L_LEVEL
Lower level value of FIFO watermark. When the pixel FIFO reaches this level or below, the priority
elevation request is asserted.
23.4.12
EPDC Update Region Address (EPDC_UPD_ADDR)
EPDC Update Region Address
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1090
NXP Semiconductors

<!-- page 1091 -->

The address alignment depends on whether the update region stride register
(EPDC_UPD_STRIDE) is set or not.
If EPDC_UPD_STRIDE is zero, the update region address must start and end on the 8-
byte aligned addresses.
If EPDC_UPD_STRIDE is non-zero, the update region address can start and/or end on
any byte addressing. But aligned address still recomended be get best bus performance.
EXAMPLE1
/* no update stride case */
    u32 stride = 0;
    u32 addr = 0x100;    /* 8-byte aligned */
    __raw_writel(stride, EPDC_UPD_STRIDE);
    __raw_writel(addr, EPDC_UPD_ADDR);
EXAMPLE2
/* update stride = 345 */
    u32 stride = 345;
    u32 addr = 0x123;    /* 8-byte unaligned is OK */
    __raw_writel(stride, EPDC_UPD_STRIDE);
    __raw_writel(addr, EPDC_UPD_ADDR);
Address: 228_C000h base + 100h offset = 228_C100h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
EPDC_UPD_ADDR field descriptions
Field
Description
ADDR
Address for incoming region update. This address points to update region which will be processed into the
working buffer.
23.4.13
EPDC Update Region Stride (EPDC_UPD_STRIDE)
EPDC Update Region Stride
When UPD_STRIDE==0 (stride feature disabled), UPD buffer line must start from 64-bit
boundary and end on 64-bit boundary(padding if not). When UPD_STRIDE!=0 (stride
feature enabled), UPD buffer line can start or end on any byte address, UPD_WIDTH
should be set to real line bytes count as normal, while UPD_STRIDE set to byte distance
between two lines' start.
EXAMPLE
see details on stride feature introduction
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1091

<!-- page 1092 -->

Address: 228_C000h base + 110h offset = 228_C110h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
STRIDE
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
EPDC_UPD_STRIDE field descriptions
Field
Description
STRIDE
line stride for incoming region update
23.4.14
EPDC Update Command Co-ordinate (EPDC_UPD_CORD)
EPDC Update Command Co-ordinate
This register is used for setting up the coordinate of a new update region.
Address: 228_C000h base + 120h offset = 228_C120h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
YCORD
Reserved
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
EPDC_UPD_CORD field descriptions
Field
Description
31–29
-
This field is reserved.
Reserved.
28–16
YCORD
Y co-ordinate for incoming region update
15–13
-
This field is reserved.
Reserved.
XCORD
X co-ordinate for incoming region update
23.4.15
EPDC Update Command Size (EPDC_UPD_SIZE)
EPDC Update Command Size
This register sets up the size of an update region.
Address: 228_C000h base + 140h offset = 228_C140h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
HEIGHT
Reserved
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
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1092
NXP Semiconductors

<!-- page 1093 -->

EPDC_UPD_SIZE field descriptions
Field
Description
31–29
-
This field is reserved.
Reserved.
28–16
HEIGHT
Height (in pixels)
15–13
-
This field is reserved.
Reserved.
WIDTH
Width (in pixels)
23.4.16
EPDC Update Command Control (EPDC_UPD_CTRLn)
EPDC Update Command Control.
Writing to this registers triggers and update request operation.
Address: 228_C000h base + 160h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
USE_FIXED
Reserved
LUT_SEL
W
Reset
0
0
0
0
0
0
0
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
WAVEFORM_MODE
Reserved
STANDBY
NO_LUT_
CANCEL
PAUSE
AUTOWV
DRY_
RUN
UPDATE_MODE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
EPDC_UPD_CTRLn field descriptions
Field
Description
31
USE_FIXED
Use fixed pixel values (requires programming of EPDC_UPD_FIXED)
30–22
-
This field is reserved.
Reserved.
21–16
LUT_SEL
LUT select 0-63
15–8
WAVEFORM_
MODE
Waveform Mode 0-255
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1093

<!-- page 1094 -->

EPDC_UPD_CTRLn field descriptions (continued)
Field
Description
7–6
-
This field is reserved.
Reserved.
5
STANDBY
4
NO_LUT_
CANCEL
EPDC will cancel LUT loading for void update (no real update needed because of partial or collision), set
this bit to 1 to disable this feature
3
PAUSE
0x0
AUTO — epdc will analyze update buffer, report histogram, then update waveform mode using the
programmed mode mapping in AUTOWV_LUT and start LUT loading
0x1
MANUAL — epdc will analyze update buffer, report histogram, then pause and waiting software to
write again with selected waveform mode to start lut loading
2
AUTOWV
enable automatical waveform mode selection
1
DRY_RUN
Enable Dry Run mode(set to 1). WB won't be updated in this mode, and lut_sel will be ignored, so actually
you don't need to wait for LUT available to use this feature
0
UPDATE_MODE
Update Mode
0x0
PARTIAL — Partial Update : only process changed pixels in region
0x1
FULL — Full Update : process all pixels in region
23.4.17
EPDC Update Fixed Pixel Control (EPDC_UPD_FIXEDn)
EPDC Update Control register for fixed-pixel updates (enabled via
EPDC_UPD_CTRL[USE_FIXED])
Address: 228_C000h base + 180h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
FIXNP_EN
FIXCP_EN
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
FIXNP
FIXCP
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1094
NXP Semiconductors

<!-- page 1095 -->

EPDC_UPD_FIXEDn field descriptions
Field
Description
31
FIXNP_EN
If set to 1, current updated region has the NP value defined by FIXNP
30
FIXCP_EN
If set to 1, current updated region has the CP value defined by FIXCP
29–16
-
This field is reserved.
Reserved.
15–8
FIXNP
NP value if fixenp_en is set to 1. Data in Y8 format.
FIXCP
CP value if fixecp_en is set to 1. Data in Y8 format.
23.4.18
EPDC Temperature Register (EPDC_TEMP)
EPDC Temperature Compensation Register
Address: 228_C000h base + 1A0h offset = 228_C1A0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
TEMPERATURE
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
EPDC_TEMP field descriptions
Field
Description
TEMPERATURE Temperature Value. This value is simply an index (not a temperature value). The index is used by the
EPDC to access the correct temperature compensated waveform.
23.4.19
Waveform Mode Lookup Table Control Register.
(EPDC_AUTOWV_LUT)
This register is used to access the waveform mode lookup table.
DATA -> AUTOWV_LUT[ADDR] : Writing this reg with 'ADDR' and 'DATA' info will
get 'DATA' written to AUTOWV_LUT mem indexed with 'ADDR'
Address: 228_C000h base + 1C0h offset = 228_C1C0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
Reserved
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
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1095

<!-- page 1096 -->

EPDC_AUTOWV_LUT field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved, always set to zero.
23–16
DATA
DATA
15–3
-
This field is reserved.
Reserved, always set to zero.
ADDR
ADDR
23.4.20
EPDC LUT Standby Register for LUT 31~0
(EPDC_LUT_STANDBY1n)
Address: 228_C000h base + 1E0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
LUTN
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
EPDC_LUT_STANDBY1n field descriptions
Field
Description
LUTN
LUT 0~31 standby control
23.4.21
EPDC LUT Standby Registerr for LUT 63~32
(EPDC_LUT_STANDBY2n)
Address: 228_C000h base + 1F0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
LUTN
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
EPDC_LUT_STANDBY2n field descriptions
Field
Description
LUTN
LUT 32~64 Standby Control
23.4.22
EPDC Timing Control Engine Control Register
(EPDC_TCE_CTRLn)
TCE general control register
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1096
NXP Semiconductors

<!-- page 1097 -->

This register houses Horizontal scan timing. Note that line data length is derived from
EPDC_RES.
Address: 228_C000h base + 200h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
VSCAN_HOLDOFF
W
Reset
0
0
0
0
0
0
0
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
VCOM_VAL
VCOM_MODE
DDR_MODE
LVDS_MODE_CE
LVDS_MODE
SCAN_DIR_1
SCAN_DIR_0
Reserved
SDDO_WIDTH
PIXELS_PER_SDCLK
W
Reset
0
0
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
EPDC_TCE_CTRLn field descriptions
Field
Description
31–25
-
This field is reserved.
Reserved.
24–16
VSCAN_
HOLDOFF
This period (expressed in vertical lines), sets the portion of the vertical blanking available for new LUTs to
be activated. The remainder of the blanking period is reserved for pre-filling the TCE pixel FIFOs.
Increasing this value allows for multiple smaller updates to be intercepted by the current frame scan. This
number should not exceed FRAME_END+FRAME_SYNC+FRAME_BEGIN. Increasing this value can
improve the ability for any given update to intercept the next available frame-scan. Excessive values can
result in TCE FIFO under-runs.
15–12
-
This field is reserved.
Reserved.
11–10
VCOM_VAL
When VCOM_MODE = MANUAL, this value is used to manually set the VCOM value for the VCOM[1:0]
pins
9
VCOM_MODE
This field determines the method used to drive the VCOM signal.
0x0
MANUAL — VCOM Value is set manually using VCOM_VAL field
0x1
AUTO — VCOM Value is used from waveform
8
DDR_MODE
If set, SDDO data is driven on both positive and negative edges of SDCLK. Note that this mode is not
supported when SDDO_BUS_FORMAT=16BIT and LVDS is not used. This must always be set when
LVDS_MODE is set.
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1097

<!-- page 1098 -->

EPDC_TCE_CTRLn field descriptions (continued)
Field
Description
7
LVDS_MODE_
CE
If set (together with LVDS_MODE=1), SDCE[9:5] shall be driven as the differential inverse of SDCE[4:0].
In this mode the EPDC only supports 5 CE lines.
6
LVDS_MODE
If set, the upper 8-bit of the SDDO bus are used for LVDS differential signalling. Note that this can only be
used when SDDO_BUS_FORMAT is set to 16BIT, i.e. LVDS signaling is not supported with an 8-bit
SDDO interface. Note that for LVDS_MODE, DDR_MODE must also be set.
5
SCAN_DIR_1
Determines scan direction for each half of the TFT panel
0x1
UP — Scan this region from bottom to top
0x0
DOWN — Scan this region from top to bottom
4
SCAN_DIR_0
Determines scan direction for each half of the TFT panel
0x1
UP — Scan this region from bottom to top
0x0
DOWN — Scan this region from top to bottom
3
-
This field is reserved.
Reserved
2
SDDO_WIDTH
Selects either 8 or 16 bit SDDO bus format
0x0
8BIT — Connect to 8-bit source driver
0x1
16BIT — Connct to 16-bit source driver
PIXELS_PER_
SDCLK
Number of TFT pixels per SDCLK period. Note that this value forms the division of the PIXLK to generate
the SDCLK such that SDCLK = PIXCLK/PIXELS_PER_SDCLK.
0x0
RESERVED — Reserved
0x1
TWO — Two TFT-pixels per SDCLK
0x2
FOUR — Four TFT-pixels per SDCLK
0x3
EIGHT — Eight TFT-pixels per SDCLK
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1098
NXP Semiconductors

<!-- page 1099 -->

23.4.23
EPDC Timing Control Engine Source-Driver Config Register
(EPDC_TCE_SDCFGn)
Source-driver configuration register
Address: 228_C000h base + 220h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
SDCLK_HOLD
SDSHR
NUM_CE
W
Reset
0
0
0
0
0
0
0
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
SDDO_
REFORMAT
SDDO_
INVERT
PIXELS_PER_CE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
EPDC_TCE_SDCFGn field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved.
21
SDCLK_HOLD
Setting this bit to 1 holds the SDCLK low during LINE_BEGIN
20
SDSHR
Value for source-driver shift direction output port
19–16
NUM_CE
Number of source driver IC chip-enables. Must be 1-10
15–14
SDDO_
REFORMAT
This register defines the various re-formatting options to enable more flexibility in the source-driver
interface:
0x0
STANDARD — No change.
0x1
FLIP_PIXELS — Reverses the order of the pixels on SDDO. This register setting is sensitive to the
TFT pixel width (TFT_PIXEL_FORMAT), e.g. for TFT_PIXEL_FORMAT=2B on an 8-bit bus
P3,P2,P1,P0 becomes P0,P1,P2,P3, whereas with TFT_PIXEL_FORMAT=4B, on an 8-bit bus,
P1,P0 becomes P0,P1
13
SDDO_INVERT
Setting this bit to 1 reverses the polarity of each SDDO bit so 0xAAAA in 16-bit mode for example
becomes 0x5555. This setting can be made in addition to the SDDO_REFORMAT register setting.
PIXELS_PER_
CE
Number of pixels (outputs) per source-driver IC. Please note that EPDC_RES[HORIZONTAL] must be an
integer multiple of PINS_PER_CE.
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1099

<!-- page 1100 -->

23.4.24
EPDC Timing Control Engine Gate-Driver Config Register
(EPDC_TCE_GDCFGn)
This register houses gate-driver configuration.
Address: 228_C000h base + 240h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
PERIOD_VSCAN
W
Reset
0
0
0
0
0
0
0
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
GDRL
Reserved
GDOE_MODE
GDSP_MODE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
EPDC_TCE_GDCFGn field descriptions
Field
Description
31–16
PERIOD_VSCAN
when vscan state is splited, this reg defines the counter period
15–5
-
This field is reserved.
Reserved.
4
GDRL
Value for gate-driver right/left shift output port
3–2
-
This field is reserved.
Reserved.
1
GDOE_MODE
Selects method for driving GDOE signal. When set to 0, GDOE is driven at all times during the frame-scan
except FRAME_SYNC. When set to 1, GDOE is driven as a delayed version of GDCLK delayed by
EPDC_TCE_TIMING3[GDOE_OFFSET].
0
GDSP_MODE
Selects method for driving GDSP pulse. When set to 0, GDSP is is always fixed to have a pulse width of
one line-time. When set to 1, GDSP has a pulse-width determined by the FRAME_SYNC setting. Note
that GDSP_MODE=1 is not compatible with the GDSP_OFFSET function
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1100
NXP Semiconductors

<!-- page 1101 -->

23.4.25
EPDC Timing Control Engine Horizontal Timing Register 1
(EPDC_TCE_HSCAN1n)
Horizontal scan timing registers. Note that all timing values are expressed in terms of the
EPDC's internal PIXCLK, which depending on the PIXELS_PER_SDCLK register
setting is either 2:1 or 4:1
This register houses Horizontal scan timing. Note that line data length is derived from
EPDC_RES.
Address: 228_C000h base + 260h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
LINE_SYNC_WIDTH
Reserved
LINE_SYNC
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
EPDC_TCE_HSCAN1n field descriptions
Field
Description
31–28
-
This field is reserved.
Reserved.
27–16
LINE_SYNC_
WIDTH
Number of PIXCLK cycles for the SDLE active time. Note that this value cannot be larger than
LINE_SYNC and must be greater than 0. Typically it is recommended to set this value to be the same as
LINE_SYNC
15–12
-
This field is reserved.
Reserved.
LINE_SYNC
Number of PIXCLK cycles for line sync duration. Note that this value encompasses the
LINE_SYNC_WIDTH duration. This value must be programmed to a multiple of SDCLK cycles
23.4.26
EPDC Timing Control Engine Horizontal Timing Register 2
(EPDC_TCE_HSCAN2n)
Horizontal scan timing registers. Note that all timing values are expressed in terms of the
EPDC's internal PIXCLK, which depending on the PIXELS_PER_SDCLK register
setting is either 2:1 or 4:1
This register houses Horizontal scan timing. Note that line data length is derived from
EPDC_RES.
Address: 228_C000h base + 280h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
LINE_END
Reserved
LINE_BEGIN
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
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1101

<!-- page 1102 -->

EPDC_TCE_HSCAN2n field descriptions
Field
Description
31–28
-
This field is reserved.
Reserved.
27–16
LINE_END
Number of PIXCLK cycles for line end duration. This defines the duration from the de-assertion of SDCE
and assertion of the next SDLE.
15–12
-
This field is reserved.
Reserved.
LINE_BEGIN
Number of PIXCLK cycles for line begin duration. This defines the interval between de-assertion of SDLE
and assertion of the SDCE signals. This value must be programmed to a multiple of SDCLK cycles
23.4.27
EPDC Timing Control Engine Vertical Timing Register
(EPDC_TCE_VSCANn)
Vertical scan timing registers
This register houses vertical scan timing. Note that frame data length is derived from
EPDC_RES.
Address: 228_C000h base + 2A0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
FRAME_END
FRAME_BEGIN
FRAME_SYNC
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
EPDC_TCE_VSCANn field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved.
23–16
FRAME_END
Number of lines for frame end duration.
15–8
FRAME_BEGIN
Number of lines for frame begin duration.
FRAME_SYNC
Number of lines for frame sync duration.
23.4.28
EPDC Timing Control Engine OE timing control Register
(EPDC_TCE_OEn)
This register contain delay programming values for the SDOEZ and SDOED source
driver control signals
This register contain delay programming values for the SDOZ and SDOE source driver
control signals
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1102
NXP Semiconductors

<!-- page 1103 -->

Address: 228_C000h base + 2C0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
SDOED_WIDTH
SDOED_DLY
SDOEZ_WIDTH
SDOEZ_DLY
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
EPDC_TCE_OEn field descriptions
Field
Description
31–24
SDOED_WIDTH
Number of PIXCLK cycles from SDOED high to SDOED falling (Must be greater than 0)
23–16
SDOED_DLY
Number of PIXCLK cycles from SDOEZ low to SDOED rising (Must be greater than 0)
15–8
SDOEZ_WIDTH
Number of PIXCLK cycles from SDOEZ high to SDOEZ falling (Must be greater than 0)
SDOEZ_DLY
Number of PIXCLK cycles from SDLE falling edge to SDOEZ rising (Must be greater than 0)
23.4.29
EPDC Timing Control Engine Driver Polarity Register
(EPDC_TCE_POLARITYn)
This registers allows for programming the polarity of source/gate driver control signals
This register houses FIFO control bits
Address: 228_C000h base + 2E0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
W
Reset
0
0
0
0
0
0
0
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
GDSP_POL
GDOE_POL
SDOE_POL
SDLE_POL
SDCE_POL
W
Reset
0
0
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
EPDC_TCE_POLARITYn field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved.
4
GDSP_POL
0 = Active Low, 1 = Active High. Applies to the GDSP output
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1103

<!-- page 1104 -->

EPDC_TCE_POLARITYn field descriptions (continued)
Field
Description
3
GDOE_POL
0 = Active Low, 1 = Active High. Applies to the GDOE output
2
SDOE_POL
0 = Active Low, 1 = Active High. Applies to the SDOE. Does not apply to SDOEZ and SDOED outputs
1
SDLE_POL
0 = Active Low, 1 = Active High. Applies to the SDLE output
0
SDCE_POL
0 = Active Low, 1 = Active High. Applies to all 10 SDCE outputs
23.4.30
EPDC Timing Control Engine Timing Register 1
(EPDC_TCE_TIMING1n)
This register contains various timing adjustment controls
This register houses general purpose timing adjustment registers
Address: 228_C000h base + 300h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
W
Reset
0
0
0
0
0
0
0
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
SDLE_SHIFT
SDCLK_INVERT
Reserved
SDCLK_
SHIFT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
EPDC_TCE_TIMING1n field descriptions
Field
Description
31–6
-
This field is reserved.
Reserved.
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1104
NXP Semiconductors

<!-- page 1105 -->

EPDC_TCE_TIMING1n field descriptions (continued)
Field
Description
5–4
SDLE_SHIFT
This register can be used to implement additional timing setup/hold adjustment of source driver signals by
adjusting the SDCLK up to 3 PIXCLK cycles
0x0
NONE — No shift of SDLE
0x1
ONE — Shift SDLE 1 pixclk cycle
0x2
TWO — Shift SDLE 2 pixclk cycles
0x3
THREE — Shift SDLE 3 pixclk cycles
3
SDCLK_INVERT
Invert phase of SDCLK
2
-
This field is reserved.
Reserved.
SDCLK_SHIFT
This register can be used to implement additional timing setup/hold adjustment of source driver signals by
adjusting the SDCLK up to 4 cycles
0x0
NONE — No shift of SDCLK
0x1
ONE — Shift SDCLK 1 pixclk cycle
0x2
TWO — Shift SDCLK 2 pixclk cycles
0x3
THREE — Shift SDCLK 3 pixclk cycles
23.4.31
EPDC Timing Control Engine Timing Register 2
(EPDC_TCE_TIMING2n)
This register contains various timing adjustment controls
This register houses general purpose timing adjustment registers
Address: 228_C000h base + 310h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
GDCLK_HP
GDSP_OFFSET
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
1
EPDC_TCE_TIMING2n field descriptions
Field
Description
31–16
GDCLK_HP
This register controls the GDCLK high-pulse width. It is expressed by N PIXCLKs where N=1 to 65535.
Note that GDCLK will always have a period equal to the line-clock timing. A value of 0 is not supported. It
is recommended that this value be set to at least a half line-clock time. For panels which use GDCLK to
drive GDOE, this high-pulse width should be set to cover tha majority of the line timing
GDSP_OFFSET This register allows the user to shift the GDSP pulse by N PIXCLKs where N=1 to 65535. Note that GDSP
will always have a pulse width equivalent to the line-clock timing. A value of 0 is not supported.
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1105

<!-- page 1106 -->

23.4.32
EPDC Timing Control Engine Timing Register 3
(EPDC_TCE_TIMING3n)
This register contains various timing adjustment controls
This register houses general purpose timing adjustment registers
Address: 228_C000h base + 320h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
GDOE_OFFSET
GDCLK_OFFSET
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
1
EPDC_TCE_TIMING3n field descriptions
Field
Description
31–16
GDOE_OFFSET
When using GDOE_MODE=1, this register sets the delay from GDCLK to the GDOE in terms of N
PIXCLK cycles
GDCLK_
OFFSET
This register allows the user to shift the GDCLK from the line time by N PIXCLK cycles.
23.4.33
EPDC Pigeon Mode Control Register 0
(EPDC_PIGEON_CTRL0n)
This register contains global counter settings for Pigeon Mode
This register houses general purpose timing adjustment registers
Address: 228_C000h base + 380h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
LD_PERIOD
Reserved
FD_PERIOD
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
EPDC_PIGEON_CTRL0n field descriptions
Field
Description
31–28
-
This field is reserved.
Reserved.
27–16
LD_PERIOD
period of pclk counter during LD phase
15–12
-
This field is reserved.
Reserved.
FD_PERIOD
period of line counter during FD phase
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1106
NXP Semiconductors

<!-- page 1107 -->

23.4.34
EPDC Pigeon Mode Control Register 1
(EPDC_PIGEON_CTRL1n)
This register contains global counter setting for pigeon mode
This register houses general purpose timing adjustment registers
Address: 228_C000h base + 390h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
FRAME_CNT_CYCLES
Reserved
FRAME_CNT_PERIOD
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
EPDC_PIGEON_CTRL1n field descriptions
Field
Description
31–28
-
This field is reserved.
Reserved.
27–16
FRAME_CNT_
CYCLES
max cycles of frame counter
15–12
-
This field is reserved.
Reserved.
FRAME_CNT_
PERIOD
period of frame counter
23.4.35
EPDC IRQ Mask Register for LUT 0~31 (EPDC_IRQ_MASK1n)
Controls masking EPDC LUT complete interrupts
This register controls LUT0~31 IRQ masks for EPDC interrupts
Address: 228_C000h base + 3C0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
LUTN_CMPLT_IRQ_EN
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
EPDC_IRQ_MASK1n field descriptions
Field
Description
LUTN_CMPLT_
IRQ_EN
LUT0~31 Complete Interrupt Enable
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1107

<!-- page 1108 -->

23.4.36
EPDC IRQ Mask Register for LUT 32~63
(EPDC_IRQ_MASK2n)
Controls masking EPDC LUT complete interrupts
This register controls LUT0~31 IRQ masks for EPDC interrupts
Address: 228_C000h base + 3D0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
LUTN_CMPLT_IRQ_EN
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
EPDC_IRQ_MASK2n field descriptions
Field
Description
LUTN_CMPLT_
IRQ_EN
LUT32~64 Complete Interrupt Enable
23.4.37
EPDC Interrupt Register for LUT 0~31 (EPDC_IRQ1n)
EPDC LUT Completion IRQs. The IRQ for a specific LUT is triggered when it's
corrrsponding physical update is competed on the screen. Each interrupt has a
corresponding mask register in EPDC_IRQ_MASK
This register houses the interrupt bits for the LUT Completions
Address: 228_C000h base + 3E0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
LUTN_CMPLT_IRQ
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
EPDC_IRQ1n field descriptions
Field
Description
LUTN_CMPLT_
IRQ
LUT 0~31 Complete Interrupt
23.4.38
EPDC Interrupt Registerr for LUT 32~63 (EPDC_IRQ2n)
EPDC LUT Completion IRQs. The IRQ for a specific LUT is triggered when it's
corrrsponding physical update is competed on the screen. Each interrupt has a
corresponding mask register in EPDC_IRQ_MASK
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1108
NXP Semiconductors

<!-- page 1109 -->

This register houses the interrupt bits for the LUT Completions
Address: 228_C000h base + 3F0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
LUTN_CMPLT_IRQ
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
EPDC_IRQ2n field descriptions
Field
Description
LUTN_CMPLT_
IRQ
LUT 32~64 Complete Interrupt
23.4.39
EPDC IRQ Mask Register (EPDC_IRQ_MASKn)
Controls masking for all EPDC interrupts
This register controls IRQ masks for all EPDC interrupts
Address: 228_C000h base + 400h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
PWR_IRQ_EN
UPD_DONE_IRQ_
EN
TCE_IDLE_IRQ_
EN
BUS_ERROR_
IRQ_EN
FRAME_END_
IRQ_EN
TCE_UNDERRUN_
IRQ_EN
COL_IRQ_EN
WB_CMPLT_IRQ_
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
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
EPDC_IRQ_MASKn field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved.
23
PWR_IRQ_EN
Enable power interrupt
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1109

<!-- page 1110 -->

EPDC_IRQ_MASKn field descriptions (continued)
Field
Description
22
UPD_DONE_
IRQ_EN
Enable UPD complete interrupt
21
TCE_IDLE_IRQ_
EN
Enable TCE Idle interrupt detection.
20
BUS_ERROR_
IRQ_EN
Enable AXI BUS ERROR interrupt detection.
19
FRAME_END_
IRQ_EN
If this bit is set, EPDC will assert the current frame end interrupt. This irq is only available during updating
period.
18
TCE_
UNDERRUN_
IRQ_EN
Enable pixel FIFO under-run condition detection.
17
COL_IRQ_EN
Enable collision detection interrupts for all LUTs
16
WB_CMPLT_
IRQ_EN
Enable WB complete interrupt
-
This field is reserved.
Reserved.
23.4.40
EPDC Interrupt Register (EPDC_IRQn)
EPDC LUT Completion IRQs. The IRQ for a specific LUT is triggered when it's
corrrsponding physical update is competed on the screen. Each interrupt has a
corresponding mask register in EPDC_IRQ_MASK
This register houses the interrupt bits for the LUT Completions
Address: 228_C000h base + 420h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
PWR_IRQ
UPD_DONE_IRQ
TCE_IDLE_IRQ
BUS_ERROR_
IRQ
FRAME_END_
IRQ
TCE_
UNDERRUN_
IRQ
LUT_COL_IRQ
WB_CMPLT_IRQ
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1110
NXP Semiconductors

<!-- page 1111 -->

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
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
EPDC_IRQn field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved.
23
PWR_IRQ
Power Interrupt
22
UPD_DONE_IRQ
Working buffer process complete Interrupt
21
TCE_IDLE_IRQ
Interrupt to indicate that the TCE has completed TFT frame scans and is in an idle state.
20
BUS_ERROR_
IRQ
Interrupt to indicate AXI BUS error occurs.
19
FRAME_END_
IRQ
Interrupt to indicate EPDC has completed the current frame and is in the vertical blanking period.
18
TCE_
UNDERRUN_
IRQ
Interrupt to indicate that a pixel FIFO under-run has occured.
17
LUT_COL_IRQ
Collision detection interrupt. Check EPDC_STATUS_COL.
16
WB_CMPLT_IRQ
Working buffer process complete Interrupt
-
This field is reserved.
Reserved.
23.4.41
EPDC Status Register - LUTs (EPDC_STATUS_LUTS1n)
EPDC Status Register - LUTS 0~31
Address: 228_C000h base + 440h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
LUTN_STS
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
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1111

<!-- page 1112 -->

EPDC_STATUS_LUTS1n field descriptions
Field
Description
LUTN_STS
LUT 0~31 Status : 1=ACTIVE, 0=IDLE
23.4.42
EPDC Status Register - LUTs (EPDC_STATUS_LUTS2n)
EPDC Status Register - LUTS 0~31
Address: 228_C000h base + 450h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
LUTN_STS
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
EPDC_STATUS_LUTS2n field descriptions
Field
Description
LUTN_STS
LUT 32~63 Status : 1=ACTIVE, 0=IDLE
23.4.43
EPDC Status Register - Next Available LUT
(EPDC_STATUS_NEXTLUT)
Holds value of next available LUT. Can be used for fast LUT assignment. This value can
be read and then used in an update command as part of the EPDC_UPD_CTRL register
write
The DIGCTL Status Register provides a read-only view to various input conditions and
internal states.
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1112
NXP Semiconductors

<!-- page 1113 -->

Address: 228_C000h base + 460h offset = 228_C460h
Bit
31
30
29
28
27
26
25
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
W
Reset
0
0
0
0
0
0
0
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
NEXT_LUT_VALID
Reserved
NEXT_LUT
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
0
1
1
1
1
1
1
EPDC_STATUS_NEXTLUT field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8
NEXT_LUT_
VALID
This bitfield can be used to check against a LUTs full condition
7–6
-
This field is reserved.
Reserved.
NEXT_LUT
Next available LUT value
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1113

<!-- page 1114 -->

23.4.44
EPDC LUT Collision Status (EPDC_STATUS_COL1n)
EPDC LUT Collision Status Register and works in conjuction with
EPDC_IRQ[LUT_COL_IRQ]. When a collision occurs the interrupt is set and all status
bits are set for LUTs which were touched by the collision. It does not set the bit for the
LUT which caused the collision. There is a single interrupt mask which is used to control
all the IRQ bits in this register (in EPDC_IRQ_MASK). Note that a collision caused by a
LUT which was set-up for no collision detection will not trigger any collision LUT IRQ
or status update. Note that clearing the interrupt bit EPDC_IRQ[LUT_COL_IRQ] clears
this register
Address: 228_C000h base + 480h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
LUTN_COL_STS
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
EPDC_STATUS_COL1n field descriptions
Field
Description
LUTN_COL_STS LUTn Collision Status
23.4.45
EPDC LUT Collision Status (EPDC_STATUS_COL2n)
EPDC LUT Collision Status Register and works in conjuction with
EPDC_IRQ[LUT_COL_IRQ]. When a collision occurs the interrupt is set and all status
bits are set for LUTs which were touched by the collision. It does not set the bit for the
LUT which caused the collision. There is a single interrupt mask which is used to control
all the IRQ bits in this register (in EPDC_IRQ_MASK). Note that a collision caused by a
LUT which was set-up for no collision detection will not trigger any collision LUT IRQ
or status update. Note that clearing the interrupt bit EPDC_IRQ[LUT_COL_IRQ] clears
this register
Address: 228_C000h base + 490h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
LUTN_COL_STS
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
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1114
NXP Semiconductors

<!-- page 1115 -->

EPDC_STATUS_COL2n field descriptions
Field
Description
LUTN_COL_STS LUTn Collision Status
23.4.46
EPDC General Status Register (EPDC_STATUSn)
Register to house non LUT specific status bits
This register houses general status bits
Address: 228_C000h base + 4A0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
HISTOGRAM_CP
W
Reset
0
0
0
0
0
0
0
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
HISTOGRAM_NP
Reserved
UPD_VOID
LUTS_UNDERRUN
LUTS_BUSY
WB_BUSY
W
Reset
0
0
0
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
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1115

<!-- page 1116 -->

EPDC_STATUSn field descriptions
Field
Description
31–21
-
This field is reserved.
Reserved.
20–16
HISTOGRAM_
CP
Indicates which histogram matched the existing bitmap(CP).
Bit[0] indicates that the bitmap pixels were fully contained within the HIST1 (single color ) histogram.
Bit[1] indicates that the bitmap pixels were fully contained within the HIST2 (black / white ) histogram.
Bit[2] indicates that the bitmap pixels were fully contained within the HIST4 (2-bit grayscale) histogram.
Bit[3] indicates that the bitmap pixels were fully contained within the HIST8 (3-bit grayscale) histogram.
Bit[4] indicates that the bitmap pixels were fully contained within the HIST16 (4-bit grayscale) histogram.
15–13
-
This field is reserved.
Reserved.
12–8
HISTOGRAM_
NP
Indicates which histogram matched the processed bitmap(NP).
Bit[0] indicates that the bitmap pixels were fully contained within the HIST1 (single color ) histogram.
Bit[1] indicates that the bitmap pixels were fully contained within the HIST2 (black / white ) histogram.
Bit[2] indicates that the bitmap pixels were fully contained within the HIST4 (2-bit grayscale) histogram.
Bit[3] indicates that the bitmap pixels were fully contained within the HIST8 (3-bit grayscale) histogram.
Bit[4] indicates that the bitmap pixels were fully contained within the HIST16 (4-bit grayscale) histogram.
7–4
-
This field is reserved.
Reserved.
3
UPD_VOID
Indicates that the update buffer is void. This means either no pixels need updating or all pixels requiring
updating were collided.
2
LUTS_
UNDERRUN
Provides a summary status of LUT fill. 1= not enough time for active luts read during blanking period
before vscan_holdoff. 0=complete all active luts fill during blanking period before VSCAN_HOLDOFF.
1
LUTS_BUSY
Provides a summary status of LUTs. 1= All LUTs are busy, 0= LUTs are available
0
WB_BUSY
Working buffer process is busy cannot accept new update requests. When WB_BUSY is 1, software
should wait for the WB_CMPLT_IRQ interrupt. When this interrupt occurs WB_BUSY is cleared
immediately. This is a real-time status of the process.
23.4.47
EPDC Collision Region Co-ordinate
(EPDC_UPD_COL_CORD)
EPDC Collision Region Co-ordinate, cleared when new update issued
This register only valid after WB completion and collision happens.
Address: 228_C000h base + 4C0h offset = 228_C4C0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
YCORD
Reserved
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
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1116
NXP Semiconductors

<!-- page 1117 -->

EPDC_UPD_COL_CORD field descriptions
Field
Description
31–29
-
This field is reserved.
Reserved.
28–16
YCORD
Y co-ordinate for collision region of the latest completed update
15–13
-
This field is reserved.
Reserved.
XCORD
X co-ordinate for collision region of the latest completed update
23.4.48
EPDC Collision Region Size (EPDC_UPD_COL_SIZE)
EPDC Collision Region Size of the latest completed update cleared when new update
issued
This register only valid after WB completion and collision happens.
Address: 228_C000h base + 4E0h offset = 228_C4E0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
HEIGHT
Reserved
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
EPDC_UPD_COL_SIZE field descriptions
Field
Description
31–29
-
This field is reserved.
Reserved.
28–16
HEIGHT
Height (in pixels)
15–13
-
This field is reserved.
Reserved.
WIDTH
Width (in pixels)
23.4.49
1-level Histogram Parameter Register.
(EPDC_HIST1_PARAM)
This register specifies the valid values for a 1-level(single color) histogram. If all pixels
in a bitmap is only one color, STATUS[0] will be set at the end of frame processing. All
comparator values should be programmed such that they are consistent with the
TFT_PIXEL_FORMAT control field.
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1117

<!-- page 1118 -->

Address: 228_C000h base + 600h offset = 228_C600h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
0
0
0
0
0
0
0
0
0
0
0
0
EPDC_HIST1_PARAM field descriptions
Field
Description
31–5
RSVD
This field is reserved.
Reserved, always set to zero.
VALUE0
value for 1-level histogram
23.4.50
2-level Histogram Parameter Register.
(EPDC_HIST2_PARAM)
This register specifies the valid values for a 2-level histogram. If all pixels in a bitmap
match these two values, STATUS[0] will be set at the end of frame processing. All
comparator values should be programmed such that they are consistent with the
TFT_PIXEL_FORMAT control field.
Address: 228_C000h base + 610h offset = 228_C610h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
VALUE1
Reserved
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
EPDC_HIST2_PARAM field descriptions
Field
Description
31–16
RSVD
This field is reserved.
Reserved, always set to zero.
15–13
-
This field is reserved.
Reserved, always set to zero.
12–8
VALUE1
White value for 2-level histogram
7–5
-
This field is reserved.
Reserved, always set to zero.
VALUE0
Black value for 2-level histogram
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1118
NXP Semiconductors

<!-- page 1119 -->

23.4.51
4-level Histogram Parameter Register.
(EPDC_HIST4_PARAM)
This register specifies the valid values for a 4-level histogram. If all pixels in a bitmap
match these two values, STATUS[1] will be set at the end of frame processing. All
comparator values should be programmed such that they are consistent with the
TFT_PIXEL_FORMAT control field.
Address: 228_C000h base + 620h offset = 228_C620h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
VALUE3
Reserved
VALUE2
Reserved
VALUE1
Reserved
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
EPDC_HIST4_PARAM field descriptions
Field
Description
31–29
-
This field is reserved.
Reserved, always set to zero.
28–24
VALUE3
GRAY3 (White) value for 4-level histogram
23–21
-
This field is reserved.
Reserved, always set to zero.
20–16
VALUE2
GRAY2 value for 4-level histogram
15–13
-
This field is reserved.
Reserved, always set to zero.
12–8
VALUE1
GRAY1 value for 4-level histogram
7–5
-
This field is reserved.
Reserved, always set to zero.
VALUE0
GRAY0 (Black) value for 4-level histogram
23.4.52
8-level Histogram Parameter 0 Register.
(EPDC_HIST8_PARAM0)
This register specifies four of the valid values for an 8-level histogram. If all pixels in a
bitmap match these two values, STATUS[2] will be set at the end of frame processing.
All comparator values should be programmed such that they are consistent with the
TFT_PIXEL_FORMAT control field.
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1119

<!-- page 1120 -->

Address: 228_C000h base + 630h offset = 228_C630h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
VALUE3
Reserved
VALUE2
Reserved
VALUE1
Reserved
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
EPDC_HIST8_PARAM0 field descriptions
Field
Description
31–29
-
This field is reserved.
Reserved, always set to zero.
28–24
VALUE3
GRAY3 value for 8-level histogram
23–21
-
This field is reserved.
Reserved, always set to zero.
20–16
VALUE2
GRAY2 value for 8-level histogram
15–13
-
This field is reserved.
Reserved, always set to zero.
12–8
VALUE1
GRAY1 value for 8-level histogram
7–5
-
This field is reserved.
Reserved, always set to zero.
VALUE0
GRAY0 (Black) value for 8-level histogram
23.4.53
8-level Histogram Parameter 1 Register.
(EPDC_HIST8_PARAM1)
This register specifies four of the valid values for an 8-level histogram. If all pixels in a
bitmap match these two values, STATUS[2] will be set at the end of frame processing.
All comparator values should be programmed such that they are consistent with the
TFT_PIXEL_FORMAT control field.
Address: 228_C000h base + 640h offset = 228_C640h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
VALUE7
Reserved
VALUE6
Reserved
VALUE5
Reserved
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
EPDC_HIST8_PARAM1 field descriptions
Field
Description
31–29
-
This field is reserved.
Reserved, always set to zero.
28–24
VALUE7
GRAY7 (White) value for 8-level histogram
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1120
NXP Semiconductors

<!-- page 1121 -->

EPDC_HIST8_PARAM1 field descriptions (continued)
Field
Description
23–21
-
This field is reserved.
Reserved, always set to zero.
20–16
VALUE6
GRAY6 value for 8-level histogram
15–13
-
This field is reserved.
Reserved, always set to zero.
12–8
VALUE5
GRAY5 value for 8-level histogram
7–5
-
This field is reserved.
Reserved, always set to zero.
VALUE4
GRAY4 value for 8-level histogram
23.4.54
16-level Histogram Parameter 0 Register.
(EPDC_HIST16_PARAM0)
This register specifies four of the valid values for a 16-level histogram. If all pixels in a
bitmap match these two values, STATUS[3] will be set at the end of frame processing.
All comparator values should be programmed such that they are consistent with the
TFT_PIXEL_FORMAT control field.
Address: 228_C000h base + 650h offset = 228_C650h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
VALUE3
Reserved
VALUE2
Reserved
VALUE1
Reserved
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
EPDC_HIST16_PARAM0 field descriptions
Field
Description
31–29
-
This field is reserved.
Reserved, always set to zero.
28–24
VALUE3
GRAY3 value for 16-level histogram
23–21
-
This field is reserved.
Reserved, always set to zero.
20–16
VALUE2
GRAY2 value for 16-level histogram
15–13
-
This field is reserved.
Reserved, always set to zero.
12–8
VALUE1
GRAY1 value for 16-level histogram
7–5
-
This field is reserved.
Reserved, always set to zero.
VALUE0
GRAY0 (Black) value for 16-level histogram
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1121

<!-- page 1122 -->

23.4.55
16-level Histogram Parameter Register.
(EPDC_HIST16_PARAM1)
This register specifies four of the valid values for a 16-level histogram. If all pixels in a
bitmap match these two values, STATUS[3] will be set at the end of frame processing.
All comparator values should be programmed such that they are consistent with the
TFT_PIXEL_FORMAT control field.
Address: 228_C000h base + 660h offset = 228_C660h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
VALUE7
Reserved
VALUE6
Reserved
VALUE5
Reserved
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
EPDC_HIST16_PARAM1 field descriptions
Field
Description
31–29
-
This field is reserved.
Reserved, always set to zero.
28–24
VALUE7
GRAY7 value for 16-level histogram
23–21
-
This field is reserved.
Reserved, always set to zero.
20–16
VALUE6
GRAY6 value for 16-level histogram
15–13
-
This field is reserved.
Reserved, always set to zero.
12–8
VALUE5
GRAY5 value for 16-level histogram
7–5
-
This field is reserved.
Reserved, always set to zero.
VALUE4
GRAY4 value for 16-level histogram
23.4.56
16-level Histogram Parameter Register.
(EPDC_HIST16_PARAM2)
This register specifies four of the valid values for a 16-level histogram. If all pixels in a
bitmap match these two values, STATUS[3] will be set at the end of frame processing.
All comparator values should be programmed such that they are consistent with the
TFT_PIXEL_FORMAT control field.
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1122
NXP Semiconductors

<!-- page 1123 -->

Address: 228_C000h base + 670h offset = 228_C670h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
VALUE11
Reserved
VALUE10
Reserved
VALUE9
Reserved
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
EPDC_HIST16_PARAM2 field descriptions
Field
Description
31–29
-
This field is reserved.
Reserved, always set to zero.
28–24
VALUE11
GRAY11 value for 16-level histogram
23–21
-
This field is reserved.
Reserved, always set to zero.
20–16
VALUE10
GRAY10 value for 16-level histogram
15–13
-
This field is reserved.
Reserved, always set to zero.
12–8
VALUE9
GRAY9 value for 16-level histogram
7–5
-
This field is reserved.
Reserved, always set to zero.
VALUE8
GRAY8 value for 16-level histogram
23.4.57
16-level Histogram Parameter Register.
(EPDC_HIST16_PARAM3)
This register specifies four of the valid values for a 16-level histogram. If all pixels in a
bitmap match these two values, STATUS[3] will be set at the end of frame processing.
All comparator values should be programmed such that they are consistent with the
TFT_PIXEL_FORMAT control field.
Address: 228_C000h base + 680h offset = 228_C680h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
VALUE15
Reserved
VALUE14
Reserved
VALUE13
Reserved
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
EPDC_HIST16_PARAM3 field descriptions
Field
Description
31–29
-
This field is reserved.
Reserved, always set to zero.
28–24
VALUE15
GRAY15 (White) value for 16-level histogram
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1123

<!-- page 1124 -->

EPDC_HIST16_PARAM3 field descriptions (continued)
Field
Description
23–21
-
This field is reserved.
Reserved, always set to zero.
20–16
VALUE14
GRAY14 value for 16-level histogram
15–13
-
This field is reserved.
Reserved, always set to zero.
12–8
VALUE13
GRAY13 value for 16-level histogram
7–5
-
This field is reserved.
Reserved, always set to zero.
VALUE12
GRAY12 value for 16-level histogram
23.4.58
EPDC General Purpose I/O Debug register (EPDC_GPIOn)
GPIO register to control ipp_epdc_bdr[1:0], ipp_epdc_pwr[3:0] and ipp_epdc_pwrcom
output signals
Houses software control signal reisters
Address: 228_C000h base + 700h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1124
NXP Semiconductors

<!-- page 1125 -->

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
PWRSTAT
PWRWAKE
PWRCOM
PWRCTRL
BDR
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
EPDC_GPIOn field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8
PWRSTAT
reflect ipp_epdc_pwrstat input
7
PWRWAKE
Controls ipp_epdc_pwrwake output
6
PWRCOM
Controls ipp_epdc_pwrcom output
5–2
PWRCTRL
Controls ipp_epdc_pwrctrl[3:0] output
BDR
Controls ipp_epdc_bdr[1:0] output
23.4.59
EPDC Version Register (EPDC_VERSION)
This register reflects the version number for the EPDC.
EXAMPLE
No Example.
Address: 228_C000h base + 7F0h offset = 228_C7F0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1125

<!-- page 1126 -->

EPDC_VERSION field descriptions
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
23.4.60
Panel Interface Signal Generator Register 0_0
(EPDC_PIGEON_0_0)
parameters for timing signal generation
Address: 228_C000h base + 800h offset = 228_C800h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_0_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1126
NXP Semiconductors

<!-- page 1127 -->

EPDC_PIGEON_0_0 field descriptions (continued)
Field
Description
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
23.4.61
Panel Interface Signal Generator Register 0_1
(EPDC_PIGEON_0_1)
parameters for timing signal generation
Address: 228_C000h base + 810h offset = 228_C810h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
EPDC_PIGEON_0_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.62
Panel Interface Signal Generator Register 0_1
(EPDC_PIGEON_0_2)
parameters for timing signal generation
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1127

<!-- page 1128 -->

Address: 228_C000h base + 820h offset = 228_C820h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_0_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.63
Panel Interface Signal Generator Register 1_0
(EPDC_PIGEON_1_0)
parameters for timing signal generation
Address: 228_C000h base + 840h offset = 228_C840h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_1_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1128
NXP Semiconductors

<!-- page 1129 -->

EPDC_PIGEON_1_0 field descriptions (continued)
Field
Description
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
23.4.64
Panel Interface Signal Generator Register 1_1
(EPDC_PIGEON_1_1)
parameters for timing signal generation
Address: 228_C000h base + 850h offset = 228_C850h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1129

<!-- page 1130 -->

EPDC_PIGEON_1_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.65
Panel Interface Signal Generator Register 1_1
(EPDC_PIGEON_1_2)
parameters for timing signal generation
Address: 228_C000h base + 860h offset = 228_C860h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_1_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.66
Panel Interface Signal Generator Register 2_0
(EPDC_PIGEON_2_0)
parameters for timing signal generation
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1130
NXP Semiconductors

<!-- page 1131 -->

Address: 228_C000h base + 880h offset = 228_C880h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_2_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1131

<!-- page 1132 -->

23.4.67
Panel Interface Signal Generator Register 2_1
(EPDC_PIGEON_2_1)
parameters for timing signal generation
Address: 228_C000h base + 890h offset = 228_C890h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
EPDC_PIGEON_2_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.68
Panel Interface Signal Generator Register 2_1
(EPDC_PIGEON_2_2)
parameters for timing signal generation
Address: 228_C000h base + 8A0h offset = 228_C8A0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_2_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1132
NXP Semiconductors

<!-- page 1133 -->

EPDC_PIGEON_2_2 field descriptions (continued)
Field
Description
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.69
Panel Interface Signal Generator Register 3_0
(EPDC_PIGEON_3_0)
parameters for timing signal generation
Address: 228_C000h base + 8C0h offset = 228_C8C0h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_3_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1133

<!-- page 1134 -->

EPDC_PIGEON_3_0 field descriptions (continued)
Field
Description
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
23.4.70
Panel Interface Signal Generator Register 3_1
(EPDC_PIGEON_3_1)
parameters for timing signal generation
Address: 228_C000h base + 8D0h offset = 228_C8D0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
EPDC_PIGEON_3_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.71
Panel Interface Signal Generator Register 3_1
(EPDC_PIGEON_3_2)
parameters for timing signal generation
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1134
NXP Semiconductors

<!-- page 1135 -->

Address: 228_C000h base + 8E0h offset = 228_C8E0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_3_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.72
Panel Interface Signal Generator Register 4_0
(EPDC_PIGEON_4_0)
parameters for timing signal generation
Address: 228_C000h base + 900h offset = 228_C900h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_4_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1135

<!-- page 1136 -->

EPDC_PIGEON_4_0 field descriptions (continued)
Field
Description
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
23.4.73
Panel Interface Signal Generator Register 4_1
(EPDC_PIGEON_4_1)
parameters for timing signal generation
Address: 228_C000h base + 910h offset = 228_C910h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1136
NXP Semiconductors

<!-- page 1137 -->

EPDC_PIGEON_4_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.74
Panel Interface Signal Generator Register 4_1
(EPDC_PIGEON_4_2)
parameters for timing signal generation
Address: 228_C000h base + 920h offset = 228_C920h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_4_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.75
Panel Interface Signal Generator Register 5_0
(EPDC_PIGEON_5_0)
parameters for timing signal generation
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1137

<!-- page 1138 -->

Address: 228_C000h base + 940h offset = 228_C940h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_5_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1138
NXP Semiconductors

<!-- page 1139 -->

23.4.76
Panel Interface Signal Generator Register 5_1
(EPDC_PIGEON_5_1)
parameters for timing signal generation
Address: 228_C000h base + 950h offset = 228_C950h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
EPDC_PIGEON_5_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.77
Panel Interface Signal Generator Register 5_1
(EPDC_PIGEON_5_2)
parameters for timing signal generation
Address: 228_C000h base + 960h offset = 228_C960h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_5_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1139

<!-- page 1140 -->

EPDC_PIGEON_5_2 field descriptions (continued)
Field
Description
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.78
Panel Interface Signal Generator Register 6_0
(EPDC_PIGEON_6_0)
parameters for timing signal generation
Address: 228_C000h base + 980h offset = 228_C980h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_6_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1140
NXP Semiconductors

<!-- page 1141 -->

EPDC_PIGEON_6_0 field descriptions (continued)
Field
Description
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
23.4.79
Panel Interface Signal Generator Register 6_1
(EPDC_PIGEON_6_1)
parameters for timing signal generation
Address: 228_C000h base + 990h offset = 228_C990h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
EPDC_PIGEON_6_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.80
Panel Interface Signal Generator Register 6_1
(EPDC_PIGEON_6_2)
parameters for timing signal generation
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1141

<!-- page 1142 -->

Address: 228_C000h base + 9A0h offset = 228_C9A0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_6_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.81
Panel Interface Signal Generator Register 7_0
(EPDC_PIGEON_7_0)
parameters for timing signal generation
Address: 228_C000h base + 9C0h offset = 228_C9C0h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_7_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1142
NXP Semiconductors

<!-- page 1143 -->

EPDC_PIGEON_7_0 field descriptions (continued)
Field
Description
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
23.4.82
Panel Interface Signal Generator Register 7_1
(EPDC_PIGEON_7_1)
parameters for timing signal generation
Address: 228_C000h base + 9D0h offset = 228_C9D0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1143

<!-- page 1144 -->

EPDC_PIGEON_7_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.83
Panel Interface Signal Generator Register 7_1
(EPDC_PIGEON_7_2)
parameters for timing signal generation
Address: 228_C000h base + 9E0h offset = 228_C9E0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_7_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.84
Panel Interface Signal Generator Register 8_0
(EPDC_PIGEON_8_0)
parameters for timing signal generation
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1144
NXP Semiconductors

<!-- page 1145 -->

Address: 228_C000h base + A00h offset = 228_CA00h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_8_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1145

<!-- page 1146 -->

23.4.85
Panel Interface Signal Generator Register 8_1
(EPDC_PIGEON_8_1)
parameters for timing signal generation
Address: 228_C000h base + A10h offset = 228_CA10h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
EPDC_PIGEON_8_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.86
Panel Interface Signal Generator Register 8_1
(EPDC_PIGEON_8_2)
parameters for timing signal generation
Address: 228_C000h base + A20h offset = 228_CA20h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_8_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1146
NXP Semiconductors

<!-- page 1147 -->

EPDC_PIGEON_8_2 field descriptions (continued)
Field
Description
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.87
Panel Interface Signal Generator Register 9_0
(EPDC_PIGEON_9_0)
parameters for timing signal generation
Address: 228_C000h base + A40h offset = 228_CA40h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_9_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1147

<!-- page 1148 -->

EPDC_PIGEON_9_0 field descriptions (continued)
Field
Description
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
23.4.88
Panel Interface Signal Generator Register 9_1
(EPDC_PIGEON_9_1)
parameters for timing signal generation
Address: 228_C000h base + A50h offset = 228_CA50h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
EPDC_PIGEON_9_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.89
Panel Interface Signal Generator Register 9_1
(EPDC_PIGEON_9_2)
parameters for timing signal generation
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1148
NXP Semiconductors

<!-- page 1149 -->

Address: 228_C000h base + A60h offset = 228_CA60h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_9_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.90
Panel Interface Signal Generator Register 10_0
(EPDC_PIGEON_10_0)
parameters for timing signal generation
Address: 228_C000h base + A80h offset = 228_CA80h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_10_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1149

<!-- page 1150 -->

EPDC_PIGEON_10_0 field descriptions (continued)
Field
Description
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
23.4.91
Panel Interface Signal Generator Register 10_1
(EPDC_PIGEON_10_1)
parameters for timing signal generation
Address: 228_C000h base + A90h offset = 228_CA90h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1150
NXP Semiconductors

<!-- page 1151 -->

EPDC_PIGEON_10_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.92
Panel Interface Signal Generator Register 10_1
(EPDC_PIGEON_10_2)
parameters for timing signal generation
Address: 228_C000h base + AA0h offset = 228_CAA0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_10_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.93
Panel Interface Signal Generator Register 11_0
(EPDC_PIGEON_11_0)
parameters for timing signal generation
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1151

<!-- page 1152 -->

Address: 228_C000h base + AC0h offset = 228_CAC0h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_11_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1152
NXP Semiconductors

<!-- page 1153 -->

23.4.94
Panel Interface Signal Generator Register 11_1
(EPDC_PIGEON_11_1)
parameters for timing signal generation
Address: 228_C000h base + AD0h offset = 228_CAD0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
EPDC_PIGEON_11_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.95
Panel Interface Signal Generator Register 11_1
(EPDC_PIGEON_11_2)
parameters for timing signal generation
Address: 228_C000h base + AE0h offset = 228_CAE0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_11_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1153

<!-- page 1154 -->

EPDC_PIGEON_11_2 field descriptions (continued)
Field
Description
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.96
Panel Interface Signal Generator Register 12_0
(EPDC_PIGEON_12_0)
parameters for timing signal generation
Address: 228_C000h base + B00h offset = 228_CB00h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_12_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1154
NXP Semiconductors

<!-- page 1155 -->

EPDC_PIGEON_12_0 field descriptions (continued)
Field
Description
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
23.4.97
Panel Interface Signal Generator Register 12_1
(EPDC_PIGEON_12_1)
parameters for timing signal generation
Address: 228_C000h base + B10h offset = 228_CB10h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
EPDC_PIGEON_12_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.98
Panel Interface Signal Generator Register 12_1
(EPDC_PIGEON_12_2)
parameters for timing signal generation
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1155

<!-- page 1156 -->

Address: 228_C000h base + B20h offset = 228_CB20h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_12_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.99
Panel Interface Signal Generator Register 13_0
(EPDC_PIGEON_13_0)
parameters for timing signal generation
Address: 228_C000h base + B40h offset = 228_CB40h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_13_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1156
NXP Semiconductors

<!-- page 1157 -->

EPDC_PIGEON_13_0 field descriptions (continued)
Field
Description
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
23.4.100
Panel Interface Signal Generator Register 13_1
(EPDC_PIGEON_13_1)
parameters for timing signal generation
Address: 228_C000h base + B50h offset = 228_CB50h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1157

<!-- page 1158 -->

EPDC_PIGEON_13_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.101
Panel Interface Signal Generator Register 13_1
(EPDC_PIGEON_13_2)
parameters for timing signal generation
Address: 228_C000h base + B60h offset = 228_CB60h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_13_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.102
Panel Interface Signal Generator Register 14_0
(EPDC_PIGEON_14_0)
parameters for timing signal generation
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1158
NXP Semiconductors

<!-- page 1159 -->

Address: 228_C000h base + B80h offset = 228_CB80h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_14_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1159

<!-- page 1160 -->

23.4.103
Panel Interface Signal Generator Register 14_1
(EPDC_PIGEON_14_1)
parameters for timing signal generation
Address: 228_C000h base + B90h offset = 228_CB90h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
EPDC_PIGEON_14_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.104
Panel Interface Signal Generator Register 14_1
(EPDC_PIGEON_14_2)
parameters for timing signal generation
Address: 228_C000h base + BA0h offset = 228_CBA0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_14_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
Table continues on the next page...
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1160
NXP Semiconductors

<!-- page 1161 -->

EPDC_PIGEON_14_2 field descriptions (continued)
Field
Description
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.105
Panel Interface Signal Generator Register 15_0
(EPDC_PIGEON_15_0)
parameters for timing signal generation
Address: 228_C000h base + BC0h offset = 228_CBC0h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_15_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1161

<!-- page 1162 -->

EPDC_PIGEON_15_0 field descriptions (continued)
Field
Description
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
23.4.106
Panel Interface Signal Generator Register 15_1
(EPDC_PIGEON_15_1)
parameters for timing signal generation
Address: 228_C000h base + BD0h offset = 228_CBD0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
EPDC_PIGEON_15_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.107
Panel Interface Signal Generator Register 15_1
(EPDC_PIGEON_15_2)
parameters for timing signal generation
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1162
NXP Semiconductors

<!-- page 1163 -->

Address: 228_C000h base + BE0h offset = 228_CBE0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_15_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
23.4.108
Panel Interface Signal Generator Register 16_0
(EPDC_PIGEON_16_0)
parameters for timing signal generation
Address: 228_C000h base + C00h offset = 228_CC00h
Bit
31
30
29
28
27
26
25
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
STATE_MASK
MASK_CNT
W
Reset
0
0
0
0
0
0
0
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
MASK_CNT
MASK_CNT_SEL
OFFSET
INC_SEL
POL
EN
W
Reset
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
EPDC_PIGEON_16_0 field descriptions
Field
Description
31–24
STATE_MASK
state_mask = (FS|FB|FD|FE) and (LS|LB|LD|LE) , select any combination of scan states as reference
point for local counter to start ticking
0x1
FS — FRAME SYNC
Table continues on the next page...
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1163

<!-- page 1164 -->

EPDC_PIGEON_16_0 field descriptions (continued)
Field
Description
0x2
FB — FRAME BEGIN
0x4
FD — FRAME DATA
0x8
FE — FRAME END
0x10
LS — LINE SYNC
0x20
LB — LINE BEGIN
0x40
LD — LINE DATA
0x80
LE — LINE END
23–12
MASK_CNT
When the global counter selected through MASK_CNT_SEL matches value in this reg, pigeon local
counter start ticking. 0=disable
11–8
MASK_CNT_SEL
select global counters as mask condition, use together with MASK_CNT
0x0
HSTATE_CNT — pclk counter within one hscan state
0x1
HSTATE_CYCLE — pclk cycle within one hscan state
0x2
VSTATE_CNT — line counter within one vscan state
0x3
VSTATE_CYCLE — line cycle within one vscan state
0x4
FRAME_CNT — frame counter
0x5
FRAME_CYCLE — frame cycle
0x6
HCNT — horizontal counter (pclk counter within one line )
0x7
VCNT — vertical counter (line counter within one frame)
7–4
OFFSET
offset on pclk unit. 0=aligne with data, positive value means delay, minus value mean ahead. Supported
range depends on panel mode
3–2
INC_SEL
event to incrment local counter
0x0
PCLK — pclk
0x1
LINE — line start pulse
0x2
FRAME — frame start pulse
0x3
SIG_ANOTHER — use another signal as tick event
1
POL
polarity of signal output
0x0
ACTIVE_HIGH — normal signal (active high)
0x1
ACTIVE_LOW — inverted signal (active low)
0
EN
enable pigeon mode on this signal
23.4.109
Panel Interface Signal Generator Register 16_1
(EPDC_PIGEON_16_1)
parameters for timing signal generation
Address: 228_C000h base + C10h offset = 228_CC10h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CLR_CNT
SET_CNT
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
EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1164
NXP Semiconductors

<!-- page 1165 -->

EPDC_PIGEON_16_1 field descriptions
Field
Description
31–16
CLR_CNT
deassert signal output when counter match this value
0x0
CLEAR_USING_MASK — keep active until mask off
SET_CNT
assert signal output when counter match this value
0x0
START_ACTIVE — start as active
23.4.110
Panel Interface Signal Generator Register 16_1
(EPDC_PIGEON_16_2)
parameters for timing signal generation
Address: 228_C000h base + C20h offset = 228_CC20h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
SIG_ANOTHER
SIG_LOGIC
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
EPDC_PIGEON_16_2 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8–4
SIG_ANOTHER
select another signal for logic operation or as mask or counter tick event
SIG_LOGIC
logic operation with another signal
sigout : final output signal of this generator
mask : final mask of this generator
this_sig : intermediate signal of this generator before logic operation
other_masks : intermediate mask result of this generator before logic operation
sig_another : signal selected other generators
0x0
DIS — no logic operation
0x1
AND — sigout = sig_another AND this_sig
0x2
OR — sigout = sig_another OR this_sig
0x3
MASK — mask = sig_another AND other_masks
Chapter 23 Electrophoretic Display Controller (EPDC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1165

<!-- page 1166 -->

EPDC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1166
NXP Semiconductors

