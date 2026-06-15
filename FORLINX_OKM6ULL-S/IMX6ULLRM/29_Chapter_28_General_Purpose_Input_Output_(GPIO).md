# Chapter 28: General Purpose Input/Output (GPIO)

> Nguồn: `IMX6ULLRM.pdf` — trang 1343–1370

<!-- page 1343 -->

Chapter 28
General Purpose Input/Output (GPIO)
28.1
Overview
The GPIO general-purpose input/output peripheral provides dedicated general-purpose
pins that can be configured as either inputs or outputs.
When configured as an output, it is possible to write to an internal register to control the
state driven on the output pin. When configured as an input, it is possible to detect the
state of the input by reading the state of an internal register. In addition, the GPIO
peripheral can produce CORE interrupts.
The GPIO is one of the blocks controlling the IOMUX of the chip.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1343

<!-- page 1344 -->

Data_in
Data_out
Dir
PAD1
alternate input
IOMUX
IOMUX
input_on
Data_in
Data_out
Dir
PAD2
input_on
SW_PAD_CTL_PAD_*
GPIO
GPIO.DR
GPIO.GDIR
pad settings
Block 
GPIO.PSR
GPIO.ICR1
GPIO.IMR
GPIO.ISR
SW_MUX_CTL_PAD_*
IOMUXC
MUX_MODE
GPIO.ICR2
 
GPIO.EDGE_SEL
This block not 
configured as a GPIO 
Figure 28-1. Chip IOMUX Scheme
The GPIO functionality is provided through eight registers, an edge-detect circuit, and
interrupt generation logic.
The eight registers are:
• Data register (GPIO_DR)
• GPIO direction register (GPIO_GDIR)
• Pad sample register (GPIO_PSR)
• Interrupt control registers (GPIO_ICR1, GPIO_ICR2)
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1344
NXP Semiconductors

<!-- page 1345 -->

• Edge select register (GPIO_EDGE_SEL)
• Interrupt mask register (GPIO_IMR)
• Interrupt status register (GPIO_ISR)
These registers are described in detail in GPIO Memory Map/Register Definition.
Each GPIO input has a dedicated edge-detect circuit which can be configured through
software to detect rising edges, falling edges, logic low-levels or logic high-levels on the
input signals. The outputs of the edge detect circuits are optionally masked by setting the
corresponding bit in the interrupt mask register (GPIO_IMR). These qualified outputs are
OR'ed together to generate two one-bit interrupt lines:
• Combined interrupt indication for GPIOx signals 0 - 15
• Combined interrupt indication for GPIOx signals 16 - 31
In addition, GPIO1 provides visibility to each of its 8 low order interrupt sources (i.e.
GPIO1 interrupt n, for n = 0 – 7). However, individual interrupt indications from other
GPIOx are not available.
The GPIO edge detection is described further in Interrupt Control Unit.
The GPIO's overall functionality is described further in GPIO Functional Description.
28.1.1
Block Diagram
The GPIO subsystem contains multiple GPIO blocks, which can generate and control up
to 32 signals for general purpose.
A block diagram of the GPIO is shown in Figure 28-2
Chapter 28 General Purpose Input/Output (GPIO)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1345

<!-- page 1346 -->

GDIR
GPIO_DR
GPIO_PSR
GPIO_ISR
Interrupt
Control
Unit
ICR0
GPIO_ICR1
GPIO_EDGE_SEL
GPIO_IMR
IP Bus Interface
gdir
gpio_dr
gpio_in
int_31_16
int_15_0
int_31_0
Figure 28-2. GPIO Block Diagram
28.1.2
Features
The GPIO includes the following features:
• General purpose input/output logic capabilities:
• Drives specific data to output using the data register (GPIO_DR)
• Controls the direction of the signal using the GPIO direction register
(GPIO_GDIR)
• Enables the core to sample the status of the corresponding inputs by reading the
pad sample register (GPIO_PSR).
• GPIO interrupt capabilities:
• Supports up to 32 interrupts
• Identifies interrupt edges
• Generates three active-high interrupts to the SoC interrupt controller
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1346
NXP Semiconductors

<!-- page 1347 -->

