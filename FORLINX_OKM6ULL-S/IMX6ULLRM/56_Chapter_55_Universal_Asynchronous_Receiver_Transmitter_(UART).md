# Chapter 55: Universal Asynchronous Receiver/Transmitter (UART)

> Nguồn: `IMX6ULLRM.pdf` — trang 3561–3640

<!-- page 3561 -->

Chapter 55
Universal Asynchronous Receiver/Transmitter
(UART)
55.1
Overview
Universal Asynchronous Receiver/Transmitter (UART) provides serial communication
capability with external devices through a level converter and an RS-232 cable or through
use of external circuitry that converts infrared signals to electrical signals (for reception)
or transforms electrical signals to signals that drive an infrared LED (for transmission) to
provide low speed IrDA compatibility.
UART supports NRZ encoding format , RS485 compatible 9 bit data format and IrDA-
compatible infrared slow data rate (SIR) format.
The following figure is the UART block diagram.
The "Module Clock" is the UART_CLK which comes from CCM. The "Peripheral
Clock" is the IPG_CLK which comes from CCM.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3561

<!-- page 3562 -->

Peripheral Bus
Interrupts
DMA Req
Peripheral Clock
Module Clock
Clock Gating
& Divider
BRM
Clock Gating
Interrupt &
DMA Requests
Peripheral
Bus
Interface
Rx Block
Control
RxFIFO
Power
Saving
Control
TxFIFO
Power
Saving
Tx Block
brm_clk
ref_clk
DCE / DTE Interface
TX_DATA
RX_DATA
CTS_B
RTS_B
DSR_B
RI_B
DCD_B
DTR_B
Figure 55-1. UART Block Diagram
55.1.1
Features
The UART includes the following features:
• High-speed TIA/EIA-232-F compatible, up to 5.0 Mbit/s
• Serial IR interface low-speed, IrDA-compatible (up to 115.2 Kbit/s)
• 9-bit or Multidrop mode (RS-485) support (automatic slave address detection)
• 7 or 8 data bits for RS-232 characters, or 9 bit RS-485 format
• 1 or 2 stop bits
• Programmable parity (even, odd, and no parity)
• Hardware flow control support for request to send (RTS_B) and clear to send
(CTS_B) signals
• RS-485 driver direction control via CTS_B signal
• Edge-selectable RTS_B and edge-detect interrupts
• Status flags for various flow control and FIFO states
• Voting logic for improved noise immunity (16x oversampling)
• Transmitter FIFO empty interrupt suppression
• UART internal clocks enable/disable
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3562
NXP Semiconductors

<!-- page 3563 -->

• Auto baud rate detection (up to 115.2 Kbit/s)
• Receiver and transmitter enable/disable for power saving
• RX_DATA input and TX_DATA output can be inverted respectively in RS-232/
RS-485 mode
• DCE/DTE capability
• RTS_B, IrDA asynchronous wake (AIRINT), receive asynchronous wake
(AWAKE), RI_B (DTE only), DCD_B (DTE only), DTR_B (DCE only) and DSR_B
(DTE only) interrupts wake the processor from STOP mode
• Maskable interrupts
• Two DMA Requests (TxFIFO DMA Request and RxFIFO DMA Request)
• Escape character sequence detection
• Software reset (SRST_B)
• Two independent, 32-entry FIFOs for transmit and receive
• The peripheral clock can be totally asynchronous with the module clock. The module
clock determines baud rate. This allows frequency scaling on peripheral clock (such
as during DVFS mode) while remaining the module clock frequency and baud rate.
55.1.2
Modes of operation
• Serial RS-232NRZ mode
• 9-bit RS-485 mode
• IrDA mode
To set UART in different modes, see the table below.
Table 55-1. UART mode definition
MDEN
(UMCR[0])
IREN
(UCR1[7])
UART Mode
Descriptioin
0
0
RS-232
RXD/TXD data is serial RS-232 NRZ format
0
1
IrDA (Interface)
RXD/TXD data is IrDA-compatible infrared slow data rate (SIR)
format
1
0
RS-485
RXD/TXD data is RS485 compatible 9 bit data format
1
1
Undefined
Undefined
55.2
External Signals
Tables that lists the conventions for representing signals and describing all UART signals
that connect off-chip can be found here.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3563

<!-- page 3564 -->

The chip-level IOMUX modifies the direction and routing of the UART signals based on
whether the UART is operating in DCE mode (UARTn_UFCR[DCEDTE]=0) or DTE
mode (UARTn_UFCR[DCEDTE]=1). The routing of the external signals to the UART
module is shown in the figure below.
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3564
NXP Semiconductors

<!-- page 3565 -->

TX_DATA
RX_DATA
CTS_B
RTS_B
DSR_B
RI_B
DCD_B
DTR_B
UART 
Module
Signals
Chip
External Signals
UARTn_TX_DATA
UARTn_RX_DATA
UARTn_CTS_B
UARTn_RTS_B
UARTn_DSR_B
UARTn_RI_B
UARTn_DCD_B
UARTn_DTR_B
DCE Mode (UARTn_UFCR[DCEDTE] = 0)
IOMUX
TX_DATA
RX_DATA
CTS_B
RTS_B
DSR_B
RI_B
DCD_B
DTR_B
UART 
Module
Signals
Chip
External Signals
UARTn_TX_DATA
UARTn_RX_DATA
UARTn_CTS_B
UARTn_RTS_B
UARTn_DSR_B
UARTn_RI_B
UARTn_DCD_B
UARTn_DTR_B
DTE Mode (UARTn_UFCR[DCEDTE] = 1)
IOMUX
Figure 55-2. UART external signals to module signals routing with respect to DCE/DTE
mode
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3565

<!-- page 3566 -->

The following tables describes the external signals of UART:
Table 55-2. UART External Signals
Signal
Description
Pad
Mode
Direction
UART1_CTS_B
Clear to send
GPIO1_IO06
ALT8
I
UART1_CTS_B
ALT0
UART1_RTS_B
Request to send
GPIO1_IO07
ALT8
O
UART1_RTS_B
ALT0
UART1_RX_DATA
Serial / infrared data receive
GPIO1_IO03
ALT8
O
UART1_RX_DATA
ALT0
UART1_TX_DATA
Serial / infrared data transmit
GPIO1_IO02
ALT8
I
UART1_TX_DATA
ALT0
UART2_CTS_B
Clear to send
NAND_DATA06
ALT8
I
UART2_CTS_B
ALT0
UART3_TX_DATA
ALT4
UART2_RTS_B
Request to send
NAND_DATA07
ALT8
O
UART2_RTS_B
ALT0
UART3_RX_DATA
ALT4
UART2_RX_DATA
Serial / infrared data receive
NAND_DATA05
ALT8
O
UART2_RX_DATA
ALT0
UART2_TX_DATA
Serial / infrared data transmit
NAND_DATA04
ALT8
I
UART2_TX_DATA
ALT0
UART3_CTS_B
Clear to send
NAND_CE1_B
ALT8
I
UART3_CTS_B
ALT0
UART3_RTS_B
Request to send
NAND_CLE
ALT8
O
UART3_RTS_B
ALT0
UART3_RX_DATA
Serial / infrared data receive
NAND_CE0_B
ALT8
O
UART3_RX_DATA
ALT0
UART3_TX_DATA
Serial / infrared data transmit
NAND_READY_B
ALT8
I
UART3_TX_DATA
ALT0
UART4_CTS_B
Clear to send
ENET1_RX_DATA1
ALT1
I
LCD_HSYNC
ALT2
UART4_RTS_B
Request to send
ENET1_RX_DATA0
ALT1
O
LCD_VSYNC
ALT2
UART4_RX_DATA
Serial / infrared data receive
LCD_ENABLE
ALT2
O
UART4_RX_DATA
ALT0
UART4_TX_DATA
Serial / infrared data transmit
LCD_CLK
ALT2
I
UART4_TX_DATA
ALT0
UART5_CTS_B
Clear to send
CSI_DATA03
ALT8
I
ENET1_TX_DATA0
ALT1
GPIO1_IO09
ALT8
UART5_RTS_B
Request to send
CSI_DATA02
ALT8
O
Table continues on the next page...
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3566
NXP Semiconductors

<!-- page 3567 -->

Table 55-2. UART External Signals (continued)
Signal
Description
Pad
Mode
Direction
ENET1_RX_EN
ALT1
GPIO1_IO08
ALT8
UART5_RX_DATA
Serial / infrared data receive
CSI_DATA01
ALT8
O
GPIO1_IO05
ALT8
UART5_RX_DATA
ALT0
UART5_TX_DATA
Serial / infrared data transmit
CSI_DATA00
ALT8
I
GPIO1_IO04
ALT8
UART5_TX_DATA
ALT0
UART6_CTS_B
Clear to send
CSI_HSYNC
ALT8
I
ENET1_TX_DATA1
ALT1
UART6_RTS_B
Request to send
CSI_VSYNC
ALT8
O
ENET1_TX_EN
ALT1
UART6_RX_DATA
Serial / infrared data receive
CSI_PIXCLK
ALT8
O
ENET2_RX_DATA1
ALT1
UART6_TX_DATA
Serial / infrared data transmit
CSI_MCLK
ALT8
I
ENET2_RX_DATA0
ALT1
UART7_CTS_B
Clear to send
ENET1_TX_CLK
ALT1
I
LCD_DATA06
ALT1
UART7_RTS_B
Request to send
ENET1_RX_ER
ALT1
O
LCD_DATA07
ALT1
UART7_RX_DATA
Serial / infrared data receive
ENET2_TX_DATA0
ALT1
O
LCD_DATA17
ALT1
UART7_TX_DATA
Serial / infrared data transmit
ENET2_RX_EN
ALT1
I
LCD_DATA16
ALT1
UART8_CTS_B
Clear to send
ENET2_TX_CLK
ALT1
I
LCD_DATA04
ALT1
UART8_RTS_B
Request to send
ENET2_RX_ER
ALT1
O
LCD_DATA05
ALT1
UART8_RX_DATA
Serial / infrared data receive
ENET2_TX_EN
ALT1
O
LCD_DATA21
ALT1
UART8_TX_DATA
Serial / infrared data transmit
ENET2_TX_DATA1
ALT1
I
LCD_DATA20
ALT1
The user must configure the input path to the UART by properly configuring the DAISY
bits in the IOMUXC_UARTn_RX_DATA_INPUT and the
IOMUXC_UARTn_UART_RTS_B_SELECT_INPUT registers.
For IOMUXC_UARTn_UART_RTS_B_SELECT_INPUT[DAISY]:
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3567

<!-- page 3568 -->

• Configurations that select UARTn_RTS_B for the pad are only valid when
UARTn_UFCR[DCEDTE]=0 (DCE mode)
• Configurations that select UARTn_CTS_B for the pad are only valid when
UARTn_UFCR[DCEDTE]=1 (DTE mode)
For IOMUXC_UARTn_UART_RX_DATA_B_SELECT_INPUT[DAISY]:
• Configurations that select UARTn_RX_DATA for the pad are only valid when
UARTn_UFCR[DCEDTE]=0 (DCE mode)
• Configurations that select UARTn_TX_DATA for the pad are only valid when
UARTn_UFCR[DCEDTE]=1 (DTE mode)
55.2.1
Detailed Signal Descriptions
55.2.1.1
Interrupt Signals
55.2.1.1.1
interrupt_uart - UART Interrupt
Output interrupt request.
55.2.1.2
DMA Request Signals
55.2.1.2.1
dma_req_rx - Receiver DMA Request
Output DMA Request signal for receiver interface.
55.2.1.2.2
dma_req_tx - Transmitter DMA Request
Output DMA Request signal for transmitter interface. Set at 0 when TXDMAEN
(UCR1[3]) is at 1 and TRDY (USR1[13]) is also at 1.
55.2.1.3
Special Signals
55.2.1.3.1
stop_req - Stop Mode
Input stop mode. Indicates to UART that Arm platform is going to enter in Stop Mode
and clocks are going to stop running.
See Low Power Modes for more information about Stop Mode.
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3568
NXP Semiconductors

<!-- page 3569 -->

55.2.1.3.2
doze_req - Doze Mode
Input doze mode. Arm platform requests UART to switch in doze mode (power saving
mode).
See Low Power Modes for more information about Doze Mode.
55.2.1.3.3
debug_req - Debug Mode
Input debug mode. Indicates UART it has to enter in debug mode.
See UART Operation in System Debug State, for more information about Debug Mode.
55.3
Clocks
The table found here describes the clock sources for UART.
Please see Clock Controller Module (CCM) for clock setting, configuration and gating
information.
Table 55-3. UART Clocks
Clock name
Clock Root
Description
ipg_clk
ipg_clk_root
Peripheral clock
ipg_clk_s
ipg_clk_root
Peripheral access clock
ipg_perclk
uart_clk_root
Module clock
55.4
Functional Description
This section provides a complete functional description of the block.
55.4.1
Interrupts and DMA Requests
See the following table for the lists of all interrupt and DMA signals and associated
interrupt and DMA sources of the UART. See register description section for explanation
of interrupt/DMA enable and status.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3569

<!-- page 3570 -->

Table 55-4. Interrupts and DMA
Interrupt/DMA Output
Interrupt/DMA
Enable
Enable Register
Location
Interrupt/DMA
Flag
Flag Register
Location
interrupt_uart
RRDYEN
IDEN
DREN
RXDSEN
ATEN
UCR1 (bit 9)
UCR1 (bit 12)
UCR4 (bit 0)
UCR3 (bit 6)
UCR2 (bit 3)
RRDY
IDLE
RDR
RXDS
AGTIM
USR1 (bit 9)
USR2 (bit 12)
USR2 (bit 0)
USR1 (bit 6)
USR1 (bit 8)
interrupt_uart
TXMPTYEN
TRDYEN
TCEN
UCR1 (bit 6)
UCR1 (bit 13)
UCR4 (bit 3)
TXFE
TRDY
TXDC
USR2 (bit 14)
USR1 (bit 13)
USR2 (bit 3)
interrupt_uart
OREN
BKEN
WKEN
ADEN
ACIEN
ESCI
ENIRI
AIRINTEN
AWAKEN
FRAERREN
PARERREN
RTSDEN
RTSEN
DTREN (DCE)
RI (DTE)
DCD (DTE)
DTRDEN
SADEN
UCR4 (bit 1)
UCR4 (bit 2)
UCR4 (bit 7)
UCR1 (bit 15)
UCR3 (bit 0)
UCR2 (bit 15)
UCR4 (bit 8)
UCR3 (bit 5)
UCR3 (bit 4)
UCR3 (bit 11)
UCR3 (bit 12)
UCR1 (bit 5)
UCR2 (bit 4)
UCR3 (bit 13)
UCR3 (bit 8)
UCR3 (bit 9)
UCR3 (bit 3)
UMCR (bit 3)
ORE
BRCD
WAKE
ADET
ACST
ESCF
IRINT
AIRINT
AWAKE
FRAERR
PARITYERR
RTSD
RTSF
DTRF
RIDELT
DCDDELT
DTRD
SAD
USR2 (bit 1)
USR2 (bit 2)
USR2 (bit 7)
USR2 (bit 15)
USR2 (bit 11)
USR1 (bit 11)
USR2 (bit 8)
USR1 (bit 5)
USR1 (bit 4)
USR1 (bit 10)
USR1 (bit 15)
USR1 (bit 12)
USR2 (bit 4)
USR2 (bit 13)
USR2 (bit 10)
USR2 (bit 6)
USR1 (bit 7)
USR1 (bit 3)
dma_req_rx
RXDMAEN
ATDMAEN
IDDMAEN
UCR1 (bit 8)
UCR1 (bit 2)
UCR4 (bit 6)
RRDY
AGTIM
IDLE
USR1 (bit 9)
USR1 (bit 8)
USR2 (bit 12)
dma_req_tx
TXDMAEN
UCR1 (bit 3)
TRDY
USR1 (bit 13)
55.4.2
Clocks
This section describes clocks and special clocking requirements of the UART.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3570
NXP Semiconductors

<!-- page 3571 -->

55.4.2.1
Clock requirements
UART module receives 2 clocks, peripheral_clock and module_clock. The
peripheral_clock is used as write clock of the TxFIFO, read clock of the RxFIFO and
synchronization of the modem control input pins. It must always be running when UART
is enabled. There is an exception in stop mode (see Clocking in Low-Power Modes).
The module_clock is for all the state machines, writing RxFIFO, reading TxFIFO, etc. It
must always be running when UART is sending or receiving characters.This clock is used
in order to allow frequency scaling on peripheral_clock without changing configuration
of baud rate (module_clock staying at a fixed frequency).
The constraints on peripheral_clock and module_clock are as follows:
• peripheral_clock and module_clock can totally be asynchronous. They can also be
synchronous.
• Due to the 16x oversampling of the incoming characters, module_clock frequency
must always be greater or equal to 16x the maximum baud rate. For example, if max
baud rate is 4 Mbit/s, module_clock must be greater or equal to 4 M x 16 = 64 MHz.
NOTE
The restriction that peripheral_clock frequency must be higher
or equal to 16x baud rate has been removed. There is no
limitation on peripheral_clock frequency to baud rate.
55.4.2.2
Maximum Baud Rate
The max baud rate the UART can support is determined by the max frequency of the
module_clock.
For example, if the SoC can provide the fastest module_clock 66.5 MHz, the UART can
transmit and receive serial data with the maximum baud rate 66.5M/16 = 4.15 Mbit/s.
The UART supports serial IR interface low speed. In the low speed IrDA mode, the max
baud rate is 115.2 Kbit/s. To support the 115.2 Kbit/s, module_clock frequency must be
higher or equal to 1.8432 MHz.
55.4.2.3
Clocking in Low-Power Modes
The UART supports 2 low-power modes: DOZE and STOP.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3571

<!-- page 3572 -->