28.2
External Signals
The tables found here describe the external signals of GPIO.
Table 28-1. GPIO External Signals
Instance
Signal
Pad
Mode
Direction
GPIO1
IO0
GPIO1_IO00
ALT5
I/O
IO1
GPIO1_IO01
ALT5
IO2
GPIO1_IO02
ALT5
IO3
GPIO1_IO03
ALT5
IO4
GPIO1_IO04
ALT5
IO5
GPIO1_IO05
ALT5
IO6
GPIO1_IO06
ALT5
IO7
GPIO1_IO07
ALT5
IO8
GPIO1_IO08
ALT5
IO9
GPIO1_IO09
ALT5
IO10
JTAG_MOD
ALT5
IO11
JTAG_TMS
ALT5
IO12
JTAG_TDO
ALT5
IO13
JTAG_TDI
ALT5
IO14
JTAG_TCK
ALT5
IO15
JTAG_TRST_B
ALT5
IO16
UART1_TX_DATA
ALT5
IO17
UART1_RX_DATA
ALT5
IO18
UART1_CTS_B
ALT5
IO19
UART1_RTS_B
ALT5
IO20
UART2_TX_DATA
ALT5
IO21
UART2_RX_DATA
ALT5
IO22
UART2_CTS_B
ALT5
IO23
UART2_RTS_B
ALT5
IO24
UART3_TX_DATA
ALT5
IO25
UART3_RX_DATA
ALT5
IO26
UART3_CTS_B
ALT5
IO27
UART3_RTS_B
ALT5
IO28
UART4_TX_DATA
ALT5
IO29
UART4_RX_DATA
ALT5
IO30
UART5_TX_DATA
ALT5
IO31
UART5_RX_DATA
ALT5
GPIO2
IO0
ENET1_RX_DATA0
ALT5
I/O
IO1
ENET1_RX_DATA1
ALT5
IO2
ENET1_RX_EN
ALT5
IO3
ENET1_TX_DATA0
ALT5
Table continues on the next page...
Chapter 28 General Purpose Input/Output (GPIO)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1347

<!-- page 1348 -->

Table 28-1. GPIO External Signals (continued)
Instance
Signal
Pad
Mode
Direction
IO4
ENET1_TX_DATA1
ALT5
IO5
ENET1_TX_EN
ALT5
IO6
ENET1_TX_CLK
ALT5
IO7
ENET1_RX_ER
ALT5
IO8
ENET2_RX_DATA0
ALT5
IO9
ENET2_RX_DATA1
ALT5
IO10
ENET2_RX_EN
ALT5
IO11
ENET2_TX_DATA0
ALT5
IO12
ENET2_TX_DATA1
ALT5
IO13
ENET2_TX_EN
ALT5
IO14
ENET2_TX_CLK
ALT5
IO15
ENET2_RX_ER
ALT5
IO16
SD1_CMD
ALT5
IO17
SD1_CLK
ALT5
IO18
SD1_DATA0
ALT5
IO19
SD1_DATA1
ALT5
IO20
SD1_DATA2
ALT5
IO21
SD1_DATA3
ALT5
GPIO3
IO0
LCD_CLK
ALT5
I/O
IO1
LCD_ENABLE
ALT5
IO2
LCD_HSYNC
ALT5
IO3
LCD_VSYNC
ALT5
IO4
LCD_RESET
ALT5
IO5
LCD_DATA00
ALT5
IO6
LCD_DATA01
ALT5
IO7
LCD_DATA02
ALT5
IO8
LCD_DATA03
ALT5
IO9
LCD_DATA04
ALT5
IO10
LCD_DATA05
ALT5
IO11
LCD_DATA06
ALT5
IO12
LCD_DATA07
ALT5
IO13
LCD_DATA08
ALT5
IO14
LCD_DATA09
ALT5
IO15
LCD_DATA10
ALT5
IO16
LCD_DATA11
ALT5
IO17
LCD_DATA12
ALT5
IO18
LCD_DATA13
ALT5
IO19
LCD_DATA14
ALT5
IO20
LCD_DATA15
ALT5
Table continues on the next page...
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1348
NXP Semiconductors

<!-- page 1349 -->

Table 28-1. GPIO External Signals (continued)
Instance
Signal
Pad
Mode
Direction
IO21
LCD_DATA16
ALT5
IO22
LCD_DATA17
ALT5
IO23
LCD_DATA18
ALT5
IO24
LCD_DATA19
ALT5
IO25
LCD_DATA20
ALT5
IO26
LCD_DATA21
ALT5
IO27
LCD_DATA22
ALT5
IO28
LCD_DATA23
ALT5
GPIO4
IO0
NAND_RE_B
ALT5
I/O
IO1
NAND_WE_B
ALT5
IO2
NAND_DATA00
ALT5
IO3
NAND_DATA01
ALT5
IO4
NAND_DATA02
ALT5
IO5
NAND_DATA03
ALT5
IO6
NAND_DATA04
ALT5
IO7
NAND_DATA05
ALT5
IO8
NAND_DATA06
ALT5
IO9
NAND_DATA07
ALT5
IO10
NAND_ALE
ALT5
IO11
NAND_WP_B
ALT5
IO12
NAND_READY_B
ALT5
IO13
NAND_CE0_B
ALT5
IO14
NAND_CE1_B
ALT5
IO15
NAND_CLE
ALT5
IO16
NAND_DQS
ALT5
IO17
CSI_MCLK
ALT5
IO18
CSI_PIXCLK
ALT5
IO19
CSI_VSYNC
ALT5
IO20
CSI_HSYNC
ALT5
IO21
CSI_DATA00
ALT5
IO22
CSI_DATA01
ALT5
IO23
CSI_DATA02
ALT5
IO24
CSI_DATA03
ALT5
IO25
CSI_DATA04
ALT5
IO26
CSI_DATA05
ALT5
IO27
CSI_DATA06
ALT5
IO28
CSI_DATA07
ALT5
GPIO5
IO0
SNVS_TAMPER0
No Muxing
(ALT5)
I/O
Table continues on the next page...
Chapter 28 General Purpose Input/Output (GPIO)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1349

<!-- page 1350 -->

Table 28-1. GPIO External Signals (continued)
Instance
Signal
Pad
Mode
Direction
IO1
SNVS_TAMPER1
No Muxing
(ALT5)
IO2
SNVS_TAMPER2
No Muxing
(ALT5)
IO3
SNVS_TAMPER3
No Muxing
(ALT5)
IO4
SNVS_TAMPER4
No Muxing
(ALT5)
IO5
SNVS_TAMPER5
No Muxing
(ALT5)
IO6
SNVS_TAMPER6
No Muxing
(ALT5)
IO7
SNVS_TAMPER7
No Muxing
(ALT5)
IO8
SNVS_TAMPER8
No Muxing
(ALT5)
IO9
SNVS_TAMPER9
No Muxing
(ALT5)
IO10
BOOT_MODE0
No Muxing
(ALT5)
IO11
BOOT_MODE1
No Muxing
(ALT5)
28.3
Clocks
The table found here describes the clock sources for GPIO.
Please see the clock controller Module for clock setting, configuration and gating
information.
Table 28-2. GPIO Clocks
Clock name
Clock Root
Description
ipg_clk_s
ipg_clk_root
Peripheral access clock
28.4
GPIO Functional Description
This section provides a complete functional description of the block.
Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1350
NXP Semiconductors

<!-- page 1351 -->

28.4.1
GPIO Function
A GPIO signal can operate as a general-purpose input/output when the IOMUX is set to
GPIO mode. Each GPIO signal may be independently configured as either an input or an
output using the GPIO direction register (GPIO_GDIR).
When configured as an output (GPIO_GDIR bit = 1), the value in the data bit in the
GPIO data register (GPIO_DR) is driven on the corresponding GPIO line. When a signal
is configured as an input (GPIO_GDIR bit = 0), the state of the input can be read from
the corresponding GPIO_PSR bit.
28.4.2
GPIO pad structure
PUS
PU / PD / Keeper
Logic
PU / PD Keeper
esd clamp or
trigger circuit
PAD
Output
Driver
ODE
PKE
output buffer enable (OBE)
SRE
SPEED
Driver
Config
Logic
HYS
Input
Receiver
Resd
input buffer enable (IBE)
DSE
IND
pull_en_b
Figure 28-3. GPIO pad functional diagram
Chapter 28 General Purpose Input/Output (GPIO)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1351

<!-- page 1352 -->