In STOP mode (input pin stop_req is at '1'), the UART doesn't need any clock. In this
mode the UART can wake-up the Arm platform with the asynchronous interrupts (see
Low Power Modes).
• If before entering in STOP mode the software has enabled RTSDEN interrupt, when
RTS will change state (put at '0' by external device started to send), the asynchronous
interrupt will wake-up the system, peripheral_clock and module_clock will be
provided to the UART before first start bit, so that no data will be lost.
• If RTS doesn't change state (already at '0' before entering in STOP mode), then
wake-up interrupt (AWAKE) will be sent at the arrival of first Start bit (on falling
edge). In this case, the UART must receive the peripheral_clock and module_clock
during the first half of start bit to correctly receive this character (for example, at
115.2 Kbit/s, UART must receive peripheral_clock and module_clock at maximum
4.3 microseconds after falling edge of Start bit). If the UART receives
peripheral_clock and module_clock too late, first character will be lost, and so should
be dropped. Also, if autobaud detection is enabled, the first character won't be
correctly received and another autobaud detection will need to be initiated.
In Doze mode, UART behavior is programmable through DOZE bit (UCR1[1]). If DOZE
bit is set to '1', then UART is disabled in Doze mode, and in consequence, UART clocks
can be switched-off (after being sure UART is not transmitting nor receiving). On the
contrary, if DOZE bit is set to '0', UART is enabled and it must receive peripheral_clock
and module_clock .
55.4.3
General UART Definitions
Definitions of terms that occurs the following discussions are given in this section.
• Bit Time-The period of time required to serially transmit or receive 1 bit of data (1
cycle of the baud rate frequency).
• Start bit-The bit time of a logic 0 that indicates the beginning of a data frame. A start
bit begins with a 1-to-0 transition, and is preceded by at least 1 bit time of logic 1.
• Stop bit-1 bit time of logic 1 that indicates the end of a data frame.
• BREAK-A frame in which all of the data bits, including the stop bit, are logic 0. This
type of frame is usually sent to signal the end of a message or the beginning of a new
message.
• Mark - When no data is being sent, the serial port's transmit pin's voltage is 1 and is
said to be in a MARK state.
• Space - The serial port can also be forced to keep the transmit pin at a 0 and is said to
be the SPACE or BREAK state.
• Frame-A start bit followed by a specified number of data or information bits and
terminated by a stop bit. The number of data or information bits depends on the
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3572
NXP Semiconductors

<!-- page 3573 -->

format specified and must be the same for the transmitting device and the receiving
device. The most common frame format is 1 start bit followed by 8 data bits (least
significant bit first) and terminated by 1 stop bit. An additional stop bit and a parity
bit also can be included.
• Framing Error-An error condition that occurs when the stop bit of a received frame is
missing, usually when the frame boundaries in the received bit stream are not
synchronized with the receiver bit counter. Framing errors can go undetected if a data
bit in the expected stop bit time happens to be a logic 1. A framing error is always
present on the receiver side when the transmitter is sending BREAKs. However,
when the UART is programmed to expect 2 stop bits and only the first stop bit is
received, this is not a framing error by definition.
• Parity Error-An error condition that occurs when the calculated parity of the received
data bits in a frame does not match the parity bit received on the RX_DATA input.
Parity error is calculated only after an entire frame is received.
• Idle-One in NRZ encoding format and selectable polarity in IrDA mode.
• Overrun Error-An error condition that occurs when the latest character received is
ignored to prevent overwriting a character already present in the UART receive
buffer (RxFIFO). An overrun error indicates that the software reading the buffer
(RxFIFO) is not keeping up with the actual reception of characters on the RX_DATA
input.
55.4.3.1
RTS_B - UART Request To Send
The UART Request To Send input controls the transmitter. The modem or other terminal
equipment signals the UART when it is ready to receive by setting '0' on the RTS_B pin.
Normally, the transmitter waits until this signal is active (low) before transmitting a
character, however when the Ignore RTS (IRTS) bit is set, the transmitter sends a
character as soon as it is ready to transmit. An interrupt (RTSD) can be posted on any
transition of this pin and can wake the Arm platform from STOP mode on its assertion.
When RTS_B is set to '1' during a transmission, the UART transmitter finishes
transmitting the current character and shuts off. The contents of the TxFIFO (characters
to be transmitted) remain undisturbed. The operation of this input is the same regardless
of whether the UART is in DTE or DCE mode.
55.4.3.2
RTS Edge Triggered Interrupt
The input to the RTS_B pin can be programmed to generate an interrupt on a selectable
edge.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3573

<!-- page 3574 -->

See the table below for summary of the operation of the RTS edge triggered interrupt
(RTSF).
To enable the RTS_B pin to generate an interrupt, set the request to send interrupt enable
(RTSEN) bit (UCR2[4]) to 1. Writing 1 to the RTS_B edge triggered interrupt flag
(RTSF) bit (USR2[4]) clears the interrupt flag. The interrupt can occur on the rising edge,
falling edge, or either edge of the RTS_B input. The request to send edge control (RTEC)
field (UCR2[10:9]) programs the edge that generates the interrupt. When RTEC is set to
0x00 and RTSEN = 1, the interrupt occurs on the rising edge (default). When RTEC is
set to 0x01 and RTSEN = 1, the interrupt occurs on the falling edge. When RTEC is set
to 0x1X and RTSEN = 1, the interrupt occurs on either edge. This is a synchronous
interrupt. The RTSF bit is cleared by writing 1 to it. Writing 0 to RTSF has no effect.
Table 55-5. RTS_B Edge Triggered Interrupt Truth Table
RTS_B
RTSEN
RTEC [1]
RTEC [0]
RTSF
Interrupt Occurs On…
interrupt_uart
X
0
X
X
0
Interrupt disabled
1
1->0
1
0
0
0
Rising edge
1
0->1
1
0
0
1
Rising edge
0
1->0
1
0
1
1
Falling edge
0
0->1
1
0
1
0
Falling edge
1
1->0
1
1
X
1
Either edge
0
0->1
1
1
X
1
Either edge
0
There is another RTS_B interrupt that is not programmable. The status bit RTSD asserts
the interrupt_uart interrupt when the RTS_B delta interrupt enable = 1. This is an
asynchronous interrupt. The RTSD bit is cleared by writing 1 to it. Writing 0 to the
RTSD bit has no effect.
55.4.3.3
DTR_B - Data Terminal Ready
This signal indicates the general readiness of the Data Terminal Equipment (DTE). This
signal is an input in DCE mode and an output in DTE mode. If the connection between
the DCE and the DTE is established once, the DTR_B signal must remain active
throughout the whole connection time.
In general the DTR_B and DSR_B signals are responsible for establishing the
connection. RTS_B and CTS_B are responsible for the data transfer and the transfer
direction in the case of a half-duplex configuration. The DTR_B signal is like a "main
switch". If the DTR_B signal is inactive the RTS_B and CTS_B signals have no effect. In
DCE mode, an interrupt (DTRD) can be posted on any transition of this pin and can wake
the ARM platform from STOP mode on its assertion.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3574
NXP Semiconductors

<!-- page 3575 -->

55.4.3.4
DSR_B - Data Set Ready
This signal indicates the general readiness of the DCE. This signal is an output in DCE
mode and an input in DTE mode. The DCE uses this signal to inform the DTE that it is
switched on, has completed all preparations and can communicate with the DTE.
In DTE mode, an interrupt (DTRD) can be posted on any transition of this pin and can
wake the ARM platform from STOP mode on its assertion.
55.4.3.5
DTR_B/DSR_B Edge Triggered Interrupt
The DTR_B input pin (DCE mode) or DSR_B input pin (DTE mode) can be configured
to cause an interrupt on a selectable edge.
See the table below for summary of the operation of the DTR/DSR edge triggered
interrupt. To enable the interrupt, set the DTREN bit (UCR3[13]) to '1'. Write a "one" to
the DTRF bit (USR2[13]) to clear the interrupt flag.
The interrupt can be configured to occur on either the rising, falling, or either edge of the
DTR_B/DSR_B input. Write to the DPEC[1:0] bits (UCR3[15:14]) to program which
edge will cause an interrupt. If the bits are set to 00b and DTREN = 1, the interrupt will
occur on the rising edge (default). If the bits are set to 01b and DTREN = 1, the interrupt
will occur on the falling edge. If the bits are set to 1Xb and DTREN = 1, the interrupt will
occur on either edge.
Table 55-6. DTR/DSR_B Edge Triggered Interrupt Truth Table
DTR_B
/
DSR_B
DTREN
DPEC[1]
DPEC[0]
DTRF
Interrupt occurs on:
interrupt_uart
X
0
X
X
0
turned off
1
1->0
1
0
0
0
rising edge
1
0->1
1
0
0
1
rising edge
0
1->0
1
0
1
1
falling edge
0
0->1
1
0
1
0
falling edge
1
1->0
1
1
X
1
either edge
0
0->1
1
1
X
1
either edge
0
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3575

<!-- page 3576 -->

55.4.3.6
DCD_B - Data Carrier Detect
This signal is an output in DCE mode and an input in DTE mode. If used, the DCE
device uses this signal to inform the DTE it has detected the carrier signal and the
connection will be set up. This signal remains active while the connection remains
established.
In DTE mode this input can trigger an interrupt on changing state. This is achieved by
setting to '1' the interrupt enable bit (DCD, UCR3[9]). The change state is reflected in
DCDDELT (USR2[6]). Also, the state of the Data Carrier Detect input is mirrored in the
status register DCDIN (USR2[5]).
55.4.3.7
RI_B - Ring Indicator
This signal is an output in DCE mode and an input in DTE mode. If used, the DCE
device uses this signal to inform the DTE that a ring just occurred.
In DTE mode this input can trigger an interrupt on changing state. This is achieved by
setting to '1' the interrupt enable bit (RI, UCR3[8]). The change state is reflected in
RIDELT (USR2[10]). Also, the state of the Ring Indicator input is mirrored in the status
register RIIN (USR2[9]).
55.4.3.8
CTS_B - Clear To Send
This output pin serves two purposes. Normally, the receiver indicates that it is ready to
receive data by asserting this pin (low). When the CTS_B trigger level is programmed to
trigger at 32 characters received and the receiver detects the valid start bit of the 33
character, it de-asserts this pin. The operation of this output is the same regardless of
whether the UART is in DTE or DCE mode.
55.4.3.9
Programmable CTS_B Deassertion
The CTS_B output can also be programmed to deassert when the RxFIFO reaches a
certain level. Setting the CTS trigger level (UCR4[15:10]) at any value less than 32
deasserts the CTS_B pin on detection of the valid start bit of the N + 1 character (where
N is the trigger level setting). However, the receiver continues to receive characters until
the RxFIFO is full.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3576
NXP Semiconductors

<!-- page 3577 -->

55.4.3.10
TX_DATA - UART Transmit
This is the transmitter serial output. When operating in RS-232/RS-485 mode, NRZ
encoded data is transmitted, and the data can be inverted (controlled by INVT
(UCR3[1])) before transmitted. When operating in infrared mode, a 3/16 bit-period pulse
is output for each 0 bit transmitted, and no pulse is output for each 1 bit transmitted.
For RS-232/RS-485 applications, this pin must be connected to an RS-232/RS-485
transmitter. The operation of this output is the same regardless of whether the UART is in
DTE or DCE mode. See Figure 55-3.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3577

<!-- page 3578 -->

55.4.3.11
RX_DATA - UART Receive
This is the receiver serial input. When operating in RS-232/RS-485 mode, NRZ encoded
data is expected, and the data can be inverted (controlled by INVR (UCR4[9])) before
sampled. When operating in infrared mode, a narrow pulse is expected for each 0 bit
received and no pulse is expected for each 1 bit received.
External circuitry must convert the IR signal to an electrical signal. RS-232/RS-485
applications require an external RS-232/RS-485 receiver to convert voltage levels. The
operation of this input is the same regardless of whether the UART is in DTE or DCE
mode. See the figure below.
-15- -16- -1-
-2-
-3-
-4-
-5-
-6-
-7-
-8-
-9- -10- -11- -12- -13- -14- -15- -16- -1-
-2-
-3-
BIT 0
Bit 1
Bit 2
UBIR = 0, UBMR =1 -> Ratio = 0.5 = 1/2
Bit 0
Bit 1
Bit 2
Bit 3
Bit 4
Bit 5
Bit 6
Bit 7
Start
Bit
STOP
Bit
Next
Start
Bit
Standard
Data
8-Bit Data Format
Possible
Parity
Bit
RXD / TXD
Receiver
Data Path
RxFIFO
Transmitter
Data Path
TxFIFO
Peripheral bus Interface
DCE/DTE Interface
Binary Rate
Multiplier
(BRM)
Programmable
Divider
UFCR:RFDIV[2:0]
ref_clk
peripheral_clock
module_clock
TX_DATA
RX_DATA
RTS_B
CTS_B
To Auto
Baud
brm_clk
Data
Control
ref_clk
brm_clk
Bit Stream
Figure 55-3. UART Simplified Block and Clock Generation Diagrams
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3578
NXP Semiconductors

<!-- page 3579 -->

55.4.4
Transmitter
The transmitter accepts a parallel character from the Arm platform and transmits it
serially. The start, stop, and parity (when enabled) bits are added to the character.
When the ignore RTS bit (IRTS) is set, the transmitter sends a character as soon as it is
ready to transmit. RTS_B can be used to provide flow-control of the serial data. When
RTS_B is set to '1', the transmitter finishes sending the character in progress (if any),
stops, and waits for RTS_B to be set to '0' again. Generation of BREAK characters and
parity errors (for debugging purposes) is supported. The transmitter operates from the
clock provided by the Binary Rate Multiplier(BRM). Normal NRZ encoded data is
transmitted when the IR interface is disabled.
The transmitter FIFO (TxFIFO) contains 32 bytes. The data is written to TxFIFO by
writing to the UTXD register with the byte data to the [7:0] bits. The data is written
consecutively if the TxFIFO is not full. It is read (internally) consecutively if the TxFIFO
is not empty. TXFULL bit (UTS[4]) can be used to control whether TXFIFO is full or
not. The TxFIFO can be written regardless of the transmitter is disabled or enabled. If the
UART is disabled, user can still write data into the TxFIFO correctly. But in this case the
write access will yield to a transfer error.
55.4.4.1
Transmitter FIFO Empty Interrupt Suppression
The transmitter FIFO empty interrupt suppression logic suppresses the TXFE interrupt
between writes to the TxFIFO.
When TxFIFO is empty, the software can either send one or several characters. If the
software sends one character, it would write the character into the UTXD register, then
that character is immediately transferred to the transmitter shift register, assuming the
transmitter is already enabled. Without interrupt suppression logic, the TXFE interrupt
flag would be set immediately. But, with this logic, the interrupt flag is set when the last
bit of the character has been transmitted, for example, before the transmission of the
parity bit (if exists) and the stop bit(s).
So, the suppression logic doesn't immediately send the TXFE interrupt flag. It allows the
software to write another character to the TxFIFO before the interrupt flag is asserted.
When the transmitter shift register empties before another character is written to the
TxFIFO, the interrupt flag is asserted. Writing data to the TxFIFO would release the
interrupt flag. The interrupt flag is asserted on the following conditions:
• System Reset
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3579

<!-- page 3580 -->

• UART software reset
• When a single character has been written to Transmitter FIFO and then the
Transmitter FIFO and the Transmitter Shift Register become empty until another
character is written to the Transmitter FIFO
• The last character in the TxFIFO is transferred to the shift register, when TxFIFO
contains two or more characters. See the figure below.
Assert
Transmitter
FIFO Empty
Flag
Transmitter
FIFO
Empty
Deassert
Transmitter
FIFO Empty
Flag
Transmitter
FIFO
Empty
Deassert
Transmitter
FIFO Empty
Flag
Deassert
Transmitter
FIFO Empty
Flag
Transmitter
Shift Register
Empty
Deassert
Transmitter
FIFO Empty
Flag
Transmitter
FIFO
Empty
Transmitter
FIFO Contains ≥ 2
Characters
N
Y
N
N
Y
Y
Y
N
N
Reset
Reset
Y
Reset
Reset
Figure 55-4. Transmitter FIFO Empty Interrupt Suppression Flow Chart
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3580
NXP Semiconductors

<!-- page 3581 -->

55.4.4.2
Transmitting a Break Condition
Asserting SNDBRK bit of the UCR1 Register forces the transmitter to send a break
character (continuous zeros). The transmitter will finish sending the character in progress
(if any) before sending break until this bit is reset.
The user is responsible to ensure that this bit is high for long enough to generate a valid
BREAK. The transmitter samples SNDBRK after every bit is transmitted. Following
completion of the BREAK transmission, the UART will transmit two mark bits. The user
can continue to fill the FIFO and any character remaining will be transmitted when the
break is terminated.
55.4.5
Receiver
See the figure below for the receiver flow chart.
The receiver accepts a serial data stream and converts it into parallel characters. When
enabled, it searches for a start bit, qualifies it, and samples the following data bits at the
bit-center.
Jitter tolerance and noise immunity are provided by sampling at a 16x rate and using
voting techniques to clean up the samples. Once the start bit is found, the data bits, parity
bit (if enabled), and stop bits (either 1 or 2 depending on user selection) are shifted in.
Parity is checked and its status reported in the URXD register when parity is enabled.
Frame errors and BREAKs are also checked and reported. When a new character is ready
to be read by the Arm platform from the RxFIFO, the receive data ready (RDR =
USR2[0]) bit is asserted and an interrupt is posted (if DREN = UCR4[0] = 1). If the
receiver trigger level is set to 2 (RXTL[5:0] = UFCR[5:0] = 2), and 2 chars have been
received into RxFIFO, the receiver ready interrupt flag (RRDY = USR1[9]) is asserted
and an interrupt is posted if the receiver ready interrupt enable bit is set (RRDYEN =
UCR1[9] = 1). If the UART Receiver Register (URXD) is read once, and in consequence
there is only 1 character in the RxFIFO, the interrupt generated by the RDR bit is
automatically cleared. The RRDY bit is cleared when the data in the RxFIFO falls below
the programmed trigger level.
Normal NRZ encoded data is expected when the IR interface is disabled. The RxFIFO
contains 32 half-word entries. Characters received are written consecutively into this
FIFO. If the FIFO is full and a 33rd characters is received, this character will be ignored
and the USR2[ORE] bit will be set.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3581

<!-- page 3582 -->