28.4.2.1
Input Driver
Input driver characteristics
• Selectable Schmitt trigger or CMOS input mode
• Keeper structure with buffer at the input receiver output to Core
• Receiver is tri-stated when I/O supply (OVDD) is powered down. (Keeper at receiver
output keeps its previous state).
28.4.2.1.1
Schmitt trigger
The anti-jamming functionality of the Schmitt trigger is illustrated below.
 
Vt+ 
Vt- 
Vo 
Vi 
Figure 28-4. Schmitt trigger transfer characteristic
noisy input voltage
cmos receiver output with multiple
transitions caused by input noise
noise is filtered out in receiver with
hysteresis mode
time
Vt+
Vth
Vt-
Figure 28-5. Receiver output in CMOS and hysteresis
GPIO Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1352
NXP Semiconductors

<!-- page 1353 -->

28.4.2.1.2
Input keeper
A simple latch to hold the input value when OVDD is powered down, or the first inverter
is tri-stated. Input buffer’s keeper is always enabled for all the pads.
28.4.2.2
Output Driver
Output driver characteristics
• Selectable CMOS or open-drain output type
• Selectable pull-keeper enable signal to enable/disable the pull-up/down and output
keeper
• Selectable pull-up resistors of 22K, 47K, 100K and a pull-down resistor of
100KOhm. Unsilicided P+ poly resistor is used to limit resistance variation to within
+/- 20%.
• Pull-up, pull-down, and pad keeper are disabled in output mode.
• Seven drive strengths in each operating mode
• Additional 2-bit slew rate control to select between 50, 100, and 200 MHz IO cell
operation range with reduced switching noise
Vpad
OVSS
OVDD
Output buffer
OVDD
OVSS
Predriver
do
Figure 28-6. Output Driver Functional Diagram
Chapter 28 General Purpose Input/Output (GPIO)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1353

<!-- page 1354 -->

28.4.2.2.1
Drive strength
Drive strength selection can be use to make the impedance matched and get better signal
integrity.
28.4.2.2.2
Output keeper
A simple latch to hold the input value.
OVDD
keeper_n
keeper_p
pad
OVDD
OVDD
PKE = VDD
DO
OBE
measure
Figure 28-7. Keeper functional diagram
28.4.2.2.3
PU / PD / Keeper Logic
When Keeper is enabled, the pull-up and pull-down are disabled, and the output value of
the pad depends on the Keeper. The output keeper is powered by OVDD. When the core
VDD is powered down or the first inverter is tri-stated, the pad’s state can be kept.
Keeper and Pull can’t be enabled together.
28.4.2.2.4
Open drain
Open drain is a circuit technique which allows multiple devices to communication over a
single wire bi-directionally. Open drain drivers usually operate with an external or
internal pull-up resistor that holds the signal line high until a device sinks enough current
to pull the line low, usually used for a bus with multiple devices.
GPIO Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1354
NXP Semiconductors

<!-- page 1355 -->

OVDD1
OVDD2
OVSS1
Rpu
external
Rpu
If internal pull-up resistor (Rpu) is
used, output level will depend on 
OVDD1
If external Rpu is used, output level 
will depend on OVDD2
Figure 28-8. Output buffer in open drain mode
28.4.3
GPIO Programming
28.4.3.1
GPIO Read Mode
The programming sequence for reading input signals should be as follows:
1. Configure IOMUX to select GPIO mode (Via IOMUX Controller (IOMUXC) ).
2. Configure GPIO direction register to input (GPIO_GDIR[GDIR] set to 0b).
3. Read value from data register/pad status register.
A pseudocode description to read [input3:input0] values is as follows:
// SET INPUTS TO GPIO MODE.
write sw_mux_ctl_<input0>_<input1>_<input2>_<input3>, 32'h00000000 
// SET GDIR TO INPUT.
write GDIR[31:4,input3_bit, input2_bit, input1_bit, input0_bit,] 32'hxxxxxxx0 
// READ INPUT VALUE FROM DR.
read DR 
// READ INPUT VALUE FROM PSR.
read PSR 
NOTE
While the GPIO direction is set to input (GPIO_GDIR = 0), a
read access to GPIO_DR does not return GPIO_DR data.
Instead, it returns the GPIO_PSR data, which is the
corresponding input signal value.
Chapter 28 General Purpose Input/Output (GPIO)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1355

<!-- page 1356 -->

28.4.3.2
GPIO Write Mode
The programming sequence for driving output signals should be as follows:
1. Configure IOMUX to select GPIO mode (Via IOMUXC), also enable SION if need
to read loopback pad value through PSR
2. Configure GPIO direction register to output (GPIO_GDIR[GDIR] set to 1b).
3. Write value to data register (GPIO_DR).
A pseudocode description to drive 4'b0101 on [output3:output0] is as follows:
// SET PADS TO GPIO MODE VIA IOMUX. 
write sw_mux_ctl_pad_<output[0-3]>.mux_mode, <GPIO_MUX_MODE>
// Enable loopback so we can capture pad value into PSR in output mode 
write sw_mux_ctl_pad_<output[0-3]>.sion, 1
// SET GDIR=1 TO OUTPUT BITS. 
write GDIR[31:4,output3_bit,output2_bit, output1_bit, output0_bit,] 32'hxxxxxxxF
// WRITE OUTPUT VALUE=4’b0101 TO DR. 
write DR, 32'hxxxxxxx5
// READ OUTPUT VALUE FROM PSR ONLY. 
read_cmp PSR, 32'hxxxxxxx5
28.4.4
Interrupt Control Unit
In addition to the general-purpose input/output function, the edge-detect logic in the
GPIO peripheral reflects whether a transition has occurred on a given GPIO signal that is
configured as an input (GDIR bit = 0). The interrupt control registers (GPIO_ICR1 and
GPIO_ICR2) may be used to independently configure the interrupt condition of each
input signal (low-to-high transition, high-to-low transition, low, or high). For information
about GPIO_ICR1 and GPIO_ICR2 settings, see GPIO Memory Map/Register
Definition.
The interrupt control unit is built of 32 interrupt control subunits, where each subunit
handles a single interrupt line.
28.5
GPIO Memory Map/Register Definition
There are eight 32-bit GPIO registers. All registers are accessible from the IP interface.
Only 32-bit access is supported.
The GPIO memory map is shown in the following table.
GPIO Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1356
NXP Semiconductors

<!-- page 1357 -->