Already 31
chars into
RX_FIFO
Receiver State
Machine
Valid char
RXFIFO
full
Set ERR and
OVRRUN
(URXD[14:13])
to 1
Write char
into RX-FIFO
Reset Receiver
State Machine
Set ORE
(USR2[1]) to 1
No
Yes
No
Yes
No
Yes
Figure 55-5. Receiver Flow Chart
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3582
NXP Semiconductors

<!-- page 3583 -->

55.4.5.1
Idle Line Detect
The receiver logic block includes the ability to detect an idle line. Idle lines indicate the
end or the beginning of a message.
For an idle condition to occur:
• RxFIFO must be empty and
• RX_DATA pin must be idle for more than a configured number of frames (ICD[1:0]
= UCR1[11:10]).
When the idle condition detected interrupt enable (IDEN = UCR1[12]) is set and the line
is idle for 4 (default), 8, 16, or 32 (maximum) frames, the detection of an idle condition
flags an interrupt (see the table below). When an idle condition is detected, the IDLE
(USR2[12]) bit is set. Clear the IDLE bit by writing 1 to it. Writing 0 to the IDLE bit has
no effect.
Table 55-7. Detection Truth Table
IDEN
ICD [1]
ICD [0]
IDLE
interrupt_uart
0
X
X
0
1
1
0
0
asserted after 4 idle frames
asserted after 4 idle frames
1
0
1
asserted after 8 idle frames
asserted after 8 idle frames
1
1
0
asserted after 16 idle frames
asserted after 16 idle frames
1
1
1
asserted after 32 idle frames
asserted after 32 idle frames
NOTE: This table assumes that no other interrupt is set at the same time this interrupt is set for the interrupt_uart signal.
This table shows how this interrupt affects the interrupt_uart signal.
During a normal message there is no idle time between frames. When all of the
information bits in a frame are logic 1s, the start bit ensures that at least one logic 0 bit
time occurs for each frame so that the IDLE bit is not asserted.
55.4.5.2
Aging Character Detect
The receiver block also includes the possibility to detect when at least one character has
been sitting into the RxFIFO for a time corresponding to 8 characters. This aging
character capability allows the UART to inform the Arm platform that there is less
character into the RxFIFO than the Rx trigger and, no new character has been detected on
the RXD line.
The aging capability is a timer which starts to count as soon as the RxFIFO is not empty
and its trigger level is not reached (RRDY=0). This counter is reset when either a
RxFIFO read is performed or another character starts to present on the RXD line. If none
of those two events occurs, the bit AGTIM (USR1[8]) is set when the counter has
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3583

<!-- page 3584 -->

measured a time corresponding to 8 characters. AGTIM is cleared by writing a 1 to it.
AGTIM can flag an interrupt to Arm platform on interrupt_uart if ATEN (UCR2[3]) has
been set.
To summarize, AGTIM is set when:
• There is at least one character into RxFIFO.
• No read has occurred on RxFIFO and RXD line has stayed high, for a time
corresponding to 8 characters.
• The RxFIFO trigger is not reached (RRDY=0)
55.4.5.3
Receiver Wake
The WAKE bit (USR2[7]) is set when the receiver detects a qualified Start bit. For this,
two conditions must be fulfilled, firstly a falling edge on RX_DATA line must be
detected and secondly the RX_DATA line must stays at low level for more than a half-bit
duration.
When the wake interrupt enable WKEN (UCR4[7]) bit is enabled, the receiver flags an
interrupt ( interrupt_uart) if the WAKE status bit is set. The WAKE bit is cleared by
writing 1 to it. Writing 0 to the WAKE bit has no effect. The WAKE status bit can be
asserted in either serial RS-232 mode or IR mode. The generation of the WAKE interrupt
needs the clock module_clock .
When the asynchronous wake interrupt (AWAKE) is enabled (AWAKEN = UCR3[4] =
1), and the Arm platform is in STOP mode, and UART clocks have been shut-off, then a
falling edge detected on the receive pin (RX_DATA) asserts the AWAKE bit (USR1[4])
and the interrupt_uart interrupt to wake the Arm platform from STOP mode. Re-enable
UART clocks and clear the AWAKE bit by writing 1 to it. Writing 0 to the AWAKE bit
has no effect. When IR interface is enabled (UCR1[7]=1), the AWAKE bit is always not
asserted. The generation of the asynchronous AWAKE interrupt does not need any
clocks.
In IR mode, if the asynchronous IR WAKE interrupt is enabled (AIRINTEN = UCR3[5]
= 1), and if the Arm platform is in STOP mode (UART clocks are off when Arm
platform in STOP mode), then the detection of a falling edge on the receive pin
(RXD_IR), asserts the AIRINT bit (USR1[5]), and the interrupt_uart interrupt. This
interrupt wakes the Arm platform from STOP mode. Software re-enables UART clocks
and clear the AIRINT bit by writing 1 to it. Writing 0 to the AIRINT bit has no effect.
When IR interface is disabled (UCR1[7]=0), the AIRINT bit is always not asserted. The
generation of the asynchronous AIRINT interrupt does not need any clocks.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3584
NXP Semiconductors

<!-- page 3585 -->

Recommended procedure for programming the asynchronous interrupts is to first clear
them by writing 1 to the appropriate bit in the UART Status Register 1 (USR1). Poll or
enable the interrupt for the Receiver IDLE Interrupt Flag (RXDS) in the USR1. When
asserted, the RXDS bit indicates to the software that the receiver state machine is in the
idle state, the next state is idle, and the RX_DATA pin is idle (high). After following this
procedure, enable the asynchronous interrupt and enter STOP mode.
55.4.5.4
Receiving a BREAK Condition
A BREAK condition is received when the receiver detects all 0s (including a 0 during the
bit time of the stop bit) in a frame. The BREAK condition asserts the BRCD bit
(USR2[2]) and writes only the first BREAK character to the RxFIFO. Clear the BRCD
bit by writing 1 to it. Writing 0 to the BRCD bit has no effect.
Asserting BRCD would generate an interrupt on interrupt_uart. The interrupt generation
can be masked using the control bit BKEN (UCR4[2]). Receiving a break condition will
also effect the following bits in the receiver register URXD:
URXD(11) = BRK. While high this bit indicates that the current char was detected as a
break.
URXD(12) = FRMERR. The frame error bit will always be set when BRK is set.
URXD(10) = PRERR. If odd parity was selected the parity error bit will also be set when
BRK is set.
URXD(14) = ERR. The error detect bit indicates that the character present in the rx data
field has an error status. This can be asserted by a break.
55.4.5.5
Vote Logic
The vote logic block provides jitter tolerance and noise immunity by sampling with
respect to a 16x clock (brm_clk) and using voting techniques to clean up the samples. The
voting is implemented by sampling the incoming signal constantly on the rising edge of
the brm_clk.
See Figure 55-6. The receiver is provided with the majority vote value, which is 2 out of
the 3 samples. For examples of the majority vote results of the vote logic, see the
following table.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3585

<!-- page 3586 -->

Table 55-8. Majority Vote Results
Samples
Vote
000
0
101
1
001
0
111
1
The vote logic captures a sample on every rising edge of brm_clk, however the receiver
uses 16x oversampling to take its value in the middle of the sample character.
The receiver starts to count when the Start bit is set however it does not capture the
contents of the RxFIFO at the time the Start bit is set. The start bit is validated when 0s
are received for 7 consecutive 1/16 of bit times following the 1-to-0 transition. Once the
counter reaches 0xF, it starts counting on the next bit and captures it in the middle of the
sampling frame (see Table 55-8). All data bits are captured in the same manner. Once the
stop bit is detected, the receiver shift register (SIPO_OUT) data is parallel shifted to the
RxFIFO.
-11-
-12- -13- -14- -15- -16- -17-
-S1- -S2- -S3- -S4- -S5- -S6- -S7- -S8- -S9- -S10--S11- -S12--S13--S14--S15--S16--S1- -S2- -S3- -S4- -S5- -S6- -S7- -S8- -S9- -S10-
brm_clk
RX_PIN
NOISE
111 111 111 111 111 111 110 100 000 000 000 000 000 000 000 000 000 000 000 000
001 011 111 110 101 011 111 111 111 111 111 111
000
110 100 000
110 101 011
Start Bit
VOTE_SR [2.0]
VOTE
Figure 55-6. Majority Vote Results
A new feature has been recently implemented, it allows to re-synchronize the counter on
each edge of RX_DATA line. This is automatic and allows to improve the immunity of
UART against signal distortion.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3586
NXP Semiconductors

<!-- page 3587 -->

There is a special case when the brm_clk frequency is too low and is unable to capture a 0
pulse in IrDA. In this case, the software must set the IRSC (UCR4[5]) bit so that the
reference clock (after internal divider) is used for the voting logic. The pulse is validated
by counting the length of the pulse.
Refer to Infrared Interface for more details.
55.4.5.6
Baud Rate Automatic Detection Logic
When the baud rate automatic detection logic is enabled, the UART locks onto the
incoming baud rate. To enable this feature, set the automatic detection of baud rate bit
(ADBR = UCR1[14] = 1) and write 1 to the ADET bit (USR2[15]) to clear it.
When ADET=0 and ADBR =1, the detection starts. Then, once the beginning of start bit
(transition from 1-to-0 of RX_DATA) has been detected, UART starts a counter (UBRC)
working at reference frequency. Once the end of start bit is detected (transition from 0-
to-1 of RX_DATA), the value of UBRC - 1 is directly copied into UBMR register. UBIR
register is filled with 0x000F.
So, at the end of start bit, registers gets following values:
          UBRC = number of reference clock periods (after divider) during Start bit.
          UBIR = 0x000F
          UBMR = UBRC - 1
The updated values of the 3 registers can be read.
See Table 55-9 for list of parameters for baud rate detection and Figure 55-7 for baud rate
detection protocol diagram.
If any of the UART BRM registers are simultaneously written by the baud rate automatic
detection logic and by the peripheral data bus, the peripheral data bus would have lower
priority.
Table 55-9. Baud Rate Automatic Detection
ADBR
ADET
Baud Rate Detection
interrupt_uart
0
X
Manual Configuration
1
1
0
Auto Detection Started
1
1
1
Auto Detection Complete
0
NOTE: This table assumes that no other interrupt is set at the same time this interrupt is set for the interrupt_uart signal.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3587

<!-- page 3588 -->

Start 
Bit
Idle
1
0
0
0
0
0
1
1
Stop 
Bit
Note: LSB Transmitted first. 
Transition from 0-to-1
Figure 55-7. Baud Rate Detection Protocol Diagram
55.4.5.6.1
Baud Rate Automatic Detection Protocol
The receiver must receive an ASCII character "A" or "a" to verify proper detection of the
incoming baud rate. When an ASCII character "A" (0x41) or "a" (0x61) is received and
no error occurs, the Automatic Detect baud rate bit is set (ADET=1) and if the interrupt is
enabled (ADEN=UCR1[15]=1), an interrupt interrupt_uart is generated.
When an ASCII character "A" or "a" is not received (because of a bit error or the
reception of another character), the auto detection sequence restarts and waits for another
1-to-0 transition.
As long as ADET = 0 and ADBR = 1, the UART continues to try to lock onto the
incoming baud rate. Once the ASCII character "A" or "a" is detected and the ADET bit is
set, the receiver ignores the ADBR bit and continues normal operation with the calculated
baud rate.
The UART interrupt is active ( interrupt_uart = 0) as long as ADET = 1 and ADBR = 1.
This can be disabled by clearing the automatic baud rate detection interrupt enable bit
(ADEN = 0). Before starting an automatic baud rate detection sequence, set ADET = 0
and ADBR = 1.
The RxFIFO must contain the ASCII character "A" or "a" following the automatic baud
rate detection interrupt.
The 16-bit UART Baud Rate Count Register (UBRC) is reset to 4 and stays at 0xFFFF
when an overflow occurs. The UBRC register counts (measures) the duration of start bit.
When the start bit is detected and counted, the UART Baud Rate Count Register retains
its value until the next automatic baud rate detection sequence is initiated.
The Baud Rate Count Register counts only when auto detection is enabled.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3588
NXP Semiconductors

<!-- page 3589 -->

55.4.5.6.2
New Baud Rate Determination
In order to fight against the problems caused by the distortion and the noise on the
RX_DATA line, the duration of the baud rate measurement has been extended.
Previously, as described above, this determination was based on the measurement of the
START bit duration. Now, this measurement is based on the duration of START bit +
bit0. Bit0 is the first bit following the START bit. In fact, the counter which is started at
the falling edge of START bit is no longer stopped at next rising edge (end of START
bit), but it is stopped at the next falling edge (end of bit0). As the character sent is always
a "A" (41h) or a "a" (61h), this second falling edge will always be present and it will
indicate the end of bit0. Once this counter is stopped, the result is divided by 2 and used
by the BRM to determine the incoming baud rate.
NOTE
UBRC register contains the result of this division by two, in
consequence it reflects the measurement of the duration of one
bit.
55.4.5.6.2.1
New Autobaud Counter Stopped bit and Interrupt
A new bit has been added in USR2 register: ACST (USR2[11]). This bit is set
immediately after the determination of the baud rate.
So,
• if ADNIMP is not set (default), ACST is set to 1 after the end of bit0,
• If ADNIMP is set to 1, ACST is set to 1 at the end of START bit.
If ACIEN (UCR3[0]) is set to 1, ACST will flag an interrupt on interrupt_uart signal.
This interrupt informs the Arm platform that the BRM has just been set with the result of
the bit length measurement. If needed, the Arm platform can perform a read of UBMR
(or UBRC) register and determine by itself the baud rate measured. Then the Arm
platform has the possibility to correct the BRM registers with the nearest standardized
baud rate.
NOTE
ACST is set only if ADBR is set to 1, for example, the UART
is autobauding.
Clear the ACST bit by writing 1 to it. Writing 0 to the ACST bit
has no effect.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3589

<!-- page 3590 -->

55.4.6
Escape Sequence Detection
An escape sequence typically consists of 3 characters entered in rapid succession (such as
+++). Because these are valid characters by themselves, the time between characters
determines if it is a valid escape sequence.
Too much time between two of the "+" characters is interpreted as two "+" characters,
and not part of an escape sequence.
The software chooses the escape character and writes its value to the UART Escape
Character Register (UESC). The software must also enable escape detection feature by
setting ESCEN (UCR2[11]) to 1. The hardware compares this value to incoming
characters in the RxFIFO. When an escape character is detected, the internal escape timer
starts to count. The software specifies a time-out value for the maximum allowable time
between 2 successive escape characters (see the table below). The escape timer is
programmable in intervals of 2 ms to a maximum interval of 8.192 seconds.
Table 55-10. Escape Timer Scaling
UTIM
Register
Maximum Time Between Specified Escape Characters
0x000
2 ms
0x001
4 ms
0x002
6 ms
0x003
8 ms
0x004
10 ms
...
...
0F8
498 ms
0F9
500 ms
...
...
9C3
5 s
...
...
FFD
8.188 s
FFE
8.190 s
FFF
8.192 s
NOTE: To calculate the time interval:
(UTIM_Value + 1) x 0.002 = Time_Interval
Example:
(09C3 + 1) x 0.002 = 5 s.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3590
NXP Semiconductors

<!-- page 3591 -->

The escape sequence detection feature is available for all the reference frequencies.
Before using Escape Sequence Detection, the user must fill the ONEMS register. This
24-bit register must contain the value of the UART internal frequency divided by 1000.
The internal frequency is obtained after the UART internal divider which is applied on
module_clock clock.
Example I:
• If the input clock module_clock frequency is 66.5 MHz.
• And if the input clock module_clock is divided by 2 with the internal divider:
UFCR[9:7] = 3'b100
ONEMS = 66.5 x 106
2 x 1000
= 33250 = 81E2h
Figure 55-8. Calculation of Frequency for ONEMS Register
Example II:
• If the input clock module_clock frequency is 66.5 MHz.
• And if the input clock module_clock is divided by 1with the internal divider:
UFCR[9:7] = 3'b101
ONEMS = 
= 66500 = 103C4h
66.5 x 106
1000
Figure 55-9. Calculation of Frequency for ONEMS Register
The escape sequence detection interrupt is asserted when the escape sequence interrupt
enable (ESCI) bit is set and an escape sequence is detected (ESCF set). Clear the ESCF
bit by writing 1 to it. Writing 0 to the ESCF bit has no effect.
55.5
Binary Rate Multiplier (BRM)
The BRM sub-block receives ref_clk (module_clock clock after divider). From this clock,
and with integer and non-integer division, BRM generates a 16x baud rate clock .
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3591

<!-- page 3592 -->