GPIO memory map
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
209_C000
GPIO data register (GPIO1_DR)
32
R/W
0000_0000h
28.5.1/1358
209_C004
GPIO direction register (GPIO1_GDIR)
32
R/W
0000_0000h
28.5.2/1359
209_C008
GPIO pad status register (GPIO1_PSR)
32
R
0000_0000h
28.5.3/1359
209_C00C
GPIO interrupt configuration register1 (GPIO1_ICR1)
32
R/W
0000_0000h
28.5.4/1360
209_C010
GPIO interrupt configuration register2 (GPIO1_ICR2)
32
R/W
0000_0000h
28.5.5/1364
209_C014
GPIO interrupt mask register (GPIO1_IMR)
32
R/W
0000_0000h
28.5.6/1367
209_C018
GPIO interrupt status register (GPIO1_ISR)
32
w1c
0000_0000h
28.5.7/1368
209_C01C
GPIO edge select register (GPIO1_EDGE_SEL)
32
R/W
0000_0000h
28.5.8/1369
20A_0000
GPIO data register (GPIO2_DR)
32
R/W
0000_0000h
28.5.1/1358
20A_0004
GPIO direction register (GPIO2_GDIR)
32
R/W
0000_0000h
28.5.2/1359
20A_0008
GPIO pad status register (GPIO2_PSR)
32
R
0000_0000h
28.5.3/1359
20A_000C
GPIO interrupt configuration register1 (GPIO2_ICR1)
32
R/W
0000_0000h
28.5.4/1360
20A_0010
GPIO interrupt configuration register2 (GPIO2_ICR2)
32
R/W
0000_0000h
28.5.5/1364
20A_0014
GPIO interrupt mask register (GPIO2_IMR)
32
R/W
0000_0000h
28.5.6/1367
20A_0018
GPIO interrupt status register (GPIO2_ISR)
32
w1c
0000_0000h
28.5.7/1368
20A_001C
GPIO edge select register (GPIO2_EDGE_SEL)
32
R/W
0000_0000h
28.5.8/1369
20A_4000
GPIO data register (GPIO3_DR)
32
R/W
0000_0000h
28.5.1/1358
20A_4004
GPIO direction register (GPIO3_GDIR)
32
R/W
0000_0000h
28.5.2/1359
20A_4008
GPIO pad status register (GPIO3_PSR)
32
R
0000_0000h
28.5.3/1359
20A_400C
GPIO interrupt configuration register1 (GPIO3_ICR1)
32
R/W
0000_0000h
28.5.4/1360
20A_4010
GPIO interrupt configuration register2 (GPIO3_ICR2)
32
R/W
0000_0000h
28.5.5/1364
20A_4014
GPIO interrupt mask register (GPIO3_IMR)
32
R/W
0000_0000h
28.5.6/1367
20A_4018
GPIO interrupt status register (GPIO3_ISR)
32
w1c
0000_0000h
28.5.7/1368
20A_401C
GPIO edge select register (GPIO3_EDGE_SEL)
32
R/W
0000_0000h
28.5.8/1369
20A_8000
GPIO data register (GPIO4_DR)
32
R/W
0000_0000h
28.5.1/1358
20A_8004
GPIO direction register (GPIO4_GDIR)
32
R/W
0000_0000h
28.5.2/1359
20A_8008
GPIO pad status register (GPIO4_PSR)
32
R
0000_0000h
28.5.3/1359
20A_800C
GPIO interrupt configuration register1 (GPIO4_ICR1)
32
R/W
0000_0000h
28.5.4/1360
20A_8010
GPIO interrupt configuration register2 (GPIO4_ICR2)
32
R/W
0000_0000h
28.5.5/1364
20A_8014
GPIO interrupt mask register (GPIO4_IMR)
32
R/W
0000_0000h
28.5.6/1367
20A_8018
GPIO interrupt status register (GPIO4_ISR)
32
w1c
0000_0000h
28.5.7/1368
20A_801C
GPIO edge select register (GPIO4_EDGE_SEL)
32
R/W
0000_0000h
28.5.8/1369
20A_C000
GPIO data register (GPIO5_DR)
32
R/W
0000_0000h
28.5.1/1358
20A_C004
GPIO direction register (GPIO5_GDIR)
32
R/W
0000_0000h
28.5.2/1359
20A_C008
GPIO pad status register (GPIO5_PSR)
32
R
0000_0000h
28.5.3/1359
20A_C00C
GPIO interrupt configuration register1 (GPIO5_ICR1)
32
R/W
0000_0000h
28.5.4/1360
20A_C010
GPIO interrupt configuration register2 (GPIO5_ICR2)
32
R/W
0000_0000h
28.5.5/1364
20A_C014
GPIO interrupt mask register (GPIO5_IMR)
32
R/W
0000_0000h
28.5.6/1367
Table continues on the next page...
Chapter 28 General Purpose Input/Output (GPIO)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1357

<!-- page 1358 -->

GPIO memory map (continued)
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
20A_C018
GPIO interrupt status register (GPIO5_ISR)
32
w1c
0000_0000h
28.5.7/1368
20A_C01C
GPIO edge select register (GPIO5_EDGE_SEL)
32
R/W
0000_0000h
28.5.8/1369
28.5.1
GPIO data register (GPIOx_DR)
The 32-bit GPIO_DR register stores data that is ready to be driven to the output lines. If
the IOMUXC is in GPIO mode and a given GPIO direction bit is set, then the
corresponding DR bit is driven to the output. If a given GPIO direction bit is cleared, then
a read of GPIO_DR reflects the value of the corresponding signal.Two wait states are
required in read access for synchronization.
The results of a read of a DR bit depends on the IOMUXC input mode settings and the
corresponding GDIR bit as follows:
• If GDIR[n] is set and IOMUXC input mode is GPIO, then reading DR[n] returns the
contents of DR[n].
• If GDIR[n] is cleared and IOMUXC input mode is GPIO, then reading DR[n] returns
the corresponding input signal's value.
• If GDIR[n] is set and IOMUXC input mode is not GPIO, then reading DR[n] returns
the contents of DR[n].
• If GDIR[n] is cleared and IOMUXC input mode is not GPIO, then reading DR[n]
always returns zero.
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
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
DR
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPIOx_DR field descriptions
Field
Description
DR
Data bits. This register defines the value of the GPIO output when the signal is configured as an output
(GDIR[n]=1). Writes to this register are stored in a register. Reading GPIO_DR returns the value stored in
the register if the signal is configured as an output (GDIR[n]=1), or the input signal's value if configured as
an input (GDIR[n]=0).
NOTE: The I/O multiplexer must be configured to GPIO mode for the GPIO_DR value to connect with the
signal. Reading the data register with the input path disabled always returns a zero value.
GPIO Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1358
NXP Semiconductors

<!-- page 1359 -->

28.5.2
GPIO direction register (GPIOx_GDIR)
GPIO_GDIR functions as direction control when the IOMUXC is in GPIO mode. Each
bit specifies the direction of a one-bit signal. The mapping of each DIR bit to a
corresponding SoC signal is determined by the SoC's pin assignment and the IOMUX
table. For more details consult the IOMUXC chapter.
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
GDIR
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPIOx_GDIR field descriptions
Field
Description
GDIR
GPIO direction bits. Bit n of this register defines the direction of the GPIO[n] signal.
NOTE: GPIO_GDIR affects only the direction of the I/O signal when the corresponding bit in the I/O MUX
is configured for GPIO.
0
INPUT — GPIO is configured as input.
1
OUTPUT — GPIO is configured as output.
28.5.3
GPIO pad status register (GPIOx_PSR)
GPIO_PSR is a read-only register. Each bit stores the value of the corresponding input
signal (as configured in the IOMUX). This register is clocked with the ipg_clk_s clock,
meaning that the input signal is sampled only when accessing this location. Two wait
states are required any time this register is accessed for synchronization.
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
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
PSR
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPIOx_PSR field descriptions
Field
Description
PSR
GPIO pad status bits (status bits). Reading GPIO_PSR returns the state of the corresponding input signal.
Chapter 28 General Purpose Input/Output (GPIO)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1359

<!-- page 1360 -->

GPIOx_PSR field descriptions (continued)
Field
Description
Settings:
NOTE: The IOMUXC must be configured to GPIO mode for GPIO_PSR to reflect the state of the
corresponding signal.
28.5.4
GPIO interrupt configuration register1 (GPIOx_ICR1)
GPIO_ICR1 contains 16 two-bit fields, where each field specifies the interrupt
configuration for a different input signal.
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
ICR15
ICR14
ICR13
ICR12
ICR11
ICR10
ICR9
ICR8
W
Reset
0
0
0
0
0
0
0
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
ICR7
ICR6
ICR5
ICR4
ICR3
ICR2
ICR1
ICR0
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPIOx_ICR1 field descriptions
Field
Description
31–30
ICR15
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 15.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
29–28
ICR14
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 14.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
27–26
ICR13
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 13.
Table continues on the next page...
GPIO Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1360
NXP Semiconductors

<!-- page 1361 -->

GPIOx_ICR1 field descriptions (continued)
Field
Description
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
25–24
ICR12
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 12.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
23–22
ICR11
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 11.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
21–20
ICR10
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 10.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
19–18
ICR9
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 9.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
17–16
ICR8
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 8.
Settings:
Table continues on the next page...
Chapter 28 General Purpose Input/Output (GPIO)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1361

<!-- page 1362 -->

GPIOx_ICR1 field descriptions (continued)
Field
Description
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
15–14
ICR7
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 7.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
13–12
ICR6
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 6.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
11–10
ICR5
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 5.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
9–8
ICR4
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 4.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
7–6
ICR3
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 3.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
Table continues on the next page...
GPIO Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1362
NXP Semiconductors

<!-- page 1363 -->

GPIOx_ICR1 field descriptions (continued)
Field
Description
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
5–4
ICR2
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 2.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
3–2
ICR1
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 1.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
ICR0
Interrupt configuration 1 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 0.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
Chapter 28 General Purpose Input/Output (GPIO)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1363

<!-- page 1364 -->