The UART transmitte will shift data out based on this 16x baud rate clock. The UART
receiver will sample the serial data line based on this 16x baud rate clock. The input and
output frequency ratio is programmed in the UART BRM Incremental Register (UBIR)
and UART BRM MOD Register (UBMR). The output frequency is divided by the input
frequency to produce this ratio. For integer division, set the UBIR = 0x000F and write the
divisor to the UBMR register. All values written to these registers must be one less than
the actual value to eliminate division by 0 (undefined), and to increase the maximum
range of the registers.
Updating the BRM registers requires writing to both registers. The UBIR register must be
written before writing to the UBMR register. If only one register is written to by the
software, the BRM continues to use the previous values.
The following examples show how to determine what values are to be programmed into
UBIR and UBMR for a given reference frequency and desired baud rate. The following
equation can be used to help determine these values:
BaudRate = 
UBMR + 1
UBIR + 1
16 x
(
)
Ref Freq
Figure 55-10. Frequency and Baud Rate for UBIR and UBMR
With:
Reference Frequency (Hz): UART Reference Frequency (module_clock after RFDIV
divider)
Baud Rate (bit/s): Desired baud rate.
Integer Division ÷ 21
Reference Frequency = 19.44 MHz
UBIR = 0x000F
UBMR = 0x0014
Baud Rate = 925.7 kbit/s
NOTE
Observe that each value written to the registers is one less than
the actual value.
Non-Integer Division
Binary Rate Multiplier (BRM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3592
NXP Semiconductors

<!-- page 3593 -->

Reference Frequency = 16 MHz
Desired Baud Rate = 920 Kbits/s
UBMR + 1
UBIR + 1
RefFreq
16 x BaudRate
16 x 106
16 x 920 x 103 
=
= 1.087
=
Ratio = 1.087 = 1087 / 1000
UBIR = 999 (decimal)= 0x3E7
UBMR = 1086 (decimal)= 0x43E
Non-Integer Division
Reference Frequency = 25 MHz
Desired Baud Rate = 920 kbit/s
Ratio = 1.69837 = 625 / 368
UBIR = 367 (decimal)= 0x16F
UBMR = 624 (decimal)= 0x270
Non-Integer Division
Reference Frequency: 30 MHz
Desired Baud Rate = 115.2 kbit/s
Ratio = 16.276043 = 65153 / 4003
UBIR = 4002 (decimal) = 0x0FA2
UBMR = 65152 (decimal) = 0xFE80
55.6
Infrared Interface
55.6.1
Generalities-Infrared
The Infrared interface is selected when IREN (UCR1[7]) is set to 1.
The Infrared Interface is compatible with IrDA Serial Infrared Physical Layer
Specification. In this specification, a "zero" is represented by a positive pulse, and a
"one" is represented by no pulse (line remains low).
In the UART:
In TX: For each "zero" to be transmitted, a narrow positive pulse which is 3/16 of a bit
time is generated. For each "one" to be transmitted no pulse is generated (output is low).
External circuitry has to be provided to drive an Infrared LED.
In RX: When receiving, a narrow negative pulse is expected for each "zero" transmitted
while no pulse is expected for each "one" transmitted (input is high).
NOTE
Rx part of IR block expects to receive an inverted signal
compared to IrDA specification. Circuitry external to the IC
transforms the Infrared signal to an electrical signal.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3593

<!-- page 3594 -->

The IR interface has an edge triggered interrupt (IRINT). This interrupt validates a zero
bit being received. This interrupt is enabled by writing a "one" to ENIRI bit.
The behavior of Infrared Interface is determined by 3 bits INVT (UCR3[1]), INVR
(UCR4[9]) and IRSC (UCR4[5]).
55.6.2
Inverted Transmission and Reception bits (INVT & INVR)
The values of INVT and INVR depend of the IrDA transceiver connected on the TXD_IR
and RXD_IR pins of the UART. If this transceiver is not inverting on both paths Tx and
Rx, a Zero is represented by a positive pulse and a One is represented by no pulse (line
remains low). In this case, the bit INVT must be set to 0 and the bit INVR must be set to
1 (because Rx IR block expects an inverted signal).
On the contrary user must set INVT=1 and INVR=0 if both paths of the transceiver are
inverting, that is, a Zero is represented as a negative pulse and a One is represented by no
pulse (line remains high). The transceiver can also be inverting on only one path (Tx or
Rx), in this case INVT and INVR must be together equal to 1 or to 0, depending on
which path is inverted.
55.6.3
InfraRed Special Case (IRSC) Bit
The value to apply to IRSC bit is based on 2 parameters: the baud rate and the Minimum
Pulse Duration (MPD) of the transceiver.
According to IrDA Standard Specification, for SIR (Serial IR) baud rates from 2.4 Kbit/s
to 115.2 Kbit/s this nominal pulse duration is equal to 3/16 of a bit duration (at the
selected baud rate). But, for all the baud rates a Minimum Pulse Duration is also
specified. According to IrDA Standard, a Zero is represented by a light pulse, so the IrDA
transceiver can't emit a light pulse shorter than the MPD. For SIR, the MPD is constant
and equal to 1.41 µs.
But user must take into account the electrical MPD associated with the transceiver on the
receiver path. Typically this value is 2.0 µs, but for some manufacturers MPD can go
down to 1.0 µs.
In order to understand the meaning of IRSC bit, one must understand how the RX path
works in IrDA mode.
When the UART is in IrDA mode, a Zero is not only detected by the state of the RXD_IR
line, but also with the duration of the pulse. This pulse duration can be measured with 2
different clocks. In this case, clock is selected with the IRSC bit.
Infrared Interface
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3594
NXP Semiconductors

<!-- page 3595 -->

• If IRSC = 0, the clock used is the BRM clock.
• If IRSC = 1, the clock used is the UART internal clock (UART clock after the
divider (RFDIV)).
In normal operation, IRSC=0. This means that at any time, the user must ensure that the
frequency of BRM_clock is high enough to measure the pulse. The pulse must last at
least 2 BRM clock cycles. If this condition is not fulfilled, IRSC must be set to 1.
Let's examine two examples, for a Minimum Pulse Duration equal to the MPD from the
IrDA SIR specification (i.e., 1.41 µs).
1: Calculation of BRM Clock Period (Clock Period < 1.41 µs)
The user wants to receive IrDA data at 115.2 Kbit/s. The UBIR and UBMR registers are
set in order to create the BRM_clock with a frequency of 16*baud rate = 16 * 115.2K =
1.843 MHz. But at the same time, in order to correctly detect the pulse, the user must be
sure that 2* BRM_clock period is lower than 1.41 µs. Lets check:
BRM_clock period = 1/1843000 = 542 ns
So 2*BRM_clock period = 1.09 µs < 1.41 µs. It is fine.
2: Calculation of BRM Clock Period (Clock Period > 1.41 µs)
This time the user wants to receive at 19.2 Kbit/s. So, the BRM_clock is set to 16*19200
= 307.2 kHz. Let's check if 2* BRM_clock period < 1.41 µs:
1. BRM_clock period =1/307200 = 3.25 µs
So 2*BRM_clock period = 6.50 µs >> 1.41 µs. It doesn't work.
So, in this case, the BRM clock can't be used to measure the pulse duration and the
user must select the UART internal clock by setting IRSC =1.
NOTE
Like for Escape character detection, when IR Special Case
is enabled (IRSC=1), the UART must measure a duration.
In order to do that, the user must fill the ONEMS register.
Refer to Escape Sequence Detection.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3595

<!-- page 3596 -->

55.6.4
IrDA interrupt
Serial infrared mode (SIR) uses an edge triggered interrupt flag IRINT (USR2[8]). When
INVR =0, detection of a falling edge on the RXD pin asserts the IRINT bit. When
INVR=1, detection of a rising edge on the RXD pin asserts the IRINT bit. When IRINT
and ENIRI bits are both asserted, the interrupt_uart interrupt is asserted. Clear the IRINT
bit by writing 1 to it. Writing 0 to the IRINT bit has no effect.
55.6.5
Conclusion about IrDA
Before using the UART in IrDA, the baud rate limit must be calculated. This baud rate
limit will inform the user if IRSC bit has to be set or not.
Let's determine this limit:
As already described, if IRSC = 0, the following condition must always be fulfilled
2 x BRMClockPeriod < MinPulseDuration
Figure 55-11. Calculation of Baud Rate
So,
2
MPD
BRMClockFrequency >
So, knowing BRM_clock frequency = 16 * Baud Rate, we get:
8 x MinPulseDuration
1
BaudRate >
So, the user needs to set IRSC = 0 when:
• If Minimum Pulse Duration = 2.5 us and Baud Rate > 50 Kbit/s.
• If Minimum Pulse Duration = 2.0 us and Baud Rate > 62.5 Kbit/s.
• If Minimum Pulse Duration = 1.41 us and Baud Rate > 88.6 Kbit/s.
NOTE
For baud rates lower than the limit, IRSC must be set to1.
Infrared Interface
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3596
NXP Semiconductors

<!-- page 3597 -->

55.6.6
Programming IrDA Interface
55.6.6.1
High Speed
As an example, the following sequence can be used to program the IrDA interface in
order to send and receive characters at 115.2 Kbit/s.
Assumptions:
• Input UART clock = 90 MHz
• Internal clock divider = 3 (divide Input UART clock by 3)
• Baud rate = 115.2 Kbit/s
• IrDA transceiver is not inverting on both channels: for Tx and Rx, a Zero is
represented by a positive pulse, and a One is represented by no pulse (line stays low).
• Interrupt: Sent to Arm platform when 1 char is received into the Rx FIFO (RDR)
Registers values and Programming orders:
UCR1 = 0x0085 
UCR1[7] = IREN = 1: Enable IR interface
UCR1[0] = UARTEN = 1: Enable UART
UTS = 0x0000 
UFCR = 0x0981 
TXTL[5:0] = 0x02: Default value
RFDIV[2:0] = 0x3: Divide Input UART clock by 3 (resulting internal clock  is 30 MHz)
RXTL[5:0] = 0x01: Default value
UBIR = 0x0202
UBMR = 0x20BE Baud rate = 115.2 kbit/s with internal clock = 30 MHz
UCR2 = 0x4027 
UCR2[14] = IRTS = 1: Ignore level of RTS input signal
UCR2[5] = WS = 1: Characters are 8-bit length
UCR2[2] = TXEN = 1: Enable Rx path
UCR2 [1] = RXEN = 1: Enable Tx path
UCR2[0] = SRST_B = 1: No software reset
UCR3 = 0x0000
         UCR4 = 0x8201
CTSTL[5:0] = 0x20: Default value
UCR4[9] = INVR = 1: Inverted Infrared Reception (because IrDA transceiver is not inverting)
UCR4[1] = DREN = 1: To enable RDR interrupt (sent when one char is received)
The UART is ready to send a character as soon as there is a write into UTXD register.
And an interrupt will be sent to Arm platform when a character is received.
55.6.6.2
Low Speed
This time, we keep the same assumptions but the speed is now 9.6 Kbit/s. So, this baud
rate is below the limit (even with a Min. Pulse Duration of 2.5 us) and thus IRSC must be
set to 1.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3597

<!-- page 3598 -->

Assumptions:
• Input UART clock = 90 MHz
• Internal clock divider = 3 (divide Input UART clock by 3)
• Baud rate = 9.6 Kbit/s
• IrDA transceiver is not inverting on both channels: for Tx and Rx, a Zero is
represented by a positive pulse, and a One is represented by no pulse (line stays low).
• Interrupt: Sent to Arm platform when 1 char is received into the Rx FIFO (RDR).
Registers values and Programming orders:
UCR1 = 0x0085 
UCR1[7] = IREN = 1: Enable IR interface
UCR1[0] = UARTEN = 1: Enable UART
UFCR = 0x0981 
UFCR[15:10] = TXTL[5:0] = 0x02: Default value
RFDIV[2:0] = 0x3: Divide Input UART clock by 3 (resulting internal clock  is 30 MHz)
UFCR[5:0] = RXTL[5:0] = 0x01: Default value
UBIR = 0x00FF
UBMR = 0xC354 Baud rate = 9.6 kbit/s with internal clock = 30 MHz
UCR2 = 0x4027 
UCR2[14] = IRTS = 1: Ignore level of RTS input signal
UCR2[5] = WS = 1: Characters are 8-bit length
UCR2[2] = TXEN = 1: Enable Rx path
UCR2 [1] = RXEN = 1: Enable Tx path
UCR2[0] = SRST_B = 1: No software reset
UCR3 = 0x0000
UCR3[1] = INVT = 0: Positive pulse represents 0.
UCR4 = 0x8221
UCR4[15:10] = CTSTL[5:0] = 0x20: Default value
UCR4[9] = INVR = 1: Inverted Infrared Reception (because IrDA transceiver is not inverting)
UCR4[5] = IRSC = 1: Because data rate is below the limit and thus the UART internal clock is 
used to measure the pulse duration.
UCR4[1] = DREN = 1: To enable RDR interrupt (sent when one char is received)
The UART is now ready to send a character as soon as there is a write into UTXD
register. An interrupt will be sent to Arm platform when a character is received.
55.7
9-bit RS-485 Mode
55.7.1
Generalities
The UART provides a 9-bit mode to facilitate multidrop (RS-485) network
communication. To enable this mode, set MDEN bit in the UMCR register to 1. When 9-
bit RS-485 mode is enabled, UART transmitter can transmit the ninth bit (9th bit) set by
TXB8, and UART receiver can differentiate between data frames (9th bit = 0) and address
frames (9th bit = 1).
The CTS_B pin can be used to control RS-485 output driver outside the chip.
9-bit RS-485 Mode
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3598
NXP Semiconductors

<!-- page 3599 -->

ipp_uart_txd
ipp_uart_rxd
ipp_uart_cts
UART
Module
RX_DATA
CTS_B
Differential Bus
TX_DATA
Figure 55-12. RS-485 driver connection (UART in DCE mode)
55.7.2
Transmit 9-bit RS-485 frames
To transmit 9-bit RS-485 frames, user need to enable parity (PREN=1) to enable
trasmitting the ninth data bit, set 8-bit data word size (WS=1), and write TXB8
(UMCR[2]) as the 9th bit (bit [8]) to be transmitted (write '0' to TXB8 to transmit a data
frame, write '1' to transmit a address frame). The other data bit [7:0] is written to TxFIFO
by writing to the UTXD same as normal RS-232 operation.
55.7.3
Receive 9-bit RS-485 frames
To receive 9-bit RS-485 frames, user need to enable parity (PREN=1) to enable receiving
the ninth data bit, set 8-bit data word size (WS=1). The receiver will save the 9-bit data to
RxFIFO, and user should read the 9th databit (bit [8]) by reading the PRERR (URXD[10])
bit, and read data bit [7:0] by reading the RX_DATA (URXD[7:0]).
There are two slave address detect modes, normal detect mode and automatic detect
mode, and can be selected by SLAM (UMCR[1]).
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3599

<!-- page 3600 -->

55.7.3.1
RS-485 Slave Address Normal Detect Mode
To enable Normal Detect mode, clear SLAM (UMCR[1] to 0). The receiver ignores all
data frames (9th bit = 0) until an address frame is received (9th bit = 1). At that time, the
slave address detected (SAD = USR1[3]) bit is asserted and the interrupt_uart interrupt is
generated (if SADEN = UMCR[3] = 1). The address byte and sebsequent bytes are all put
into RxFIFO along with their 9th bit. The UART will also generate DMA request
dma_req_rx when the RxFIFO reaches the selected threshold (controlled by RXTL) if
receive ready DMA (RXDMAEN = UCR1[8]) request is enabled.
User should read the 9th databit (bit [8]) by reading the PRERR (URXD[10]) bit, and read
data bit [7:0] by reading the RX_DATA (URXD[7:0]).
In this mode, once the UART has detected a 9th bit is equal to '1', it will always save the
subsequent frames to RxFIFO. So the software must decide whether the address and data
in RxFIFO are needed or not.
55.7.3.2
RS-485 Slave Address Automatic Detect Mode
To enable Automatic Detect Mode, set SLAM (UMCR[1]) to 1. The receiver tries to
detect an address byte (frame 9th bit = 1) that matches the programmed SLADDR
(UMCR[15:8]) character. If the received byte is a data or an address byte that does not
match the programmed SLADDR character, the receiver will discard these data.
Once the UART receives a matching address byte, it will assert the slave address detected
(SAD = USR1[3]) bit and the interrupt_uart interrupt will be generated (if SADEN =
UMCR[3] = 1). The address byte and sebsequent bytes are all put into RxFIFO along
with their 9th bit. If receive ready DMA(RXDMAEN = UCR1[8]) request is enabled, the
UART will also generate DMA request dma_req_rx when the RxFIFO reaches the
selected threshold (controlled by RXTL).
If another address byte is received and this address byte does not match SLADDR
character, the receiver will discard the address byte and subsequent data byte. If the
address byte again matches SLADDR character, the receiver will put this address byte
and subsequent data byte in the RxFIFO along with their 9th bit.
User should read the 9th databit (bit [8]) by reading the PRERR (URXD[10]) bit, and read
data bit [7:0] by reading the RX_DATA (URXD[7:0]).
See Initialization for 9-bit RS-485 programming guide.
Low Power Modes
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3600
NXP Semiconductors

<!-- page 3601 -->

55.8
Low Power Modes
These modes are controlled by the signals doze_req and stop_req. The control/status/data
registers won't change when getting in/out of low power modes.
Table 55-11. UART Low Power State Operation
Normal State
(doze_req = 1'b0
& stop_req = 1'b0)
Doze State
(doze_req = 1'b1)
Stop State
(stop_req = 1'b1)
DOZE bit = 0
DOZE bit = 1
UART-Clock
ON
ON
ON
OFF
UART Serial / IrDA
ON
ON
OFF
OFF
55.8.1
UART Operation in System Doze Mode
While in Doze State (when doze_req input pin is set to 1'b1), the UART behavior
depends on the DOZE (UCR1[1]) control bit.
While the DOZE bit is negated, the UART serial interface is enabled. While the system is
in the Doze State, and the DOZE bit is asserted, the UART is disabled. If the Doze State
is entered with the DOZE bit asserted while the UART serial interface was receiving or
transmitting data, it will complete the receive/transmit of the current character and signal
to the far-end transmitter/receiver to stop sending/receiving.
55.8.2
UART Operation in System Stop Mode
The internal baud rate clocks of the transmitter and receiver are gated off if the stop_req
signal to UART is asserted. Even though the clocks at the input of the UART continue to
run during system Stop mode, the UART will not do any transmission or reception.
The following UART interrupts wake the Arm platform processor from STOP mode:
• RTS (RTSD)
• IrDA Asynchronous WAKE (AIRINT)
• Asynchronous WAKE (AWAKE)
• RI (RIDELT in DTE mode only)
• DCD (DCDDELT in DTE mode only)
• DTR (DTRD in DCE mode only)
• DSR (DTRD in DTE mode only)
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3601

<!-- page 3602 -->

When an asynchronous WAKE (awake) interrupt exits the Arm platform from STOP
mode, make sure that a dummy character is sent first because the first character may not
be received correctly.
55.8.3
Power Saving Method in UART
The RXEN (UCR2[1]), TXEN (UCR2[2]) and UARTEN (UCR1[0]) bits are set by the
user and provide software control of low-power modes.
Setting the UARTEN (UCR1[0]) bit to 0 shuts off the receiver and transmitter logic and
the associated clocks.
If the UART is used only in transmit mode, UARTEN and TXEN must be set to 1. If the
UART is used only in receive mode, UARTEN and RXEN must be set to 1. Setting
TXEN or RXEN to 0 allows to save a lot of power.
55.9
UART Operation in System Debug State
The bit UTS [11] controls whether the UART will respond to the input signal debug_req,
or whether it will continue to run as normal.
If the UART is programmed to respond to debug_req:
1. The UART will halt all operations upon detecting the debug_req input.
2. A transfer in progress, either to/from a core (using the IP Bus interface) or to/from an
external device, will be completed before halting. This means a single byte/word
transfer, not an entire FIFO. Reception of any further data from an external device
will be disabled.
3. Internal registers will continue to be writable and readable using the IP Bus interface.
A read will leave the contents unaffected.
4. The RX FIFO is affected in debug mode in the following way:
• All writes into the RX FIFO are prevented.
• The bit RXDBG (UTS[9]) is used to select the readability of the RX FIFO
during debug mode:
RXDBG = 0: hold the read pointer at the location it had upon entering debug
mode, and URXD register returns only the data value at that location, no matter
how many reads attempted.
UART Operation in System Debug State
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3602
NXP Semiconductors

<!-- page 3603 -->

RXDBG = 1, selectable at any time: Allow to read the characters received in Rx
FIFO. It will not be possible to re-read previously read locations, nor will it be
possible to readjust the read pointer to the value it had prior to entering debug
mode.
55.10
Reset
This section describes how to reset the block and explains special requirements related to
reset.
55.10.1
Hardware reset
All of registers, FIFOs, state machines and sequential elements can be reset to their initial
values by hardware reset or power on reset.
55.10.2
Software reset
The status registers USR1 and USR2, BRM registers UBIR and UBMR, TxFIFO and
RxFIFO, and transmitter and receiver state machines can be reset by software reset.
Internal logic will keep the software reset asserted for about 4 module_clock cycles.
Programmer can follow the following software reset sequence:
1. Clear the SRST_B bit (UCR2[0])
2. Wait for software reset complete: poll SOFTRST bit (UTS[0]) until it is 0.
3. Re-program baud rate registers: Re-write UBIR and UBMR.
55.11
Transfer Error
The UART can generate a transfer error on the peripheral bus in the following cases:
• Core is writing into a read-only register.
• Core is accessing (read or write) an unused location within the assigned address
space reserved to UART.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3603

<!-- page 3604 -->

• Core is writing into UTXD register with transmit interface disabled (TXEN=0 or
UARTEN=0)
• Core is reading URXD register with receive interface disabled (RXEN=0 or
UARTEN=0)
55.12
Functional Timing
This section includes timing diagrams for functional signaling.
55.12.1
IrDA Mode
According to IrDA specification, the low speed (115.2Kbit/s and below) IR frame format
is compatible with UART frame.
In this figure, an example data 0x65 is used.
1
0
1
0
0
1
1
0
Stop
Bit
Start
Bit
Data Bits
UART Frame
1
0
1
0
0
1
1
0
Data Bits
Start
Bit
Stop
Bit
IR Frame
Bit
Time
Pulse Width
3/16 Bit Time
TXD_IR/ 
RXD_IR
Figure 55-13. Timing diagram of Low Speed IR (<=115.2 Kbit/s) Data Line
55.13
Initialization
Functional Timing
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3604
NXP Semiconductors

<!-- page 3605 -->

55.13.1
Programming the UART in RS-232 mode
As an example, the following sequence can be used to program the UART in order to
send and receive characters in RS-232 mode.
Assumptions:
• Input uart clock = 100 MHz
• Baud rate = 921.6 Kbps
• Data bits = 8 bits
• Parity = Even
• Stop bits = 1 bit
• Flow control = Hardware
Main program:
1. UCR1 = 0x0001
Enable the UART.
2. UCR2 = 0x2127
Set hardware flow control, data format and enable transmitter and receiver.
3. UCR3 = 0x0704
Set UCR3[RXDMUXSEL] = 1.
4. UCR4 = 0x7C00
Set CTS trigger level to 31,
5. UFCR = 0x089E
Set internal clock divider = 5 (divide input uart clock by 5). So the reference clock is
100 MHz/5 = 20 MHz.
Set TXTL = 2 and RXTL = 30.
6. UBIR = 0x08FF
7. UBMR = 0x0C34
In the above two steps, set baud rate to 921.6Kbps based on the 20MHz reference
clock.
8. UCR1 = 0x2201
Enable the TRDY and RRDY interrupts.
9. UMCR = 0x0000
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3605

<!-- page 3606 -->

UMCR stay at default value 0x0000
Interrupt service routine for the transmitter:
• Write characters into UTXD
The TRDY interrupt will be automatically de-asserted when the data level of the TxFIFO
exceeds the TXTL=2. Note: For the first time the interrupt may be de-asserted after 4
characters are written into the TxFIFO because of the shift register.
Interrupt service routine for the receiver:
• Read characters from URXD
The RRDY interrupt will be automatically de-asserted when the data level of the RxFIFO
is below the RXTL=30.
55.13.2
Programming the UART in 9-bit RS-485 mode
As an example, the following sequence can be used to program the UART in order to
send and receive frames in RS-485 mode.
Assumptions:
• Input uart clock = 100 MHz
• Baud rate = 5 Mbps
Main program:
1. UCR1 = 0x0001
Enable the UART.
2. UCR2 = 0x4127
Set software flow control (CTS pin is controlled by UCR2[12] ), enable parity(enable
9th bit rxd/txd), 8-bit word size , and enable transmitter and receiver.
3. UCR4 = 0x7C00
Set CTS trigger level to 31,
4. UFCR = 0x0A9E
Set RFDIV = 5 (divide input uart clock by 1), so the reference clock is 100 MHz. Set
UART in DCE mode (RS-485 driver connection outside the chip is the same as
Figure 55-12)
Initialization
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3606
NXP Semiconductors

<!-- page 3607 -->

Set TXTL = 2 and RXTL = 30.
5. UBIR = 0x0003
6. UBMR = 0x0004
In the above two steps, set baud rate to 5 Mbps based on the 100 MHz reference
clock.
7. UCR1 = 0x2001 when UART as a master ,
or UCR1 = 0x0201 (or 0x0101) when UART as a slave.
Enable TRDY interrupt when UART as a master, enable RRDY interrupt or DMA
request when UART as a slave.
8. UMCR = 0xA50B
Enable 9-bit RS-485 mode, enable SAD interrupt, set automatic slave address detect
mode, set slave address is 0xA5.
Interrupt service routine for the transmitter:
• Transmit data: write its ninth bit (bit[8]) to UMCR[2], write its bit [7:0] into
UTXD[7:0]
The TRDY interrupt will be automatically de-asserted when the data level of the TxFIFO
exceeds the TXTL=2.
Note: For the first time the interrupt may be de-asserted after 4 characters are written into
the TxFIFO because of the shift register.
Interrupt service routine for the receiver:
• Receive data: read its ninth bit (bit[8]) from URXD[10] , read its bit [7:0] from
URXD[7:0].
Note: in RS-485 mode, URXD[10] bit is not the parity error, instead it holds the ninth bit
(bit[8]) of the received data.
The SAD interrupt can not de-assert automatically, it needs MCU write 1 to USR1[3] to
clear it . The RRDY interrupt or DMA request will be automatically de-asserted when the
data level of the RxFIFO is below the RXTL=30.
55.14
References
• EIA/TIA-232-F Interface Standard
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3607

<!-- page 3608 -->

http://www.eia.org, http://www.tiaonline.org/standards
• IrDA Standard
http://www.irda.org
55.15
UART Memory Map/Register Definition
UART supports 8-bit, 16-bit and 32-bit accesses to 32-bit memory-mapped addresses.
Any access to unmapped memory location will yield a transfer error.
All registers except the ONEMS described in this section are 16-bit registers. The
ONEMS register is a 24-bit register.
• For 32-bit write accesses, the upper two bytes will not be taken into account.
• For 32-bit read accesses the upper two bytes will return 0.
The ONEMS register is expanded from 16 bits to 24 bits in order to support the high
frequency of the BRM internal clock ref_clk (module_clock after divider). The ONEMS
register can be accessed as 8 bits, 16 bits or 32 bits.
• For 32-bit write accesses, the most significant byte of the ONEMS will be discarded.
• For 32-bit read accesses, the most significant byte of the ONEMS will be read as 0.
UART memory map
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
201_8000
UART Receiver Register (UART7_URXD)
32
R
0000_0000h
55.15.1/
3615
201_8040
UART Transmitter Register (UART7_UTXD)
32
W
0000_0000h
55.15.2/
3617
201_8080
UART Control Register 1 (UART7_UCR1)
32
R/W
0000_0000h
55.15.3/
3618
201_8084
UART Control Register 2 (UART7_UCR2)
32
R/W
0000_0001h
55.15.4/
3620
201_8088
UART Control Register 3 (UART7_UCR3)
32
R/W
0000_0700h
55.15.5/
3623
201_808C
UART Control Register 4 (UART7_UCR4)
32
R/W
0000_8000h
55.15.6/
3625
201_8090
UART FIFO Control Register (UART7_UFCR)
32
R/W
0000_0801h
55.15.7/
3627
Table continues on the next page...
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3608
NXP Semiconductors

<!-- page 3609 -->

UART memory map (continued)
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
201_8094
UART Status Register 1 (UART7_USR1)
32
R/W
0000_2040h
55.15.8/
3629
201_8098
UART Status Register 2 (UART7_USR2)
32
R/W
0000_4028h
55.15.9/
3632
201_809C
UART Escape Character Register (UART7_UESC)
32
R/W
0000_002Bh
55.15.10/
3634
201_80A0
UART Escape Timer Register (UART7_UTIM)
32
R/W
0000_0000h
55.15.11/
3635
201_80A4
UART BRM Incremental Register (UART7_UBIR)
32
R/W
0000_0000h
55.15.12/
3635
201_80A8
UART BRM Modulator Register (UART7_UBMR)
32
R/W
0000_0000h
55.15.13/
3636
201_80AC
UART Baud Rate Count Register (UART7_UBRC)
32
R
0000_0004h
55.15.14/
3636
201_80B0
UART One Millisecond Register (UART7_ONEMS)
32
R/W
0000_0000h
55.15.15/
3637
201_80B4
UART Test Register (UART7_UTS)
32
R/W
0000_0060h
55.15.16/
3638
201_80B8
UART RS-485 Mode Control Register (UART7_UMCR)
32
R/W
0000_0000h
55.15.17/
3639
202_0000
UART Receiver Register (UART1_URXD)
32
R
0000_0000h
55.15.1/
3615
202_0040
UART Transmitter Register (UART1_UTXD)
32
W
0000_0000h
55.15.2/
3617
202_0080
UART Control Register 1 (UART1_UCR1)
32
R/W
0000_0000h
55.15.3/
3618
202_0084
UART Control Register 2 (UART1_UCR2)
32
R/W
0000_0001h
55.15.4/
3620
202_0088
UART Control Register 3 (UART1_UCR3)
32
R/W
0000_0700h
55.15.5/
3623
202_008C
UART Control Register 4 (UART1_UCR4)
32
R/W
0000_8000h
55.15.6/
3625
202_0090
UART FIFO Control Register (UART1_UFCR)
32
R/W
0000_0801h
55.15.7/
3627
202_0094
UART Status Register 1 (UART1_USR1)
32
R/W
0000_2040h
55.15.8/
3629
202_0098
UART Status Register 2 (UART1_USR2)
32
R/W
0000_4028h
55.15.9/
3632
202_009C
UART Escape Character Register (UART1_UESC)
32
R/W
0000_002Bh
55.15.10/
3634
202_00A0
UART Escape Timer Register (UART1_UTIM)
32
R/W
0000_0000h
55.15.11/
3635
202_00A4
UART BRM Incremental Register (UART1_UBIR)
32
R/W
0000_0000h
55.15.12/
3635
Table continues on the next page...
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3609

<!-- page 3610 -->

UART memory map (continued)
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
202_00A8
UART BRM Modulator Register (UART1_UBMR)
32
R/W
0000_0000h
55.15.13/
3636
202_00AC
UART Baud Rate Count Register (UART1_UBRC)
32
R
0000_0004h
55.15.14/
3636
202_00B0
UART One Millisecond Register (UART1_ONEMS)
32
R/W
0000_0000h
55.15.15/
3637
202_00B4
UART Test Register (UART1_UTS)
32
R/W
0000_0060h
55.15.16/
3638
202_00B8
UART RS-485 Mode Control Register (UART1_UMCR)
32
R/W
0000_0000h
55.15.17/
3639
21E_8000
UART Receiver Register (UART2_URXD)
32
R
0000_0000h
55.15.1/
3615
21E_8040
UART Transmitter Register (UART2_UTXD)
32
W
0000_0000h
55.15.2/
3617
21E_8080
UART Control Register 1 (UART2_UCR1)
32
R/W
0000_0000h
55.15.3/
3618
21E_8084
UART Control Register 2 (UART2_UCR2)
32
R/W
0000_0001h
55.15.4/
3620
21E_8088
UART Control Register 3 (UART2_UCR3)
32
R/W
0000_0700h
55.15.5/
3623
21E_808C
UART Control Register 4 (UART2_UCR4)
32
R/W
0000_8000h
55.15.6/
3625
21E_8090
UART FIFO Control Register (UART2_UFCR)
32
R/W
0000_0801h
55.15.7/
3627
21E_8094
UART Status Register 1 (UART2_USR1)
32
R/W
0000_2040h
55.15.8/
3629
21E_8098
UART Status Register 2 (UART2_USR2)
32
R/W
0000_4028h
55.15.9/
3632
21E_809C
UART Escape Character Register (UART2_UESC)
32
R/W
0000_002Bh
55.15.10/
3634
21E_80A0
UART Escape Timer Register (UART2_UTIM)
32
R/W
0000_0000h
55.15.11/
3635
21E_80A4
UART BRM Incremental Register (UART2_UBIR)
32
R/W
0000_0000h
55.15.12/
3635
21E_80A8
UART BRM Modulator Register (UART2_UBMR)
32
R/W
0000_0000h
55.15.13/
3636
21E_80AC
UART Baud Rate Count Register (UART2_UBRC)
32
R
0000_0004h
55.15.14/
3636
21E_80B0
UART One Millisecond Register (UART2_ONEMS)
32
R/W
0000_0000h
55.15.15/
3637
21E_80B4
UART Test Register (UART2_UTS)
32
R/W
0000_0060h
55.15.16/
3638
21E_80B8
UART RS-485 Mode Control Register (UART2_UMCR)
32
R/W
0000_0000h
55.15.17/
3639
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3610
NXP Semiconductors

<!-- page 3611 -->

UART memory map (continued)
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
21E_C000
UART Receiver Register (UART3_URXD)
32
R
0000_0000h
55.15.1/
3615
21E_C040
UART Transmitter Register (UART3_UTXD)
32
W
0000_0000h
55.15.2/
3617
21E_C080
UART Control Register 1 (UART3_UCR1)
32
R/W
0000_0000h
55.15.3/
3618
21E_C084
UART Control Register 2 (UART3_UCR2)
32
R/W
0000_0001h
55.15.4/
3620
21E_C088
UART Control Register 3 (UART3_UCR3)
32
R/W
0000_0700h
55.15.5/
3623
21E_C08C
UART Control Register 4 (UART3_UCR4)
32
R/W
0000_8000h
55.15.6/
3625
21E_C090
UART FIFO Control Register (UART3_UFCR)
32
R/W
0000_0801h
55.15.7/
3627
21E_C094
UART Status Register 1 (UART3_USR1)
32
R/W
0000_2040h
55.15.8/
3629
21E_C098
UART Status Register 2 (UART3_USR2)
32
R/W
0000_4028h
55.15.9/
3632
21E_C09C
UART Escape Character Register (UART3_UESC)
32
R/W
0000_002Bh
55.15.10/
3634
21E_C0A0
UART Escape Timer Register (UART3_UTIM)
32
R/W
0000_0000h
55.15.11/
3635
21E_C0A4
UART BRM Incremental Register (UART3_UBIR)
32
R/W
0000_0000h
55.15.12/
3635
21E_C0A8
UART BRM Modulator Register (UART3_UBMR)
32
R/W
0000_0000h
55.15.13/
3636
21E_C0AC
UART Baud Rate Count Register (UART3_UBRC)
32
R
0000_0004h
55.15.14/
3636
21E_C0B0
UART One Millisecond Register (UART3_ONEMS)
32
R/W
0000_0000h
55.15.15/
3637
21E_C0B4
UART Test Register (UART3_UTS)
32
R/W
0000_0060h
55.15.16/
3638
21E_C0B8
UART RS-485 Mode Control Register (UART3_UMCR)
32
R/W
0000_0000h
55.15.17/
3639
21F_0000
UART Receiver Register (UART4_URXD)
32
R
0000_0000h
55.15.1/
3615
21F_0040
UART Transmitter Register (UART4_UTXD)
32
W
0000_0000h
55.15.2/
3617
21F_0080
UART Control Register 1 (UART4_UCR1)
32
R/W
0000_0000h
55.15.3/
3618
21F_0084
UART Control Register 2 (UART4_UCR2)
32
R/W
0000_0001h
55.15.4/
3620
21F_0088
UART Control Register 3 (UART4_UCR3)
32
R/W
0000_0700h
55.15.5/
3623
Table continues on the next page...
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3611

<!-- page 3612 -->

UART memory map (continued)
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
21F_008C
UART Control Register 4 (UART4_UCR4)
32
R/W
0000_8000h
55.15.6/
3625
21F_0090
UART FIFO Control Register (UART4_UFCR)
32
R/W
0000_0801h
55.15.7/
3627
21F_0094
UART Status Register 1 (UART4_USR1)
32
R/W
0000_2040h
55.15.8/
3629
21F_0098
UART Status Register 2 (UART4_USR2)
32
R/W
0000_4028h
55.15.9/
3632
21F_009C
UART Escape Character Register (UART4_UESC)
32
R/W
0000_002Bh
55.15.10/
3634
21F_00A0
UART Escape Timer Register (UART4_UTIM)
32
R/W
0000_0000h
55.15.11/
3635
21F_00A4
UART BRM Incremental Register (UART4_UBIR)
32
R/W
0000_0000h
55.15.12/
3635
21F_00A8
UART BRM Modulator Register (UART4_UBMR)
32
R/W
0000_0000h
55.15.13/
3636
21F_00AC
UART Baud Rate Count Register (UART4_UBRC)
32
R
0000_0004h
55.15.14/
3636
21F_00B0
UART One Millisecond Register (UART4_ONEMS)
32
R/W
0000_0000h
55.15.15/
3637
21F_00B4
UART Test Register (UART4_UTS)
32
R/W
0000_0060h
55.15.16/
3638
21F_00B8
UART RS-485 Mode Control Register (UART4_UMCR)
32
R/W
0000_0000h
55.15.17/
3639
21F_4000
UART Receiver Register (UART5_URXD)
32
R
0000_0000h
55.15.1/
3615
21F_4040
UART Transmitter Register (UART5_UTXD)
32
W
0000_0000h
55.15.2/
3617
21F_4080
UART Control Register 1 (UART5_UCR1)
32
R/W
0000_0000h
55.15.3/
3618
21F_4084
UART Control Register 2 (UART5_UCR2)
32
R/W
0000_0001h
55.15.4/
3620
21F_4088
UART Control Register 3 (UART5_UCR3)
32
R/W
0000_0700h
55.15.5/
3623
21F_408C
UART Control Register 4 (UART5_UCR4)
32
R/W
0000_8000h
55.15.6/
3625
21F_4090
UART FIFO Control Register (UART5_UFCR)
32
R/W
0000_0801h
55.15.7/
3627
21F_4094
UART Status Register 1 (UART5_USR1)
32
R/W
0000_2040h
55.15.8/
3629
21F_4098
UART Status Register 2 (UART5_USR2)
32
R/W
0000_4028h
55.15.9/
3632
21F_409C
UART Escape Character Register (UART5_UESC)
32
R/W
0000_002Bh
55.15.10/
3634
Table continues on the next page...
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3612
NXP Semiconductors

<!-- page 3613 -->

UART memory map (continued)
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
21F_40A0
UART Escape Timer Register (UART5_UTIM)
32
R/W
0000_0000h
55.15.11/
3635
21F_40A4
UART BRM Incremental Register (UART5_UBIR)
32
R/W
0000_0000h
55.15.12/
3635
21F_40A8
UART BRM Modulator Register (UART5_UBMR)
32
R/W
0000_0000h
55.15.13/
3636
21F_40AC
UART Baud Rate Count Register (UART5_UBRC)
32
R
0000_0004h
55.15.14/
3636
21F_40B0
UART One Millisecond Register (UART5_ONEMS)
32
R/W
0000_0000h
55.15.15/
3637
21F_40B4
UART Test Register (UART5_UTS)
32
R/W
0000_0060h
55.15.16/
3638
21F_40B8
UART RS-485 Mode Control Register (UART5_UMCR)
32
R/W
0000_0000h
55.15.17/
3639
21F_C000
UART Receiver Register (UART6_URXD)
32
R
0000_0000h
55.15.1/
3615
21F_C040
UART Transmitter Register (UART6_UTXD)
32
W
0000_0000h
55.15.2/
3617
21F_C080
UART Control Register 1 (UART6_UCR1)
32
R/W
0000_0000h
55.15.3/
3618
21F_C084
UART Control Register 2 (UART6_UCR2)
32
R/W
0000_0001h
55.15.4/
3620
21F_C088
UART Control Register 3 (UART6_UCR3)
32
R/W
0000_0700h
55.15.5/
3623
21F_C08C
UART Control Register 4 (UART6_UCR4)
32
R/W
0000_8000h
55.15.6/
3625
21F_C090
UART FIFO Control Register (UART6_UFCR)
32
R/W
0000_0801h
55.15.7/
3627
21F_C094
UART Status Register 1 (UART6_USR1)
32
R/W
0000_2040h
55.15.8/
3629
21F_C098
UART Status Register 2 (UART6_USR2)
32
R/W
0000_4028h
55.15.9/
3632
21F_C09C
UART Escape Character Register (UART6_UESC)
32
R/W
0000_002Bh
55.15.10/
3634
21F_C0A0
UART Escape Timer Register (UART6_UTIM)
32
R/W
0000_0000h
55.15.11/
3635
21F_C0A4
UART BRM Incremental Register (UART6_UBIR)
32
R/W
0000_0000h
55.15.12/
3635
21F_C0A8
UART BRM Modulator Register (UART6_UBMR)
32
R/W
0000_0000h
55.15.13/
3636
21F_C0AC
UART Baud Rate Count Register (UART6_UBRC)
32
R
0000_0004h
55.15.14/
3636
21F_C0B0
UART One Millisecond Register (UART6_ONEMS)
32
R/W
0000_0000h
55.15.15/
3637
Table continues on the next page...
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3613

<!-- page 3614 -->

UART memory map (continued)
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
21F_C0B4
UART Test Register (UART6_UTS)
32
R/W
0000_0060h
55.15.16/
3638
21F_C0B8
UART RS-485 Mode Control Register (UART6_UMCR)
32
R/W
0000_0000h
55.15.17/
3639
228_8000
UART Receiver Register (UART8_URXD)
32
R
0000_0000h
55.15.1/
3615
228_8040
UART Transmitter Register (UART8_UTXD)
32
W
0000_0000h
55.15.2/
3617
228_8080
UART Control Register 1 (UART8_UCR1)
32
R/W
0000_0000h
55.15.3/
3618
228_8084
UART Control Register 2 (UART8_UCR2)
32
R/W
0000_0001h
55.15.4/
3620
228_8088
UART Control Register 3 (UART8_UCR3)
32
R/W
0000_0700h
55.15.5/
3623
228_808C
UART Control Register 4 (UART8_UCR4)
32
R/W
0000_8000h
55.15.6/
3625
228_8090
UART FIFO Control Register (UART8_UFCR)
32
R/W
0000_0801h
55.15.7/
3627
228_8094
UART Status Register 1 (UART8_USR1)
32
R/W
0000_2040h
55.15.8/
3629
228_8098
UART Status Register 2 (UART8_USR2)
32
R/W
0000_4028h
55.15.9/
3632
228_809C
UART Escape Character Register (UART8_UESC)
32
R/W
0000_002Bh
55.15.10/
3634
228_80A0
UART Escape Timer Register (UART8_UTIM)
32
R/W
0000_0000h
55.15.11/
3635
228_80A4
UART BRM Incremental Register (UART8_UBIR)
32
R/W
0000_0000h
55.15.12/
3635
228_80A8
UART BRM Modulator Register (UART8_UBMR)
32
R/W
0000_0000h
55.15.13/
3636
228_80AC
UART Baud Rate Count Register (UART8_UBRC)
32
R
0000_0004h
55.15.14/
3636
228_80B0
UART One Millisecond Register (UART8_ONEMS)
32
R/W
0000_0000h
55.15.15/
3637
228_80B4
UART Test Register (UART8_UTS)
32
R/W
0000_0060h
55.15.16/
3638
228_80B8
UART RS-485 Mode Control Register (UART8_UMCR)
32
R/W
0000_0000h
55.15.17/
3639
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3614
NXP Semiconductors

<!-- page 3615 -->

55.15.1
UART Receiver Register (UARTx_URXD)
NOTE
The UART will yield a transfer error on the peripheral bus
when core is reading URXD register with receive interface
disabled (RXEN=0 or UARTEN=0).
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
CHARRDY
ERR
OVRRUN
FRMERR
BRK
PRERR
Reserved
RX_DATA
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
UARTx_URXD field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15
CHARRDY
Character Ready. This read-only bit indicates an invalid read when the FIFO becomes empty and software
tries to read the same old data. This bit should not be used for polling for data written to the RX FIFO.
0
Character in RX_DATA field and associated flags are invalid.
1
Character in RX_DATA field and associated flags valid and ready for reading.
Table continues on the next page...
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3615

<!-- page 3616 -->

UARTx_URXD field descriptions (continued)
Field
Description
14
ERR
Error Detect. Indicates whether the character present in the RX_DATA field has an error (OVRRUN,
FRMERR, BRK or PRERR) status. The ERR bit is updated and valid for each received character.
0
No error status was detected
1
An error status was detected
13
OVRRUN
Receiver Overrun. This read-only bit, when HIGH, indicates that the corresponding character was stored
in the last position (32nd) of the Rx FIFO. Even if a 33rd character has not been detected, this bit will be
set to '1' for the 32nd character.
0
No RxFIFO overrun was detected
1
A RxFIFO overrun was detected
12
FRMERR
Frame Error. Indicates whether the current character had a framing error (a missing stop bit) and is
possibly corrupted. FRMERR is updated for each character read from the RxFIFO.
0
The current character has no framing error
1
The current character has a framing error
11
BRK
BREAK Detect. Indicates whether the current character was detected as a BREAK character. The data
bits and the stop bit are all 0. The FRMERR bit is set when BRK is set. When odd parity is selected,
PRERR is also set when BRK is set. BRK is valid for each character read from the RxFIFO.
0
The current character is not a BREAK character
1
The current character is a BREAK character
10
PRERR
In RS-485 mode, it holds the ninth data bit (bit [8]) of received 9-bit RS-485 data
In RS232/IrDA mode, it is the Parity Error flag. Indicates whether the current character was detected
with a parity error and is possibly corrupted. PRERR is updated for each character read from the RxFIFO.
When parity is disabled, PRERR always reads as 0.
0
= No parity error was detected for data in the RX_DATA field
1
= A parity error was detected for data in the RX_DATA field
9–8
-
This field is reserved.
Reserved
RX_DATA
Received Data. Holds the received character. In 7-bit mode, the most significant bit (MSB) is forced to 0.
In 8-bit mode, all bits are active.
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3616
NXP Semiconductors

<!-- page 3617 -->

55.15.2
UART Transmitter Register (UARTx_UTXD)
NOTE
The UART will yield a transfer error on the peripheral bus
when core is writing into UART_URXD register with transmit
interface disabled (TXEN=0 or UARTEN=0).
Memory space between UART_URXD and UART_UTXD
registers is reserved. Any read or write access to this space will
be considered as an invalid access and yield a transfer error.
Address: Base address + 40h offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
TX_DATA
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
UARTx_UTXD field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15–8
Reserved
This read-only field is reserved and always has the value 0.
TX_DATA
Transmit Data. Holds the parallel transmit data inputs. In 7-bit mode, D7 is ignored. In 8-bit mode, all bits
are used. Data is transmitted least significant bit (LSB) first. A new character is transmitted when the
TX_DATA field is written. The TX_DATA field must be written only when the TRDY bit is high to ensure
that corrupted data is not sent.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3617

<!-- page 3618 -->

55.15.3
UART Control Register 1 (UARTx_UCR1)
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
ADEN
ADBR
TRDYEN
IDEN
ICD
RRDYEN
RXDMAEN
IREN
TXMPTYEN
RTSDEN
SNDBRK
TXDMAEN
ATDMAEN
DOZE
UARTEN
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
UARTx_UCR1 field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15
ADEN
Automatic Baud Rate Detection Interrupt Enable. Enables/Disables the automatic baud rate detect
complete (ADET) bit to generate an interrupt (interrupt_uart = 0).
0
Disable the automatic baud rate detection interrupt
1
Enable the automatic baud rate detection interrupt
14
ADBR
Automatic Detection of Baud Rate. Enables/Disables automatic baud rate detection. When the ADBR
bit is set and the ADET bit is cleared, the receiver detects the incoming baud rate automatically. The
ADET flag is set when the receiver verifies that the incoming baud rate is detected properly by detecting
an ASCII character "A" or "a" (0x41 or 0x61).
0
Disable automatic detection of baud rate
1
Enable automatic detection of baud rate
13
TRDYEN
Transmitter Ready Interrupt Enable. Enables/Disables the transmitter Ready Interrupt (TRDY) when the
transmitter has one or more slots available in the TxFIFO. The fill level in the TXFIFO at which an interrupt
is generated is controlled by TxTL bits. When TRDYEN is negated, the transmitter ready interrupt is
disabled.
NOTE: An interrupt will be issued as long as TRDYEN and TRDY are high even if the transmitter is not
enabled. In general, user should enable the transmitter before enabling the TRDY interrupt.
0
Disable the transmitter ready interrupt
1
Enable the transmitter ready interrupt
12
IDEN
Idle Condition Detected Interrupt Enable. Enables/Disables the IDLE bit to generate an interrupt
(interrupt_uart = 0).
0
Disable the IDLE interrupt
1
Enable the IDLE interrupt
Table continues on the next page...
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3618
NXP Semiconductors

<!-- page 3619 -->

UARTx_UCR1 field descriptions (continued)
Field
Description
11–10
ICD
Idle Condition Detect. Controls the number of frames RXD is allowed to be idle before an idle condition is
reported.
00
Idle for more than 4 frames
01
Idle for more than 8 frames
10
Idle for more than 16 frames
11
Idle for more than 32 frames
9
RRDYEN
Receiver Ready Interrupt Enable. Enables/Disables the RRDY interrupt when the RxFIFO contains data.
The fill level in the RxFIFO at which an interrupt is generated is controlled by the RXTL bits. When
RRDYEN is negated, the receiver ready interrupt is disabled.
0
Disables the RRDY interrupt
1
Enables the RRDY interrupt
8
RXDMAEN
Receive Ready DMA Enable. Enables/Disables the receive DMA request dma_req_rx when the receiver
has data in the RxFIFO. The fill level in the RxFIFO at which a DMA request is generated is controlled by
the RXTL bits. When negated, the receive DMA request is disabled.
0
Disable DMA request
1
Enable DMA request
7
IREN
Infrared Interface Enable. Enables/Disables the IR interface. See the IR interface description in Infrared
Interface, for more information.
Note: MDEN(UMCR[0]) must be cleared to 0 when using IrDA interface. See Table 55-1
0
Disable the IR interface
1
Enable the IR interface
6
TXMPTYEN
Transmitter Empty Interrupt Enable. Enables/Disables the transmitter FIFO empty (TXFE) interrupt.
interrupt_uart. When negated, the TXFE interrupt is disabled.
NOTE: An interrupt will be issued as long as TXMPTYEN and TXFE are high even if the transmitter is not
enabled. In general, user should enable the transmitter before enabling the TXFE interrupt.
0
Disable the transmitter FIFO empty interrupt
1
Enable the transmitter FIFO empty interrupt
5
RTSDEN
RTS Delta Interrupt Enable. Enables/Disables the RTSD interrupt. The current status of the RTS_B pin is
read in the RTSS bit.
0
Disable RTSD interrupt
1
Enable RTSD interrupt
4
SNDBRK
Send BREAK. Forces the transmitter to send a BREAK character. The transmitter finishes sending the
character in progress (if any) and sends BREAK characters until SNDBRK is reset. Because the
transmitter samples SNDBRK after every bit is transmitted, it is important that SNDBRK is asserted high
for a sufficient period of time to generate a valid BREAK. After the BREAK transmission completes, the
UART transmits 2 mark bits. The user can continue to fill the TxFIFO and any characters remaining are
transmitted when the BREAK is terminated.
0
Do not send a BREAK character
1
Send a BREAK character (continuous 0s)
3
TXDMAEN
Transmitter Ready DMA Enable. Enables/Disables the transmit DMA request dma_req_tx when the
transmitter has one or more slots available in the TxFIFO. The fill level in the TxFIFO that generates the
dma_req_tx is controlled by the TXTL bits.
Table continues on the next page...
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3619

<!-- page 3620 -->

UARTx_UCR1 field descriptions (continued)
Field
Description
NOTE: A DMA request will be issued as long as TXDMAEN and TRDY are high even if the transmitter is
not enabled. In general, user should enable the transmitter before enabling the transmit DMA
request.
0
Disable transmit DMA request
1
Enable transmit DMA request
2
ATDMAEN
Aging DMA Timer Enable. Enables/Disables the receive DMA request dma_req_rx for the aging timer
interrupt (triggered with AGTIM flag in USR1[8]).
0
Disable AGTIM DMA request
1
Enable AGTIM DMA request
1
DOZE
DOZE. Determines the UART enable condition in the DOZE state. When doze_req input pin is at '1', (the
Arm Platform executes a doze instruction and the system is placed in the Doze State), the DOZE bit
affects operation of the UART. While in the Doze State, if this bit is asserted, the UART is disabled. See
the description in Low Power Modes.
0
The UART is enabled when in DOZE state
1
The UART is disabled when in DOZE state
0
UARTEN
UART Enable. Enables/Disables the UART. If UARTEN is negated in the middle of a transmission, the
transmitter stops and pulls the TXD line to a logic 1. UARTEN must be set to 1 before any access to
UTXD and URXD registers, otherwise a transfer error is returned.
This bit can be set to 1 along with other bits in this register. There is no restriction to the sequence of
programing this bit and other control registers.
0
Disable the UART
1
Enable the UART
55.15.4
UART Control Register 2 (UARTx_UCR2)
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
ESCI
IRTS
CTSC
CTS
ESCEN
RTEC
PREN
PRO
E
STPB
WS
RTSEN
ATEN
TXEN RXEN SRST
W
Reset
0
0
0
0
0
0
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
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3620
NXP Semiconductors

<!-- page 3621 -->

UARTx_UCR2 field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15
ESCI
Escape Sequence Interrupt Enable. Enables/Disables the ESCF bit to generate an interrupt.
0
Disable the escape sequence interrupt
1
Enable the escape sequence interrupt
14
IRTS
Ignore RTS Pin. Forces the RTS input signal presented to the transmitter to always be asserted (set to
low), effectively ignoring the external pin. When in this mode, the RTS pin serves as a general purpose
input.
0
Transmit only when the RTS pin is asserted
1
Ignore the RTS pin
13
CTSC
CTS Pin Control. Controls the operation of the CTS_B module output. When CTSC is asserted, the
CTS_B module output is controlled by the receiver. When the RxFIFO is filled to the level of the
programmed trigger level and the start bit of the overflowing character (TRIGGER LEVEL + 1) is validated,
the CTS_B module output is negated to indicate to the far-end transmitter to stop transmitting. When the
trigger level is programmed for less than 32, the receiver continues to receive data until the RxFIFO is full.
When the CTSC bit is negated, the CTS_B module output is controlled by the CTS bit. On reset, because
CTSC is cleared to 0, the CTS_B pin is controlled by the CTS bit, which again is cleared to 0 on reset.
This means that on reset the CTS_B signal is negated.
0
The CTS_B pin is controlled by the CTS bit
1
The CTS_B pin is controlled by the receiver
12
CTS
Clear to Send. Controls the CTS_B pin when the CTSC bit is negated. CTS has no function when CTSC
is asserted.
0
The CTS_B pin is high (inactive)
1
The CTS_B pin is low (active)
11
ESCEN
Escape Enable. Enables/Disables the escape sequence detection logic.
0
Disable escape sequence detection
1
Enable escape sequence detection
10–9
RTEC
Request to Send Edge Control. Selects the edge that triggers the RTS interrupt. This has no effect on
the RTS delta interrupt. RTEC has an effect only when RTSEN = 1 (see Table 55-5).
00
Trigger interrupt on a rising edge
01
Trigger interrupt on a falling edge
1X
Trigger interrupt on any edge
8
PREN
Parity Enable. Enables/Disables the parity generator in the transmitter and parity checker in the receiver.
When PREN is asserted, the parity generator and checker are enabled, and disabled when PREN is
negated.
0
Disable parity generator and checker
1
Enable parity generator and checker
7
PROE
Parity Odd/Even. Controls the sense of the parity generator and checker. When PROE is high, odd parity
is generated and expected. When PROE is low, even parity is generated and expected. PROE has no
function if PREN is low.
0
Even parity
1
Odd parity
Table continues on the next page...
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3621

<!-- page 3622 -->

UARTx_UCR2 field descriptions (continued)
Field
Description
6
STPB
Stop. Controls the number of stop bits after a character. When STPB is low, 1 stop bit is sent. When
STPB is high, 2 stop bits are sent. STPB also affects the receiver.
0
The transmitter sends 1 stop bit. The receiver expects 1 or more stop bits.
1
The transmitter sends 2 stop bits. The receiver expects 2 or more stop bits.
5
WS
Word Size. Controls the character length. When WS is high, the transmitter and receiver are in 8-bit
mode. When WS is low, they are in 7-bit mode. The transmitter ignores bit 7 and the receiver sets bit 7 to
0. WS can be changed in-between transmission (reception) of characters, however not when a
transmission (reception) is in progress, in which case the length of the current character being transmitted
(received) is unpredictable.
0
7-bit transmit and receive character length (not including START, STOP or PARITY bits)
1
8-bit transmit and receive character length (not including START, STOP or PARITY bits)
4
RTSEN
Request to Send Interrupt Enable. Controls the RTS edge sensitive interrupt. When RTSEN is asserted
and the programmed edge is detected on the RTS_B pin (the RTSF bit is asserted), an interrupt will be
generated on the interrupt_uart pin. (See Table 55-5.)
0
Disable request to send interrupt
1
Enable request to send interrupt
3
ATEN
Aging Timer Enable. This bit is used to enable the aging timer interrupt (triggered with AGTIM)
0
AGTIM interrupt disabled
1
AGTIM interrupt enabled
2
TXEN
Transmitter Enable. Enables/Disables the transmitter. When TXEN is negated the transmitter is disabled
and idle. When the UARTEN and TXEN bits are set the transmitter is enabled. If TXEN is negated in the
middle of a transmission, the UART disables the transmitter immediately, and starts marking 1s. The
transmitter FIFO cannot be written when this bit is cleared.
0
Disable the transmitter
1
Enable the transmitter
1
RXEN
Receiver Enable. Enables/Disables the receiver. When the receiver is enabled, if the RXD input is
already low, the receiver does not recognize BREAK characters, because it requires a valid 1-to-0
transition before it can accept any character.
0
Disable the receiver
1
Enable the receiver
0
SRST
Software Reset. Once the software writes 0 to SRST_B, the software reset remains active for 4
module_clock cycles before the hardware deasserts SRST_B. The software can only write 0 to SRST_B.
Writing 1 to SRST_B is ignored.
0
Reset the transmit and receive state machines, all FIFOs and register USR1, USR2, UBIR, UBMR,
UBRC , URXD, UTXD and UTS[6-3].
1
No reset
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3622
NXP Semiconductors

<!-- page 3623 -->

55.15.5
UART Control Register 3 (UARTx_UCR3)
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
DPEC
DTREN
PARERREN
FRAERREN
DSR
DCD
RI
ADNIMP
RXDSEN
AIRINTEN
AWAKEN
DTRDEN
RXDMUXSEL
INVT
ACIEN
W
Reset
0
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
0
0
0
UARTx_UCR3 field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15–14
DPEC
DTR/DSR Interrupt Edge Control. These bits control the edge of DTR_B (DCE) or DSR_B (DTE) on
which an interrupt will be generated. An interrupt will only be generated if the DTREN bit is set.
00
interrupt generated on rising edge
01
interrupt generated on falling edge
1X
interrupt generated on either edge
13
DTREN
Data Terminal Ready Interrupt Enable. When this bit is set, it will enable the status bit DTRF (USR2
[13]) (DTR/DSR edge sensitive interrupt) to cause an interrupt.
0
Data Terminal Ready Interrupt Disabled
1
Data Terminal Ready Interrupt Enabled
12
PARERREN
Parity Error Interrupt Enable. Enables/Disables the interrupt. When asserted, PARERREN causes
the PARITYERR bit to generate an interrupt.
0
Disable the parity error interrupt
1
Enable the parity error interrupt
11
FRAERREN
Frame Error Interrupt Enable. Enables/Disables the interrupt. When asserted, FRAERREN causes
the FRAMERR bit to generate an interrupt.
0
Disable the frame error interrupt
1
Enable the frame error interrupt
10
DSR
Data Set Ready. This bit is used by software to control the DSR/DTR module output for the modem
interface. In DCE mode it applies to DSR_B and in DTE mode it applies to DTR_B.
0
DSR/ DTR pin is logic zero
1
DSR/ DTR pin is logic one
Table continues on the next page...
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3623

<!-- page 3624 -->

UARTx_UCR3 field descriptions (continued)
Field
Description
9
DCD
Data Carrier Detect. In DCE mode this bit is used by software to control the DCD_B module output for the
modem interface. In DTE mode, when this bit is set, it will enable the status bit DCDDELT (USR2 (6)) to
cause an interrupt.
0
DCD_B pin is logic zero (DCE mode)
1
DCD_B pin is logic one (DCE mode)
0
DCDDELT interrupt disabled (DTE mode)
1
DCDDELT interrupt enabled (DTE mode)
8
RI
Ring Indicator. In DCE mode this bit is used by software to control the RI_B module output for the
modem interface. In DTE mode, when this bit is set, it will enable the status bit RIDELT (USR2 (10)) to
cause an interrupt.
0
RI_B pin is logic zero (DCE mode)
1
RI_B pin is logic one (DCE mode)
0
RIDELT interrupt disabled (DTE mode)
1
RIDELT interrupt enabled (DTE mode)
7
ADNIMP
Autobaud Detection Not Improved-. Disables new features of autobaud detection (See Baud Rate
Automatic Detection Protocol, for more details).
0
Autobaud detection new features selected
1
Keep old autobaud detection mechanism
6
RXDSEN
Receive Status Interrupt Enable. Controls the receive status interrupt (interrupt_uart). When this bit is
enabled and RXDS status bit is set, the interrupt interrupt_uart will be generated.
0
Disable the RXDS interrupt
1
Enable the RXDS interrupt
5
AIRINTEN
Asynchronous IR WAKE Interrupt Enable. Controls the asynchronous IR WAKE interrupt. An interrupt is
generated when AIRINTEN is asserted and a pulse is detected on the RXD pin.
0
Disable the AIRINT interrupt
1
Enable the AIRINT interrupt
4
AWAKEN
Asynchronous WAKE Interrupt Enable. Controls the asynchronous WAKE interrupt. An interrupt is
generated when AWAKEN is asserted and a falling edge is detected on the RXD pin.
0
Disable the AWAKE interrupt
1
Enable the AWAKE interrupt
3
DTRDEN
Data Terminal Ready Delta Enable. Enables / Disables the asynchronous DTRD interrupt. When
DTRDEN is asserted and an edge (rising or falling) is detected on DTR_B (in DCE mode) or on DSR_B (in
DTE mode), then an interrupt is generated.
0
Disable DTRD interrupt
1
Enable DTRD interrupt
2
RXDMUXSEL
RXD Muxed Input Selected. Selects proper input pins for serial and Infrared input signal.
NOTE: In this chip, UARTs are used in MUXED mode, so that this bit should always be set.
1
INVT
Invert TXD output in RS-232/RS-485 mode, set TXD active level in IrDA mode.
In RS232/RS-485 mode(UMCR[0] = 1), if this bit is set to 1, the TXD output is inverted before transmitted.
In IrDA mode, when INVT is cleared, the infrared logic block transmits a positive IR 3/16 pulse for all 0s
and 0s are transmitted for 1s. When INVT is set (INVT = 1), the infrared logic block transmits an active low
or negative infrared 3/16 pulse for all 0s and 1s are transmitted for 1s.
Table continues on the next page...
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3624
NXP Semiconductors

<!-- page 3625 -->

UARTx_UCR3 field descriptions (continued)
Field
Description
0
TXD is not inverted
1
TXD is inverted
0
TXD Active low transmission
1
TXD Active high transmission
0
ACIEN
Autobaud Counter Interrupt Enable. This bit is used to enable the autobaud counter stopped interrupt
(triggered with ACST (USR2[11]).
0
ACST interrupt disabled
1
ACST interrupt enabled
55.15.6
UART Control Register 4 (UARTx_UCR4)
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
W
Reset
0
0
0
0
0
0
0
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
CTSTL
INVR ENIRI
WKEN
IDDMAEN
IRSC
LPBYP
TCEN
BKEN
OREN
DREN
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
0
UARTx_UCR4 field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15–10
CTSTL
CTS Trigger Level. Controls the threshold at which the CTS_B pin is deasserted by the RxFIFO. After the
trigger level is reached and the CTS_B pin is deasserted, the RxFIFO continues to receive data until it is
full. The CTSTL bits are encoded as shown in the Settings column.
Settings 0 to 32 are in use. All other settings are Reserved.
000000
0 characters received
000001
1 characters in the RxFIFO
...
—
...
—
100000
32 characters in the RxFIFO (maximum)
9
INVR
Invert RXD input in RS-232/RS-485 Mode, determine RXD input logic level being sampled in In IrDA
mode.
Table continues on the next page...
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3625

<!-- page 3626 -->

UARTx_UCR4 field descriptions (continued)
Field
Description
In RS232/RS-485 Mode(UMCR[0] = 1), if this bit is set to 1, the RXD input is inverted before
sampled.
In IrDA mode,when cleared, the infrared logic block expects an active low or negative IR 3/16 pulse for 0s
and 1s are expected for 1s. When INVR is set (INVR 1), the infrared logic block expects an active high or
positive IR 3/16 pulse for 0s and 0s are expected for 1s.
0
RXD input is not inverted
1
RXD input is inverted
0
RXD active low detection
1
RXD active high detection
8
ENIRI
Serial Infrared Interrupt Enable. Enables/Disables the serial infrared interrupt.
0
Serial infrared Interrupt disabled
1
Serial infrared Interrupt enabled
7
WKEN
WAKE Interrupt Enable. Enables/Disables the WAKE bit to generate an interrupt. The WAKE bit is set at
the detection of a start bit by the receiver.
0
Disable the WAKE interrupt
1
Enable the WAKE interrupt
6
IDDMAEN
DMA IDLE Condition Detected Interrupt Enable Enables/Disables the receive DMA request
dma_req_rx for the IDLE interrupt (triggered with IDLE flag in USR2[12]).
0
DMA IDLE interrupt disabled
1
DMA IDLE interrupt enabled
5
IRSC
IR Special Case. Selects the clock for the vote logic. When set, IRSC switches the vote logic clock from
the sampling clock to the UART reference clock. The IR pulses are counted a predetermined amount of
time depending on the reference frequency. See InfraRed Special Case (IRSC) Bit.
0
The vote logic uses the sampling clock (16x baud rate) for normal operation
1
The vote logic uses the UART reference clock
4
LPBYP
Low Power Bypass. Allows to bypass the low power new features in UART. To use during debug phase.
0
Low power features enabled
1
Low power features disabled
3
TCEN
TransmitComplete Interrupt Enable. Enables/Disables the TXDC bit to generate an interrupt
(interrupt_uart = 0)
NOTE: An interrupt will be issued as long as TCEN and TXDC are high even if the transmitter is not
enabled. In general, user should enable the transmitter before enabling the TXDC interrupt.
0
Disable TXDC interrupt
1
Enable TXDC interrupt
2
BKEN
BREAK Condition Detected Interrupt Enable. Enables/Disables the BRCD bit to generate an interrupt.
0
Disable the BRCD interrupt
1
Enable the BRCD interrupt
1
OREN
Receiver Overrun Interrupt Enable. Enables/Disables the ORE bit to generate an interrupt.
0
Disable ORE interrupt
1
Enable ORE interrupt
Table continues on the next page...
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3626
NXP Semiconductors

<!-- page 3627 -->

UARTx_UCR4 field descriptions (continued)
Field
Description
0
DREN
Receive Data Ready Interrupt Enable. Enables/Disables the RDR bit to generate an interrupt.
0
Disable RDR interrupt
1
Enable RDR interrupt
55.15.7
UART FIFO Control Register (UARTx_UFCR)
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
W
Reset
0
0
0
0
0
0
0
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
TXTL
RFDIV
DCEDTE
RXTL
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
1
UARTx_UFCR field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15–10
TXTL
Transmitter Trigger Level. Controls the threshold at which a maskable interrupt is generated by the
TxFIFO. A maskable interrupt is generated whenever the data level in the TxFIFO falls below the selected
threshold. The bits are encoded as shown in the Settings column.
Settings 0 to 32 are in use. All other settings are Reserved.
000000
Reserved
000001
Reserved
000010
TxFIFO has 2 or fewer characters
...
—
...
—
011111
TxFIFO has 31 or fewer characters
100000
TxFIFO has 32 characters (maximum)
9–7
RFDIV
Reference Frequency Divider. Controls the divide ratio for the reference clock. The input clock is
module_clock. The output from the divider is ref_clk which is used by BRM to create the 16x baud rate
oversampling clock (brm_clk).
000
Divide input clock by 6
001
Divide input clock by 5
Table continues on the next page...
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3627

<!-- page 3628 -->

UARTx_UFCR field descriptions (continued)
Field
Description
010
Divide input clock by 4
011
Divide input clock by 3
100
Divide input clock by 2
101
Divide input clock by 1
110
Divide input clock by 7
111
Reserved
6
DCEDTE
DCE/DTE mode select. Select UART as data communication equipment (DCE mode) or as data terminal
equipment (DTE mode).
0
DCE mode selected
1
DTE mode selected
RXTL
Receiver Trigger Level. Controls the threshold at which a maskable interrupt is generated by the
RxFIFO. A maskable interrupt is generated whenever the data level in the RxFIFO reaches the selected
threshold. The RXTL bits are encoded as shown in the Settings column.
Setting 0 to 32 are in use. All other settings are Reserved.
000000
0 characters received
000001
RxFIFO has 1 character
...
—
...
—
011111
RxFIFO has 31 characters
100000
RxFIFO has 32 characters (maximum)
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3628
NXP Semiconductors

<!-- page 3629 -->

55.15.8
UART Status Register 1 (UARTx_USR1)
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
PARITYERR
RTSS
TRDY
RTSD
ESCF
FRAMERR
RRDY
AGTIM
DTRD
RXDS
AIRINT
AWAKE
SAD
Reserved
W
w1c
w1c
w1c
w1c
w1c
w1c
w1c
w1c
w1c
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
1
0
0
0
0
0
0
UARTx_USR1 field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15
PARITYERR
Parity Error Interrupt Flag. Indicates a parity error is detected. PARITYERR is cleared by writing 1 to it.
Writing 0 to PARITYERR has no effect. When parity is disabled, PARITYERR always reads 0. At reset,
PARITYERR is set to 0.
0
No parity error detected
1
Parity error detected (write 1 to clear)
14
RTSS
RTS_B Pin Status. Indicates the current status of the RTS_B pin. A "snapshot" of RTS_B is taken
immediately before RTSS is presented to the data bus. RTSS cannot be cleared because all writes to
RTSS are ignored. At reset, RTSS is set to 0.
Table continues on the next page...
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3629

<!-- page 3630 -->

UARTx_USR1 field descriptions (continued)
Field
Description
0
The RTS_B module input is high (inactive)
1
The RTS_B module input is low (active)
13
TRDY
Transmitter Ready Interrupt / DMA Flag. Indicates that the TxFIFO emptied below its target threshold
and requires data. TRDY is automatically cleared when the data level in the TxFIFO exceeds the threshold
set by TXTL bits. At reset, TRDY is set to 1.
0
The transmitter does not require data
1
The transmitter requires data (interrupt posted)
12
RTSD
RTS Delta. Indicates whether the RTS_B pin changed state. It (RTSD) generates a maskable interrupt.
When in STOP mode, RTS assertion sets RTSD and can be used to wake the processor. The current
state of the RTS_B pin is available on the RTSS bit. Clear RTSD by writing 1 to it. Writing 0 to RTSD has
no effect. At reset, RTSD is set to 0.
0
RTS_B pin did not change state since last cleared
1
RTS_B pin changed state (write 1 to clear)
11
ESCF
Escape Sequence Interrupt Flag. Indicates if an escape sequence was detected. ESCF is asserted
when the ESCEN bit is set and an escape sequence is detected in the RxFIFO. Clear ESCF by writing 1
to it. Writing 0 to ESCF has no effect.
0
No escape sequence detected
1
Escape sequence detected (write 1 to clear).
10
FRAMERR
Frame Error Interrupt Flag. Indicates that a frame error is detected. The interrupt_uart interrupt will be
generated if a frame error is detected and the interrupt is enabled. Clear FRAMERR by writing 1 to it.
Writing 0 to FRAMERR has no effect.
0
No frame error detected
1
Frame error detected (write 1 to clear)
9
RRDY
Receiver Ready Interrupt / DMA Flag. Indicates that the RxFIFO data level is above the threshold set by
the RXTL bits. (See the RXTL bits description in UART FIFO Control Register (UART_UFCR) for setting
the interrupt threshold.) When asserted, RRDY generates a maskable interrupt or DMA request. RRDY is
automatically cleared when data level in the RxFIFO goes below the set threshold level. At reset, RRDY is
set to 0.
0
No character ready
1
Character(s) ready (interrupt posted)
8
AGTIM
Ageing Timer Interrupt Flag. Indicates that data in the RxFIFO has been idle for a time of 8 character
lengths (where a character length consists of 7 or 8 bits, depending on the setting of the WS bit in UCR2,
with the bit time corresponding to the baud rate setting) and FIFO data level is less than RxFIFO threshold
level (RXTL in the UFCR). Clear by writing a 1 to it.
0
AGTIM is not active
1
AGTIM is active (write 1 to clear)
7
DTRD
DTR Delta. Indicates whether DTR_B (in DCE mode) or DSR_B (in DTE mode) pins changed state.
DTRD generates a maskable interrupt if DTRDEN (UCR3[3]) is set. Clear DTRD by writing 1 to it. Writing
0 to DTRD has no effect.
0
DTR_B (DCE) or DSR_B (DTE) pin did not change state since last cleared
1
DTR_B (DCE) or DSR_B (DTE) pin changed state (write 1 to clear)
6
RXDS
Receiver IDLE Interrupt Flag. Indicates that the receiver state machine is in an IDLE state, the next state
is IDLE, and the receive pin is high. RXDS is automatically cleared when a character is received. RXDS is
active only when the receiver is enabled.
Table continues on the next page...
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3630
NXP Semiconductors

<!-- page 3631 -->

UARTx_USR1 field descriptions (continued)
Field
Description
0
Receive in progress
1
Receiver is IDLE
5
AIRINT
Asynchronous IR WAKE Interrupt Flag. Indicates that the IR WAKE pulse was detected on the RXD pin.
Clear AIRINT by writing 1 to it. Writing 0 to AIRINT has no effect.
0
No pulse was detected on the RXD IrDA pin
1
A pulse was detected on the RXD IrDA pin
4
AWAKE
Asynchronous WAKE Interrupt Flag. Indicates that a falling edge was detected on the RXD pin. Clear
AWAKE by writing 1 to it. Writing 0 to AWAKE has no effect.
0
No falling edge was detected on the RXD Serial pin
1
A falling edge was detected on the RXD Serial pin
3
SAD
RS-485 Slave Address Detected Interrupt Flag.
Indicates if RS-485 Slave Address was detected . SAD was asserted in RS-485 mode when the SADEN
bit is set and Slave Address is detected in RxFIFO (in Nomal Address Detect Mode, the 9th data bit = 1; in
Automatic Address Detect Mode, the received charater matches the programmed SLADDR).
0
No slave address detected
1
Slave address detected
-
This field is reserved.
Reserved
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3631

<!-- page 3632 -->

55.15.9
UART Status Register 2 (UARTx_USR2)
Address: Base address + 98h offset
Bit
31
30
29
28
27
26
25
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
ADET
TXFE
DTRF
IDLE
ACST
RIDELT
RIIN
IRINT
WAKE
DCDDELT
DCDIN
RTSF
TXDC
BRCD
ORE
RDR
W
w1c
w1c
w1c
w1c
w1c
w1c
w1c
w1c
w1c
w1c
w1c
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
1
0
1
0
0
0
UARTx_USR2 field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15
ADET
Automatic Baud Rate Detect Complete. Indicates that an "A" or "a" was received and that the receiver
detected and verified the incoming baud rate. Clear ADET by writing 1 to it. Writing 0 to ADET has no
effect.
0
ASCII "A" or "a" was not received
1
ASCII "A" or "a" was received (write 1 to clear)
14
TXFE
Transmit Buffer FIFO Empty. Indicates that the transmit buffer (TxFIFO) is empty. TXFE is cleared
automatically when data is written to the TxFIFO. Even though TXFE is high, the transmission might still
be in progress.
0
The transmit buffer (TxFIFO) is not empty
1
The transmit buffer (TxFIFO) is empty
Table continues on the next page...
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3632
NXP Semiconductors

<!-- page 3633 -->

UARTx_USR2 field descriptions (continued)
Field
Description
13
DTRF
DTR edge triggered interrupt flag. This bit is asserted, when the programmed edge is detected on the
DTR_B pin (DCE mode) or on DSR_B (DTE mode). This flag can cause an interrupt if DTREN (UCR3[13])
is enabled.
0
Programmed edge not detected on DTR/DSR
1
Programmed edge detected on DTR/DSR (write 1 to clear)
12
IDLE
Idle Condition. Indicates that an idle condition has existed for more than a programmed amount frame
(see Idle Line Detect. An interrupt can be generated by this IDLE bit if IDEN (UCR1[12]) is enabled. IDLE
is cleared by writing 1 to it. Writing 0 to IDLE has no effect.
0
No idle condition detected
1
Idle condition detected (write 1 to clear)
11
ACST
Autobaud Counter Stopped. In autobaud detection (ADBR=1), indicates the counter which determines
the baud rate was running and is now stopped. This means either START bit is finished (if ADNIMP=1), or
Bit 0 is finished (if ADNIMP=0). See New Autobaud Counter Stopped bit and Interrupt, for more details. An
interrupt can be flagged on interrupt_uart if ACIEN=1.
0
Measurement of bit length not finished (in autobaud)
1
Measurement of bit length finished (in autobaud). (write 1 to clear)
10
RIDELT
Ring Indicator Delta. This bit is used in DTE mode to indicate that the Ring Indicator input (RI_B) has
changed state. This flag can generate an interrupt if RI (UCR3[8]) is enabled. RIDELT is cleared by writing
1 to it. Writing 0 to RIDELT has no effect.
0
Ring Indicator input has not changed state
1
Ring Indicator input has changed state (write 1 to clear)
9
RIIN
Ring Indicator Input. This bit is used in DTE mode to reflect the status if the Ring Indicator input (RI_B).
The Ring Indicator input is used to indicate that a ring has occurred. In DCE mode this bit is always zero.
0
Ring Detected
1
No Ring Detected
8
IRINT
Serial Infrared Interrupt Flag. When an edge is detected on the RXD pin during SIR Mode, this flag will
be asserted. This flag can cause an interrupt which can be masked using the control bit ENIRI: UCR4 [8].
0
no edge detected
1
valid edge detected (write 1 to clear)
7
WAKE
Wake. Indicates the start bit is detected. WAKE can generate an interrupt that can be masked using the
WKEN bit. Clear WAKE by writing 1 to it. Writing 0 to WAKE has no effect.
0
start bit not detected
1
start bit detected (write 1 to clear)
6
DCDDELT
Data Carrier Detect Delta. This bit is used in DTE mode to indicate that the Data Carrier Detect input
(DCD_B) has changed state.
This flag can cause an interrupt if DCD (UCR3[9]) is enabled. When in STOP mode, this bit can be used to
wake the processor. In DCE mode this bit is always zero.
0
Data Carrier Detect input has not changed state
1
Data Carrier Detect input has changed state (write 1 to clear)
5
DCDIN
Data Carrier Detect Input. This bit is used in DTE mode reflect the status of the Data Carrier Detect input
(DCD_B). The Data Carrier Detect input is used to indicate that a carrier signal has been detected. In DCE
mode this bit is always zero.
Table continues on the next page...
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3633

<!-- page 3634 -->

UARTx_USR2 field descriptions (continued)
Field
Description
0
Carrier signal Detected
1
No Carrier signal Detected
4
RTSF
RTS Edge Triggered Interrupt Flag. Indicates if a programmed edge is detected on the RTS_B pin. The
RTEC bits select the edge that generates an interrupt (see Table 55-5). RTSF can generate an interrupt
that can be masked using the RTSEN bit. Clear RTSF by writing 1 to it. Writing 0 to RTSF has no effect.
0
Programmed edge not detected on RTS_B
1
Programmed edge detected on RTS_B (write 1 to clear)
3
TXDC
Transmitter Complete. Indicates that the transmit buffer (TxFIFO) and Shift Register is empty; therefore
the transmission is complete. TXDC is cleared automatically when data is written to the TxFIFO.
0
Transmit is incomplete
1
Transmit is complete
2
BRCD
BREAK Condition Detected. Indicates that a BREAK condition was detected by the receiver. Clear
BRCD by writing 1 to it. Writing 0 to BRCD has no effect.
0
No BREAK condition was detected
1
A BREAK condition was detected (write 1 to clear)
1
ORE
Overrun Error. When set to 1, ORE indicates that the receive buffer (RxFIFO) was full (32 chars inside),
and a 33rd character has been fully received. This 33rd character has been discarded. Clear ORE by
writing 1 to it. Writing 0 to ORE has no effect.
0
No overrun error
1
Overrun error (write 1 to clear)
0
RDR
Receive Data Ready-Indicates that at least 1 character is received and written to the RxFIFO. If the
URXD register is read and there is only 1 character in the RxFIFO, RDR is automatically cleared.
0
No receive data ready
1
Receive data ready
55.15.10
UART Escape Character Register (UARTx_UESC)
Address: Base address + 9Ch offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
ESC_CHAR
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
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
1
1
UARTx_UESC field descriptions
Field
Description
31–8
Reserved
This read-only field is reserved and always has the value 0.
ESC_CHAR
UART Escape Character. Holds the selected escape character that all received characters are compared
against to detect an escape sequence.
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3634
NXP Semiconductors

<!-- page 3635 -->

55.15.11
UART Escape Timer Register (UARTx_UTIM)
Address: Base address + A0h offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
TIM
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
UARTx_UTIM field descriptions
Field
Description
31–12
Reserved
This read-only field is reserved and always has the value 0.
TIM
UART Escape Timer. Holds the maximum time interval (in ms) allowed between escape characters. The
escape timer register is programmable in intervals of 2 ms. See Escape Sequence Detection and Table
55-10 for more information on the UART escape sequence detection.
Reset value 0x000 = 2 ms up to 0xFFF = 8.192 s.
55.15.12
UART BRM Incremental Register (UARTx_UBIR)
This register can be written by both software and hardware. When enabling the automatic
baud rate detection feature hardware can write 0x000F value into the UBIR after
finishing detecting baud rate. Hardware has higher priority when both software and
hardware try to write it at the same cycle3.
Please note software reset will reset the register to its reset value.
Address: Base address + A4h offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
INC
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
UARTx_UBIR field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
INC
Incremental Numerator. Holds the numerator value minus one of the BRM ratio (see Binary Rate Multiplier
(BRM)). The UBIR register MUST be updated before the UBMR register for the baud rate to be updated
correctly. If only one register is written to by software, the BRM will ignore this data until the other register
is written to by software. Updating this field using byte accesses is not recommended and is undefined.
3.
Note: The write priority in the new design is not same as the original UART. In the orginal design, software has higher
priority than hardware when writing this register at the same time.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3635

<!-- page 3636 -->

55.15.13
UART BRM Modulator Register (UARTx_UBMR)
This register can be written by both software and hardware. When enabling the automatic
baud rate detection feature hardware can write a proper value into the UBMR based on
detected baud rate. Hardware has higher priority when both software and hardware try to
write it at the same cycle4.
Please note software reset will reset the register to its reset value.
Address: Base address + A8h offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
MOD
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
UARTx_UBMR field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
MOD
Modulator Denominator. Holds the value of the denominator minus one of the BRM ratio (see Binary
Rate Multiplier (BRM)). The UBIR register MUST be updated before the UBMR register for the baud rate
to be updated correctly. If only one register is written to by software, the BRM will ignore this data until the
other register is written to by software. Updating this register using byte accesses is not recommended
and undefined.
55.15.14
UART Baud Rate Count Register (UARTx_UBRC)
Address: Base address + ACh offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
BCNT
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
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
UARTx_UBRC field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
BCNT
Baud Rate Count Register. This read only register is used to count the start bit of the incoming baud rate
(if ADNIMP=1), or start bit + bit0 (if ADNIMP=0). When the measurement is done, the Baud Rate Count
Register contains the number of UART internal clock cycles (clock after divider) present in an incoming bit.
BCNT retains its value until the next Automatic Baud Rate Detection sequence has been initiated. The 16
bit Baud Rate Count register is reset to 4 and stays at hex FFFF in the case of an overflow.
4.
Note: The write priority in the new design is not same as the original UART. In the orginal design, software has higher
priority than hardware when writing this register at the same time.
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3636
NXP Semiconductors

<!-- page 3637 -->

55.15.15
UART One Millisecond Register (UARTx_ONEMS)
NOTE
This register has been expanded from 16 bits to 24 bits. In
previous versions, the 16-bit ONEMS can only support the
maximum 65.535MHz (0xFFFFx1000) ref_clk. To support
4Mbps Bluetooth application with 66.5MHz module_clock, the
value 0x103C4 (66.5M/1000) should be written into this
register. In this case, the 16 bits are not enough to contain the
0x103C4. So this register was expanded to 24 bits to support
high frequency of the ref_clk.
Address: Base address + B0h offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
ONEMS
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
UARTx_ONEMS field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
ONEMS
One Millisecond Register. This 24-bit register must contain the value of the UART internal frequency
(ref_clk in Figure 55-1) divided by 1000. The internal frequency is obtained after the UART BRM internal
divider (F (ref_clk) = F(module_clock) / RFDIV).
In fact this register contains the value corresponding to the number of UART BRM internal clock cycles
present in one millisecond.
The ONEMS (and UTIM) registers value are used in the escape character detection feature (Escape
Sequence Detection) to count the number of clock cycles left between two escape characters. The
ONEMS register is also used in infrared special case mode (IRSC = UCR4[5] = 1'b1), see InfraRed
Special Case (IRSC) Bit.
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3637

<!-- page 3638 -->

55.15.16
UART Test Register (UARTx_UTS)
Address: Base address + B4h offset
Bit
31
30
29
28
27
26
25
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
FRCPERR
LOOP
DBGEN
LOOPIR
RXDBG
0
TXEMPTY
RXEMPTY
TXFULL
RXFULL
0
SOFTRST
W
Reset
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
0
0
0
UARTx_UTS field descriptions
Field
Description
31–14
Reserved
This read-only field is reserved and always has the value 0.
13
FRCPERR
Force Parity Error. Forces the transmitter to generate a parity error if parity is enabled. FRCPERR is
provided for system debugging.
0
Generate normal parity
1
Generate inverted parity (error)
12
LOOP
Loop TX and RX for Test. Controls loopback for test purposes. When LOOP is high, the receiver input is
internally connected to the transmitter and ignores the RXD pin. The transmitter is unaffected by LOOP. If
RXDMUXSEL (UCR3[2]) is set to 1, the loopback is applied on serial and IrDA signals. If RXDMUXSEL is
set to 0, the loopback is only applied on serial signals.
0
Normal receiver operation
1
Internally connect the transmitter output to the receiver input
11
DBGEN
debug_enable_B. This bit controls whether to respond to the debug_req input signal.
0
UART will go into debug mode when debug_req is HIGH
1
UART will not go into debug mode even if debug_req is HIGH
10
LOOPIR
Loop TX and RX for IR Test (LOOPIR). This bit controls loopback from transmitter to receiver in the
InfraRed interface.
0
No IR loop
1
Connect IR transmitter to IR receiver
9
RXDBG
RX_fifo_debug_mode. This bit controls the operation of the RX fifo read counter when in debug mode.
0
rx fifo read pointer does not increment
1
rx_fifo read pointer increments as normal
Table continues on the next page...
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3638
NXP Semiconductors

<!-- page 3639 -->

UARTx_UTS field descriptions (continued)
Field
Description
8–7
Reserved
This read-only field is reserved and always has the value 0.
6
TXEMPTY
TxFIFO Empty. Indicates that the TxFIFO is empty.
0
The TxFIFO is not empty
1
The TxFIFO is empty
5
RXEMPTY
RxFIFO Empty. Indicates the RxFIFO is empty.
0
The RxFIFO is not empty
1
The RxFIFO is empty
4
TXFULL
TxFIFO FULL. Indicates the TxFIFO is full.
0
The TxFIFO is not full
1
The TxFIFO is full
3
RXFULL
RxFIFO FULL. Indicates the RxFIFO is full.
0
The RxFIFO is not full
1
The RxFIFO is full
2–1
Reserved
This read-only field is reserved and always has the value 0.
0
SOFTRST
Software Reset. Indicates the status of the software reset (SRST_B bit of UCR2).
0
Software reset inactive
1
Software reset active
55.15.17
UART RS-485 Mode Control Register (UARTx_UMCR)
Address: Base address + B8h offset
Bit
31
30
29
28
27
26
25
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
SLADDR
0
SADEN
TXB8
SLAM
MDEN
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 55 Universal Asynchronous Receiver/Transmitter (UART)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3639

<!-- page 3640 -->

UARTx_UMCR field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15–8
SLADDR
RS-485 Slave Address Character.
Holds the selected slave adress character that the receiver wil try to detect.
7–4
Reserved
This read-only field is reserved and always has the value 0.
3
SADEN
RS-485 Slave Address Detected Interrupt Enable.
0
Disable RS-485 Slave Address Detected Interrupt
1
Enable RS-485 Slave Address Detected Interrupt
2
TXB8
Transmit RS-485 bit 8 (the ninth bit or 9th bit).
In RS-485 mode, software writes TXB8 bit as the 9th data bit to be transmitted.
0
0 will be transmitted as the RS485 9th data bit
1
1 will be transmitted as the RS485 9th data bit
1
SLAM
RS-485 Slave Address Detect Mode Selection.
0
Select Normal Address Detect mode
1
Select Automatic Address Detect mode
0
MDEN
9-bit data or Multidrop Mode (RS-485) Enable.
0
Normal RS-232 or IrDA mode, see Table 55-1 for detail.
1
Enable RS-485 mode, see Table 55-1 for detail
UART Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3640
NXP Semiconductors