28.5.5
GPIO interrupt configuration register2 (GPIOx_ICR2)
GPIO_ICR2 contains 16 two-bit fields, where each field specifies the interrupt
configuration for a different input signal.
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
ICR31
ICR30
ICR29
ICR28
ICR27
ICR26
ICR25
ICR24
W
Reset
0
0
0
0
0
0
0
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
ICR23
ICR22
ICR21
ICR20
ICR19
ICR18
ICR17
ICR16
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPIOx_ICR2 field descriptions
Field
Description
31–30
ICR31
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 31.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
29–28
ICR30
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 30.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
27–26
ICR29
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 29.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
Table continues on the next page...
GPIO Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1364
NXP Semiconductors

<!-- page 1365 -->

GPIOx_ICR2 field descriptions (continued)
Field
Description
25–24
ICR28
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 28.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
23–22
ICR27
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 27.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
21–20
ICR26
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 26.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
19–18
ICR25
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 25.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
17–16
ICR24
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 24.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
Table continues on the next page...
Chapter 28 General Purpose Input/Output (GPIO)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1365

<!-- page 1366 -->

GPIOx_ICR2 field descriptions (continued)
Field
Description
15–14
ICR23
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 23.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
13–12
ICR22
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 22.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
11–10
ICR21
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 21.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
9–8
ICR20
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 20.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
7–6
ICR19
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 19.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
Table continues on the next page...
GPIO Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1366
NXP Semiconductors

<!-- page 1367 -->

GPIOx_ICR2 field descriptions (continued)
Field
Description
5–4
ICR18
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 18.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
3–2
ICR17
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 17.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
ICR16
Interrupt configuration 2 fields. This register controls the active condition of the interrupt function for GPIO
interrupt 16.
Settings:
Bits ICRn[1:0] determine the interrupt condition for signal n as follows:
00
LOW_LEVEL — Interrupt n is low-level sensitive.
01
HIGH_LEVEL — Interrupt n is high-level sensitive.
10
RISING_EDGE — Interrupt n is rising-edge sensitive.
11
FALLING_EDGE — Interrupt n is falling-edge sensitive.
28.5.6
GPIO interrupt mask register (GPIOx_IMR)
GPIO_IMR contains masking bits for each interrupt line.
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
IMR
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPIOx_IMR field descriptions
Field
Description
IMR
Interrupt Mask bits. This register is used to enable or disable the interrupt function on each of the 32 GPIO
signals.
Chapter 28 General Purpose Input/Output (GPIO)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1367

<!-- page 1368 -->

GPIOx_IMR field descriptions (continued)
Field
Description
Settings:
Bit IMR[n] (n=0...31) controls interrupt n as follows:
0
MASKED — Interrupt n is disabled.
1
UNMASKED — Interrupt n is enabled.
28.5.7
GPIO interrupt status register (GPIOx_ISR)
The GPIO_ISR functions as an interrupt status indicator. Each bit indicates whether an
interrupt condition has been met for the corresponding input signal. When an interrupt
condition is met (as determined by the corresponding interrupt condition register field),
the corresponding bit in this register is set. Two wait states are required in read access for
synchronization. One wait state is required for reset.
Address: Base address + 18h offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
ISR
W
w1c
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPIOx_ISR field descriptions
Field
Description
ISR
Interrupt status bits - Bit n of this register is asserted (active high) when the active condition (as
determined by the corresponding ICR bit) is detected on the GPIO input and is waiting for service. The
value of this register is independent of the value in GPIO_IMR.
When the active condition has been detected, the corresponding bit remains set until cleared by software.
Status flags are cleared by writing a 1 to the corresponding bit position.
GPIO Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1368
NXP Semiconductors

<!-- page 1369 -->

28.5.8
GPIO edge select register (GPIOx_EDGE_SEL)
GPIO_EDGE_SEL may be used to override the ICR registers' configuration. If the
GPIO_EDGE_SEL bit is set, then a rising edge or falling edge in the corresponding
signal generates an interrupt. This register provides backward compatibility. On reset all
bits are cleared (ICR is not overridden).
Address: Base address + 1Ch offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
GPIO_EDGE_SEL
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPIOx_EDGE_SEL field descriptions
Field
Description
GPIO_EDGE_
SEL
Edge select. When GPIO_EDGE_SEL[n] is set, the GPIO disregards the ICR[n] setting, and detects any
edge on the corresponding input signal.
Chapter 28 General Purpose Input/Output (GPIO)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1369

<!-- page 1370 -->

GPIO Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1370
NXP Semiconductors

