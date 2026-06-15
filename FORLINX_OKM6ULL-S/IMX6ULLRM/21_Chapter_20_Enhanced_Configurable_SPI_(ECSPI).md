# Chapter 20: Enhanced Configurable SPI (ECSPI)

> Nguồn: `IMX6ULLRM.pdf` — trang 791–820

<!-- page 791 -->

Chapter 20
Enhanced Configurable SPI (ECSPI)
20.1
Overview
The Enhanced Configurable Serial Peripheral Interface (ECSPI) is a full-duplex,
synchronous, four-wire serial communication block.
The ECSPI contains a 64 x 32 receive buffer (RXFIFO) and a 64 x 32 transmit buffer
(TXFIFO). With data FIFOs, the ECSPI allows rapid data communication with fewer
software interrupts. The figure below shows a block diagram of the ECSPI.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
791

<!-- page 792 -->

SPI_RDY
Peripheral Bus Interface
Clock
Generator
PERIODREG
Shift Register
SS[3:0]
SCLK
MISO
MOSI
RXDATA
TXDATA
CONREG
INTREG
DMAREG
TESTREG
State Machine
STATREG
Interrupt Request
DMA Requests
Low-Frequency
Reference Clock
Reference Clock
Figure 20-1. ECSPI Block Diagram
20.1.1
Features
Key features of the ECSPI include:
• Full-duplex synchronous serial interface
• Master/Slave configurable
• Four Chip Select (SS) signals to support multiple peripherals
• Transfer continuation function allows unlimited length data transfers
• 32-bit wide by 64-entry FIFO for both transmit and receive data
• Polarity and phase of the Chip Select (SS) and SPI Clock (SCLK) are configurable
• Direct Memory Access (DMA) support
• Max operation frequency up to the reference clock frequency.
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
792
NXP Semiconductors

<!-- page 793 -->

20.1.2
Modes and Operations
The ECSPI supports the modes described in the indicated sections:
• Master Mode
• Slave Mode
• Low Power Modes
As described in Operations, the ECSPI supports the operations described in the indicated
sections:
• Typical Master Mode
• Master Mode with SPI_RDY
• Master Mode with Wait States
• Master Mode with SS_CTL[3:0] Control
• Master Mode with Phase Control
• Typical Slave Mode
20.2
External Signals
Figure 20-2 shows the ECSPI in master mode connected to four external devices in a
one-way communication link.
ECSPI
(Master)
External
Device 0
External 
Device 1
External
Device 2
External
Device 3
SS[0]
SS[1]
SS[2]
SS[3]
SS[3:0]
SCLK
MOSI
Figure 20-2. Example Connection Diagram
Chapter 20 Enhanced Configurable SPI (ECSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
793

<!-- page 794 -->

20.3
Clocks
The following table describes the clock sources for eCSPI. Please see Clock Controller
Module (CCM) for clock setting, configuration and gating information.
Table 20-1. eCSPI Clocks
Clock name
Clock Root
Description
ipg_clk
ipg_clk_root
Peripheral clock
ipg_clk_32k
ckil_sync_clk_root
Low-frequency reference clock (32kHz)
ipg_clk_per
ecspi_clk_root
eCSPI module clock
ipg_clk_s
ipg_clk_root
Peripheral access clock
20.4
Functional Description
This section provides a complete functional description of the ECSPI. The figure found
here shows the relationship of SCLK and data lines while ECSPI has been configured
with different POL and PHA settings.
MSB
. . .
. . .
. . .
. . .
. . .
. . .
LSB
MSB
. . .
. . .
. . .
. . .
. . .
. . .
LSB
(POL=1, PHA=1) SCLK
(POL=1, PHA=0) SCLK
(POL=0, PHA=1) SCLK
(POL=0, PHA=0) SCLK
MISO
MOSI
Figure 20-3. ECSPI SCLK, MISO, and MOSI Relationship
Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
794
NXP Semiconductors

<!-- page 795 -->

20.4.1
Master Mode
When the ECSPI is configured as a master, it uses a serial link to transfer data between
the ECSPI and an external slave device.
One of the Chip Select (SS) signals and the clock signal (SCLK) are used to transfer data
between two devices. If the external device is a transmit-only device, the ECSPI master's
output port can be ignored and used for other purposes. In order to use the internal
TXFIFO and RXFIFO, two auxiliary output signals, Chip Select (SS) and SPI_RDY, are
used for data transfer rate control. Software can also configure the sample period control
register to a fixed data transfer rate.
20.4.2
Slave Mode
When the ECSPI is configured as a slave, software can configure the ECSPI Control
register to match the external SPI master's timing.
In this configuration, Chip Select (SS) becomes an input signal, and is used to control
data transfers through the Shift register, as well as to load/store the data FIFO.
Slave mode only supports the case when ECSPIx_CONFIGREG[SS_CTL] is cleared.
The accurate burst length should always be specified using the BURST_LENGTH
parameter. ECSPIx_CONFIGREG[SS_CTL] set to 1 is not supported in slave mode.
20.4.3
Low Power Modes
The ECSPI does not operate under low power mode.
It holds its operation when its clock is gated off in master mode. In slave mode, the
ECSPI does not respond when its clock is gated off.
20.4.4
Operations
The information found here describes the ECSPI's operations.
Chapter 20 Enhanced Configurable SPI (ECSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
795

<!-- page 796 -->

20.4.4.1
Typical Master Mode
The ECSPI master uses the Chip Select (SS) signal to enable an external SPI device, and
uses the SCLK signal to transfer data in and out of the Shift register.
The SPI_RDY enables fast data communication with fewer software interrupts. By
programming the ECSPI_PERIODREG register accordingly, the ECSPI can be used for a
fixed data transfer rate.
When the ECSPI is in Master mode the SS, SCLK, and MOSI are output signals, and the
MISO signal is an input.
1
1
0
1
0
0
1
0
0
1
1
0
0
1
1
0
SCLK
MOSI
MISO
SS
Figure 20-4. Typical SPI Burst (8-bit Transfer)
In the above figure, the Chip Select (SS) signal enables the selected external SPI device,
and the SCLK synchronizes the data transfer. The MOSI and MISO signals change on
rising edge of SCLK and the MISO signal is latched on the falling edge of the SCLK.
The figure above shows a data of 0xD2 is shifted out, and a data of 0x66 is shifted in.
20.4.4.1.1
Master Mode with SPI_RDY
By default, the ECSPI does not use the SPI_RDY signal in master mode (MODE =1).
A SPI burst begins when the following events happen:
• The ECSPI is enabled, TXFIFO has data in it, and ECSPI_CONREG[XCH] bit or
the ECSPI_CONREG[SMC] bit is set.
• When the SPI Data Ready Control (ECSPI_CONREG[DRCTL]) bits contains either
01 or 10, the SPI_RDY signal controls when a SPI burst starts.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
796
NXP Semiconductors

<!-- page 797 -->

A SPI burst is defined as a bus transaction that starts when the slave select is asserted and
ends when the slave select is negated. The Chip Select (SS) signal will remain asserted
until all the bits in a SPI burst are shifted out.
If ECSPI_CONREG[DRCTL] is set to 01, the SPI burst can be triggered only if a falling
edge of the SPI_RDY signal has been detected.
The following figure shows the relationship between a SPI burst and the falling edge of
SPI_RDY signal.
SCLK
MOSI
MISO
SS
SPI_RDY
Figure 20-5. Relationship Between a SPI Burst and SPI_RDY: Falling-Edge Triggered
A SPI burst does not start until the falling edge of the SPI_RDY signal is detected. The
next SPI burst starts when the next SPI_RDY falling edge is detected, after the last burst
has finished.
If SPI Data Ready Control (ECSPI_CONREG[DRCTL]) is set to 10, the SPI burst can be
triggered only if the SPI_RDY signal is low.
The following figure shows the relationship between a SPI burst and the SPI_RDY
signal. The SPI burst does not begin until the SPI_RDY signal goes low. The ECSPI will
keep transmitting SPI burst if the SPI_RDY signal remains low.
Chapter 20 Enhanced Configurable SPI (ECSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
797

<!-- page 798 -->

SCLK
MOSI
MISO
SS
SPI_RDY
Figure 20-6. Relationship Between a SPI Burst and SPI_RDY: Low-Level Triggered
20.4.4.1.2
Master Mode with Wait States
Wait states can be inserted between SPI bursts. This provides a way for software to slow
down the SPI burst to meet the timing requirements of a slower SPI device.
The following figure shows wait states inserted between SPI bursts.
SCLK
MOSI
MISO
SS
Wait States
Figure 20-7. SPI Bursts with Wait States
In this case, the number of wait states is controlled by ECSPI_PERIODREG[SAMPLE
PERIOD] and the wait states' clock source is selected by ECSPI_PERIODREG[CSRC].
20.4.4.1.3
Master Mode with SS_CTL[3:0] Control
The SPI SS Control (SS_CTL[3:0]) controls whether the current operation is single burst
or multiple bursts.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
798
NXP Semiconductors

<!-- page 799 -->

When the SPI SS Wave Form Select (SS_CTL[3:0]) is set, the current operation is
multiple bursts transfer. When the SPI SS Wave Form Select (SS_CTL[3:0]) bit is
cleared, the current operation is single burst transfer. A SPI burst can contains multiple
words as defined in the BURST LENGTH field of the ECSPI_CONREG register.
SCLK
MOSI
MISO
SS
Waiting for
software to 
write data to
the TXFIFO
Figure 20-8. SPI Burst While SS_CTL[3:0] is Clear
In Figure 20-8, two 8-bit bursts in the TXFIFO have been combined and transmitted in
one SPI burst. The maximum length of a single SPI burst is defined by the BURST
LENGTH and limited by the FIFO size. (Figure 20-8 corresponds to a BURST LENGTH
of 8.) This provides a way for transferring a longer SPI burst by writing data into
TXFIFO while the ECSPI is transmitting.
SCLK
MOSI
MISO
SS
Figure 20-9. SPI Bursts While SS_CTL[3:0] is Set
In Figure 20-9, two FIFO entries are transmitted, one entry with each SPI burst. The
ECSPI will continue to transmit SPI bursts until the TXFIFO is empty. When wait states
can be inserted between SPI bursts, the SS will negate between SPI bursts until the wait
states finish.
20.4.4.1.4
Master Mode with Phase Control
The Phase Control (ECSPI_CONREG[PHA]) bit controls how the transmit data shifts out
and the receive data shifts in.
Chapter 20 Enhanced Configurable SPI (ECSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
799

<!-- page 800 -->

When the Phase control (ECSPI_CONREG[PHA]) bit is set, the transmit data will shift
out on the rising edge of SCLK, and the receive data is latched on the falling edge of
SCLK. The most-significant bit is output on the first rising SCLK edge.
When ECSPI_CONREG[PHA] is cleared, the transmit data is shifted out on the falling
edge of SCLK and the receive data is latched on the rising edge of SCLK. The MSB is
output when the host processor loads the transmitted data.
Inverting the SCLK polarity does not impact the edge-triggered operations because they
are internal to the serial peripheral interface master. Figure 20-10 shows how SPI burst
works with different POL and PHA configuration.
(POL=1, PHA=1)
(POL=1, PHA=0)
(POL=0, PHA=1)
(POL=0, PHA=0)
MOSI
MISO
SS
SCLK
Figure 20-10. SPI Burst with Different POL and PHA Configurations
20.4.4.2
Typical Slave Mode
When the ECSPI is configured as a slave (Mode = 0), software can configure the ECSPI
Control register to match the external SPI master's timing. In this configuration, SS
becomes an input signal, and is used to latch data in and out of the internal data Shift
registers, as well as to advance the data FIFO.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
800
NXP Semiconductors

<!-- page 801 -->

The SS, SCLK, and MOSI are inputs and MISO is output. Most of the timing diagrams
are similar to the diagrams shown previously for the SPI in Master mode (Mode = 1),
because the inputs come from a SPI master device.
However, the timing is different when SS is used to advance the data FIFO. When the
SS_POL=0 is set while the ECSPI is configured in Slave mode, the data FIFO will
advance on the rising edge of the SS signal. When the polarity is reversed (SS_POL = 1),
the data FIFO will advance on the falling edge of the SS signal.
The figure below shows a SPI burst in which the data FIFO is advanced by the rising
edge of the SS signal.
SCLK
MOSI
MISO
SS
Figure 20-11. Advancing the Data FIFO on the Rising Edge of SS
In the above case, only the most significant 7 bits are loaded to the RXFIFO.
20.4.5
Reset
Whenever a device reset occurs, a reset is performed on the ECSPI, resetting all registers
to their default values.
Software can reset the block using the CONREG[EN] bit; see ECSPI.
20.4.6
Interrupts
Interrupt control provides a way to manage the ECSPI FIFOs:
Chapter 20 Enhanced Configurable SPI (ECSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
801

<!-- page 802 -->

• For transmitting data, software can enable the TXFIFO empty, TXFIFO data request,
and TXFIFO full interrupts to maintain the TXFIFO using an interrupt service
routine.
• For receiving data, software can enable the RXFIFO ready, RXFIFO data request,
and RXFIFO full interrupts to retrieve data from the RXFIFO using an interrupt
service routine.
Other interrupt sources can be used to control or debug the SPI bursts:
• The transfer-completed interrupt means that there is no data left in the TXFIFO and
that the data in the Shift register has been shifted out.
• The RXFIFO overflow interrupt means that the RXFIFO received more than 64
words and will not accept any other words.
Enable CSPI
Enable interrupts
Enable XCH
Wait until all needed data are transferred
TC clear by writing 1
Done
Retrieve data using interrupt service routine
Fill TXFIFO using interrupt service routine
TC interrupt
Figure 20-12. Program Sequence of SPI Burst Using Interrupt Control
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
802
NXP Semiconductors

<!-- page 803 -->

20.4.7
DMA
DMA control provides another method to utilize the FIFOs in the ECSPI. By using DMA
request and acknowledge signals, larger amounts of data can be transferred, and will
reduce interrupts and host processor loading. When the appropriate conditions are
matched, the block will send out a DMA request.
The DMA can deal with the following conditions:
• TXFIFO empty
• TXFIFO data request
• RXFIFO data request
• RXFIFO full
The figure below shows a program sequence of SPI bursts using DMA control.
Enable CSPI
Enable DMA
Enable XCH
Wait until all needed data is transferred
Done
Retrieve data using DMA
Fill TXFIFO using DMA
TC interrupt
Figure 20-13. Program Sequence of SPI Burst Using DMA
20.4.8
Byte Order
The ECSPI does not support byte re-ordering in hardware.
Chapter 20 Enhanced Configurable SPI (ECSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
803

<!-- page 804 -->

20.5
Initialization
This section provides initialization information for ECSPI.
To initialize the block:
1. Clear the EN bit in ECSPI_CONREG to reset the block.
2. Enable the clocks for ECSPI within the CCM.
3. Configure the Control Register and then set the EN bit in the ECSPI_CONREG to
put ECSPI out of reset.
4. Configure corresponding IOMUX for ECSPI external signals.
5. Configure registers of ECSPI properly according to the specifications of the external
SPI device.
20.6
Applications
Configure ECSPI.CONREG, 
ECSPI.CONFIGREG
Configure ECSPI.INTREG (optional)
Configure ECSPI.DMAREG (optional)
Configure ECSPI.PERIODREG (optional)
Fill TXFIFO
Set XCH bit
Poll XCH bit
or wait for TC interrupt
Read Data from RXFIFO
Transfer Completed
Master Mode
Configure ECSPI.CONREG, 
ECSPI.CONFIGREG
Fill TXFIFO
Wait for RXFIFO Interrupt
(Ready, Data Request, Full)
Read Data from RXFIFO
Transfer Completed
Slave Mode
Figure 20-14. Flowchart of the ECSPI Operation
Initialization
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
804
NXP Semiconductors

<!-- page 805 -->

20.7
ECSPI Memory Map/Register Definition
This section includes the block memory map and detailed descriptions of all registers. For
the base address of a particular block instantiation, see the system memory map.
ECSPI memory map
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
200_8000
Receive Data Register (ECSPI1_RXDATA)
32
R
0000_0000h
20.7.1/806
200_8004
Transmit Data Register (ECSPI1_TXDATA)
32
W
0000_0000h
20.7.2/807
200_8008
Control Register (ECSPI1_CONREG)
32
R/W
0000_0000h
20.7.3/807
200_800C
Config Register (ECSPI1_CONFIGREG)
32
R/W
0000_0000h
20.7.4/810
200_8010
Interrupt Control Register (ECSPI1_INTREG)
32
R/W
0000_0000h
20.7.5/812
200_8014
DMA Control Register (ECSPI1_DMAREG)
32
R/W
0000_0000h
20.7.6/813
200_8018
Status Register (ECSPI1_STATREG)
32
R/W
0000_0003h
20.7.7/815
200_801C
Sample Period Control Register (ECSPI1_PERIODREG)
32
R/W
0000_0000h
20.7.8/816
200_8020
Test Control Register (ECSPI1_TESTREG)
32
R/W
0000_0000h
20.7.9/818
200_8040
Message Data Register (ECSPI1_MSGDATA)
32
W
0000_0000h
20.7.10/
819
200_C000
Receive Data Register (ECSPI2_RXDATA)
32
R
0000_0000h
20.7.1/806
200_C004
Transmit Data Register (ECSPI2_TXDATA)
32
W
0000_0000h
20.7.2/807
200_C008
Control Register (ECSPI2_CONREG)
32
R/W
0000_0000h
20.7.3/807
200_C00C
Config Register (ECSPI2_CONFIGREG)
32
R/W
0000_0000h
20.7.4/810
200_C010
Interrupt Control Register (ECSPI2_INTREG)
32
R/W
0000_0000h
20.7.5/812
200_C014
DMA Control Register (ECSPI2_DMAREG)
32
R/W
0000_0000h
20.7.6/813
200_C018
Status Register (ECSPI2_STATREG)
32
R/W
0000_0003h
20.7.7/815
200_C01C
Sample Period Control Register (ECSPI2_PERIODREG)
32
R/W
0000_0000h
20.7.8/816
200_C020
Test Control Register (ECSPI2_TESTREG)
32
R/W
0000_0000h
20.7.9/818
200_C040
Message Data Register (ECSPI2_MSGDATA)
32
W
0000_0000h
20.7.10/
819
201_0000
Receive Data Register (ECSPI3_RXDATA)
32
R
0000_0000h
20.7.1/806
201_0004
Transmit Data Register (ECSPI3_TXDATA)
32
W
0000_0000h
20.7.2/807
201_0008
Control Register (ECSPI3_CONREG)
32
R/W
0000_0000h
20.7.3/807
201_000C
Config Register (ECSPI3_CONFIGREG)
32
R/W
0000_0000h
20.7.4/810
201_0010
Interrupt Control Register (ECSPI3_INTREG)
32
R/W
0000_0000h
20.7.5/812
201_0014
DMA Control Register (ECSPI3_DMAREG)
32
R/W
0000_0000h
20.7.6/813
201_0018
Status Register (ECSPI3_STATREG)
32
R/W
0000_0003h
20.7.7/815
201_001C
Sample Period Control Register (ECSPI3_PERIODREG)
32
R/W
0000_0000h
20.7.8/816
Table continues on the next page...
Chapter 20 Enhanced Configurable SPI (ECSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
805

<!-- page 806 -->

ECSPI memory map (continued)
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
201_0020
Test Control Register (ECSPI3_TESTREG)
32
R/W
0000_0000h
20.7.9/818
201_0040
Message Data Register (ECSPI3_MSGDATA)
32
W
0000_0000h
20.7.10/
819
201_4000
Receive Data Register (ECSPI4_RXDATA)
32
R
0000_0000h
20.7.1/806
201_4004
Transmit Data Register (ECSPI4_TXDATA)
32
W
0000_0000h
20.7.2/807
201_4008
Control Register (ECSPI4_CONREG)
32
R/W
0000_0000h
20.7.3/807
201_400C
Config Register (ECSPI4_CONFIGREG)
32
R/W
0000_0000h
20.7.4/810
201_4010
Interrupt Control Register (ECSPI4_INTREG)
32
R/W
0000_0000h
20.7.5/812
201_4014
DMA Control Register (ECSPI4_DMAREG)
32
R/W
0000_0000h
20.7.6/813
201_4018
Status Register (ECSPI4_STATREG)
32
R/W
0000_0003h
20.7.7/815
201_401C
Sample Period Control Register (ECSPI4_PERIODREG)
32
R/W
0000_0000h
20.7.8/816
201_4020
Test Control Register (ECSPI4_TESTREG)
32
R/W
0000_0000h
20.7.9/818
201_4040
Message Data Register (ECSPI4_MSGDATA)
32
W
0000_0000h
20.7.10/
819
20.7.1
Receive Data Register (ECSPIx_RXDATA)
The Receive Data register (ECSPI_RXDATA) is a read-only register that forms the top
word of the 64 x 32 receive FIFO. This register holds the data received from an external
SPI device during a data transaction. Only word-sized read operations are allowed.
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
ECSPI_RXDATA
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ECSPIx_RXDATA field descriptions
Field
Description
ECSPI_RXDATA Receive Data. This register holds the top word of the receive data FIFO. The FIFO is advanced for each
read of this register. The data read is undefined when the Receive Data Ready (RR) bit in the Interrupt
Control/Status register is cleared. Zeros are read when ECSPI is disabled.
ECSPI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
806
NXP Semiconductors

<!-- page 807 -->

20.7.2
Transmit Data Register (ECSPIx_TXDATA)
The Transmit Data (ECSPI_TXDATA) register is a write-only data register that forms
the bottom word of the 64 x 32 TXFIFO. The TXFIFO can be written to as long as it is
not full, even when the SPI Exchange bit (XCH) in ECSPI_CONREG is set. This allows
software to write to the TXFIFO during a SPI data exchange process. Writes to this
register are ignored when the ECSPI is disabled (ECSPI_CONREG[EN] bit is cleared).
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
W
ECSPI_TXDATA
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ECSPIx_TXDATA field descriptions
Field
Description
ECSPI_TXDATA Transmit Data. This register holds the top word of data loaded into the FIFO. Data written to this register
must be a word operation. The number of bits actually transmitted is determined by the BURST_LENGTH
field of the corresponding SPI Control register. If this field contains more bits than the number specified by
BURST_LENGTH, the extra bits are ignored. For example, to transfer 10 bits of data, a 32-bit word must
be written to this register. Bits 9-0 are shifted out and bits 31-10 are ignored. When the ECSPI is operating
in Slave mode, zeros are shifted out when the FIFO is empty. Zeros are read when ECSPI is disabled.
20.7.3
Control Register (ECSPIx_CONREG)
The Control Register (ECSPI_CONREG) allows software to enable the ECSPI ,
configure its operating modes, specify the divider value, and SPI_RDY control signal,
and define the transfer length.
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
BURST_LENGTH
CHANNEL_
SELECT
DRCTL
W
Reset
0
0
0
0
0
0
0
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
PRE_DIVIDER
POST_DIVIDER
CHANNEL_MODE
SMC
XCH
HT
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
Chapter 20 Enhanced Configurable SPI (ECSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
807

<!-- page 808 -->

ECSPIx_CONREG field descriptions
Field
Description
31–20
BURST_
LENGTH
Burst Length. This field defines the length of a SPI burst to be transferred. The Chip Select (SS) will
remain asserted until all bits in a SPI burst are shifted out. A maximum of 2^12 bits can be transferred in a
single SPI burst.
In master mode, it controls the number of bits per SPI burst. Since the shift register always loads 32-bit
data from transmit FIFO, only the n least-significant (n = BURST LENGTH + 1) will be shifted out. The
remaining bits will be ignored.
Number of Valid Bits in a SPI burst.
0x000
A SPI burst contains the 1 LSB in a word.
0x001
A SPI burst contains the 2 LSB in a word.
0x002
A SPI burst contains the 3 LSB in a word.
...
0x01F
A SPI burst contains all 32 bits in a word.
0x020
A SPI burst contains the 1 LSB in first word and all 32 bits in second word.
0x021
A SPI burst contains the 2 LSB in first word and all 32 bits in second word.
...
0xFFE
A SPI burst contains the 31 LSB in first word and 2^7 -1 words.
0xFFF
A SPI burst contains 2^7 words.
19–18
CHANNEL_
SELECT
SPI CHANNEL SELECT bits. Select one of four external SPI Master/Slave Devices. In master mode,
these two bits select the external slave devices by asserting the Chip Select (SSn) outputs. Only the
selected Chip Select (SSn) signal can be active at a given time; the remaining three signals will be
negated.
00
Channel 0 is selected. Chip Select 0 (SS0) will be asserted.
01
Channel 1 is selected. Chip Select 1 (SS1) will be asserted.
10
Channel 2 is selected. Chip Select 2 (SS2) will be asserted.
11
Channel 3 is selected. Chip Select 3 (SS3) will be asserted.
17–16
DRCTL
SPI Data Ready Control. This field selects the utilization of the SPI_RDY signal in master mode. ECSPI
checks this field before it starts an SPI burst.
00
The SPI_RDY signal is a don't care.
01
Burst will be triggered by the falling edge of the SPI_RDY signal (edge-triggered).
10
Burst will be triggered by a low level of the SPI_RDY signal (level-triggered).
11
Reserved.
15–12
PRE_DIVIDER
SPI Pre Divider. ECSPI uses a two-stage divider to generate the SPI clock. This field defines the pre-
divider of the reference clock.
0000
Divide by 1.
0001
Divide by 2.
0010
Divide by 3.
...
1101
Divide by 14.
1110
Divide by 15.
1111
Divide by 16.
11–8
POST_DIVIDER
SPI Post Divider. ECSPI uses a two-stage divider to generate the SPI clock. This field defines the post-
divider of the reference clock using the equation: 2 n .
0000
Divide by 1.
0001
Divide by 2.
Table continues on the next page...
ECSPI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
808
NXP Semiconductors

<!-- page 809 -->

ECSPIx_CONREG field descriptions (continued)
Field
Description
0010
Divide by 4.
...
1110
Divide by 2 14 .
1111
Divide by 2 15 .
7–4
CHANNEL_
MODE
SPI CHANNEL MODE selects the mode for each SPI channel.
CHANNEL MODE[3] is for SPI channel 3.
CHANNEL MODE[2] is for SPI channel 2.
CHANNEL MODE[1] is for SPI channel 1.
CHANNEL MODE[0] is for SPI channel 0.
0
Slave mode.
1
Master mode.
3
SMC
Start Mode Control. This bit applies only to channels configured in Master mode (CHANNEL MODE = 1).
It controls how the ECSPI starts a SPI burst, either through the SPI exchange bit, or immediately when the
TXFIFO is written to.
0
SPI Exchange Bit (XCH) controls when a SPI burst can start. Setting the XCH bit will start a SPI burst
or multiple bursts. This is controlled by the SPI SS Wave Form Select (SS_CTL). Refer to XCH and
SS_CTL descriptions.
1
Immediately starts a SPI burst when data is written in TXFIFO.
2
XCH
SPI Exchange Bit. This bit applies only to channels configured in Master mode (CHANNEL MODE = 1).
If the Start Mode Control (SMC) bit is cleared, writing a 1 to this bit starts one SPI burst or multiple SPI
bursts according to the SPI SS Wave Form Select (SS_CTL). The XCH bit remains set while either the
data exchange is in progress, or when the ECSPI is waiting for an active input if SPIRDY is enabled
through DRCTL. This bit is cleared automatically when all data in the TXFIFO and the shift register has
been shifted out.
0
Idle.
1
Initiates exchange (write) or busy (read).
1
HT
Hardware Trigger Enable. This bit is used in master mode only. It enables hardware trigger (HT) mode.
Note, HT mode is not supported by this product.
0
Disable HT mode.
1
Enable HT mode.
0
EN
SPI Block Enable Control. This bit enables the ECSPI. This bit must be set before writing to other registers
or initiating an exchange. Writing zero to this bit disables the block and resets the internal logic with the
exception of the ECSPI_CONREG. The block's internal clocks are gated off whenever the block is
disabled.
0
Disable the block.
1
Enable the block.
Chapter 20 Enhanced Configurable SPI (ECSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
809

<!-- page 810 -->

20.7.4
Config Register (ECSPIx_CONFIGREG)
The Config Register (ECSPI_CONFIGREG) allows software to configure each SPI
channel, configure its operating modes, specify the phase and polarity of the clock,
configure the Chip Select (SS), and define the HT transfer length. Note, HT mode is not
supported by this product.
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
15
14
13
12
11
10
9
8
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
HT_LENGTH
SCLK_CTL
DATA_CTL
SS_POL
SS_CTL
SCLK_POL
SCLK_PHA
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ECSPIx_CONFIGREG field descriptions
Field
Description
31–29
-
This field is reserved.
Reserved
28–24
HT_LENGTH
HT LENGTH. This field defines the message length in HT Mode. Note, HT mode is not supported by this
product.
The length in bits of one message is (HT LENGTH + 1).
23–20
SCLK_CTL
SCLK CTL. This field controls the inactive state of SCLK for each SPI channel.
SCLK CTL[3] is for SPI channel 3.
SCLK CTL[2] is for SPI channel 2.
SCLK CTL[1] is for SPI channel 1.
SCLK CTL[0] is for SPI channel 0.
0
Stay low.
1
Stay high.
19–16
DATA_CTL
DATA CTL. This field controls inactive state of the data line for each SPI channel.
DATA CTL[3] is for SPI channel 3.
DATA CTL[2] is for SPI channel 2.
DATA CTL[1] is for SPI channel 1.
DATA CTL[0] is for SPI channel 0.
0
Stay high.
1
Stay low.
15–12
SS_POL
SPI SS Polarity Select. In both Master and Slave modes, this field selects the polarity of the Chip Select
(SS) signal.
SS POL[3] is for SPI channel 3.
SS POL[2] is for SPI channel 2.
SS POL[1] is for SPI channel 1.
SS POL[0] is for SPI channel 0.
Table continues on the next page...
ECSPI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
810
NXP Semiconductors

<!-- page 811 -->

ECSPIx_CONFIGREG field descriptions (continued)
Field
Description
0
Active low.
1
Active high.
11–8
SS_CTL
SPI SS Wave Form Select. In master mode, this field controls the output wave form of the Chip Select
(SS) signal when the SMC (Start Mode Control) bit is cleared. The SS_CTL are ignored if the SMC bit is
set.
SS CTL[3] is for SPI channel 3.
SS CTL[2] is for SPI channel 2.
SS CTL[1] is for SPI channel 1.
SS CTL[0] is for SPI channel 0.
In slave mode, this bit controls when the SPI burst is completed.
An SPI burst is completed by the Chip Select (SS) signal edges. (SSPOL = 0: rising edge; SSPOL = 1:
falling edge) The RXFIFO is advanced whenever a Chip Select (SS) signal edge is detected or the shift
register contains 32-bits of valid data.
0
In master mode - only one SPI burst will be transmitted.
1
In master mode - Negate Chip Select (SS) signal between SPI bursts. Multiple SPI bursts will be
transmitted. The SPI transfer will automatically stop when the TXFIFO is empty.
1
Reserved
7–4
SCLK_POL
SPI Clock Polarity Control. This field controls the polarity of the SCLK signal. See Figure 20-10 for more
information.
SCLK_POL[3] is for SPI channel 3.
SCLK_POL[2] is for SPI channel 2.
SCLK_POL[1] is for SPI channel 1.
SCLK_POL[0] is for SPI channel 0.
0
Active high polarity (0 = Idle).
1
Active low polarity (1 = Idle).
SCLK_PHA
SPI Clock/Data Phase Control. This field controls the clock/data phase relationship. See Figure 20-10 for
more information.
SCLK PHA[3] is for SPI channel 3.
SCLK PHA[2] is for SPI channel 2.
SCLK PHA[1] is for SPI channel 1.
SCLK PHA[0] is for SPI channel 0.
0
Phase 0 operation.
1
Phase 1 operation.
Chapter 20 Enhanced Configurable SPI (ECSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
811

<!-- page 812 -->

20.7.5
Interrupt Control Register (ECSPIx_INTREG)
The Interrupt Control Register (ECSPI_INTREG) enables the generation of interrupts to
the host processor. If the ECSPI is disabled, this register reads zero.
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
TCEN
ROEN
RFEN
RDREN
RRE
N
TFEN
TDREN
TEEN
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ECSPIx_INTREG field descriptions
Field
Description
31–8
-
This field is reserved.
Reserved
7
TCEN
Transfer Completed Interrupt enable. This bit enables the Transfer Completed Interrupt.
0
Disable
1
Enable
6
ROEN
RXFIFO Overflow Interrupt enable. This bit enables the RXFIFO Overflow Interrupt.
0
Disable
1
Enable
5
RFEN
RXFIFO Full Interrupt enable. This bit enables the RXFIFO Full Interrupt.
0
Disable
1
Enable
4
RDREN
RXFIFO Data Request Interrupt enable. This bit enables the RXFIFO Data Request Interrupt when the
number of data entries in the RXFIFO is greater than RX_THRESHOLD.
0
Disable
1
Enable
3
RREN
RXFIFO Ready Interrupt enable. This bit enables the RXFIFO Ready Interrupt.
0
Disable
1
Enable
Table continues on the next page...
ECSPI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
812
NXP Semiconductors

<!-- page 813 -->

ECSPIx_INTREG field descriptions (continued)
Field
Description
2
TFEN
TXFIFO Full Interrupt enable. This bit enables the TXFIFO Full Interrupt.
0
Disable
1
Enable
1
TDREN
TXFIFO Data Request Interrupt enable. This bit enables the TXFIFO Data Request Interrupt when the
number of data entries in the TXFIFO is less than or equal to TX_THRESHOLD.
0
Disable
1
Enable
0
TEEN
TXFIFO Empty Interrupt enable. This bit enables the TXFIFO Empty Interrupt.
0
Disable
1
Enable
20.7.6
DMA Control Register (ECSPIx_DMAREG)
The Direct Memory Access Control Register (ECSPI_DMAREG) provides software a
way to use an on-chip DMA controller for ECSPI data. Internal DMA request signals
enable direct data transfers between the ECSPI FIFOs and system memory. The ECSPI
sends out DMA requests when the appropriate FIFO conditions are matched.
If the ECSPI is disabled, this register is read as 0.
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
R
RXTDEN
Reserved
RX_DMA_LENGTH
RXDEN
Reserved
RX_THRESHOLD
W
Reset
0
0
0
0
0
0
0
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
TEDEN
Reserved
TX_THRESHOLD
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 20 Enhanced Configurable SPI (ECSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
813

<!-- page 814 -->

ECSPIx_DMAREG field descriptions
Field
Description
31
RXTDEN
RXFIFO TAIL DMA Request/Interrupt Enable. This bit enables an internal counter that is increased at
each read of the RXFIFO. This counter is cleared automatically when it reaches RX DMA LENGTH. If the
number of words remaining in the RXFIFO is greater than or equal to RX DMA LENGTH, a DMA request/
interrupt is generated even if it is less than or equal to RX_THRESHOLD.
0
Disable
1
Enable
30
-
This field is reserved.
Reserved
29–24
RX_DMA_
LENGTH
RX DMA LENGTH. This field defines the burst length of a DMA operation. Applies only when RXTDEN is
set.
23
RXDEN
RXFIFO DMA Request Enable. This bit enables/disables the RXFIFO DMA Request.
0
Disable
1
Enable
22
-
This field is reserved.
Reserved
21–16
RX_
THRESHOLD
RX THRESHOLD. This field defines the FIFO threshold that triggers a RX DMA/INT request.
A RX DMA/INT request is issued when the number of data entries in the RXFIFO is greater than
RX_THRESHOLD.
15–8
-
This field is reserved.
Reserved
7
TEDEN
TXFIFO Empty DMA Request Enable. This bit enables/disables the TXFIFO Empty DMA Request.
0
Disable
1
Enable
6
-
This field is reserved.
Reserved
TX_
THRESHOLD
TX THRESHOLD. This field defines the FIFO threshold that triggers a TX DMA/INT request.
A TX DMA/INT request is issued when the number of data entries in the TXFIFO is not greater than
TX_THRESHOLD.
ECSPI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
814
NXP Semiconductors

<!-- page 815 -->

20.7.7
Status Register (ECSPIx_STATREG)
The ECSPI Status Register (ECSPI_STATREG) reflects the status of the ECSPI's
operating condition. If the ECSPI is disabled, this register reads 0x0000_0003.
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
TC
RO
RF
RDR
RR
TF
TDR
TE
W
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
1
1
ECSPIx_STATREG field descriptions
Field
Description
31–8
-
This field is reserved.
Reserved
7
TC
Transfer Completed Status bit. Writing 1 to this bit clears it.
0
Transfer in progress.
1
Transfer completed.
6
RO
RXFIFO Overflow. When set, this bit indicates that RXFIFO has overflowed. Writing 1 to this bit clears it.
0
RXFIFO has no overflow.
1
RXFIFO has overflowed.
5
RF
RXFIFO Full. This bit is set when the RXFIFO is full.
0
Not Full.
1
Full.
4
RDR
RXFIFO Data Request.
0
When RXTDE is set - Number of data entries in the RXFIFO is not greater than RX_THRESHOLD.
1
When RXTDE is set - Number of data entries in the RXFIFO is greater than RX_THRESHOLD or a
DMA TAIL DMA condition exists.
0
When RXTDE is clear - Number of data entries in the RXFIFO is not greater than RX_THRESHOLD.
1
When RXTDE is clear - Number of data entries in the RXFIFO is greater than RX_THRESHOLD.
3
RR
RXFIFO Ready. This bit is set when one or more words are stored in the RXFIFO.
0
No valid data in RXFIFO.
1
More than 1 word in RXFIFO.
2
TF
TXFIFO Full. This bit is set when if the TXFIFO is full.
Table continues on the next page...
Chapter 20 Enhanced Configurable SPI (ECSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
815

<!-- page 816 -->

ECSPIx_STATREG field descriptions (continued)
Field
Description
0
TXFIFO is not Full.
1
TXFIFO is Full.
1
TDR
TXFIFO Data Request.
0
Number of valid data slots in TXFIFO is greater than TX_THRESHOLD.
1
Number of valid data slots in TXFIFO is not greater than TX_THRESHOLD.
0
TE
TXFIFO Empty. This bit is set if the TXFIFO is empty.
0
TXFIFO contains one or more words.
1
TXFIFO is empty.
20.7.8
Sample Period Control Register (ECSPIx_PERIODREG)
The Sample Period Control Register (ECSPI_PERIODREG) provides software a way to
insert delays (wait states) between consecutive SPI transfers. Control bits in this register
select the clock source for the sample period counter and the delay count indicating the
number of wait states to be inserted between data transfers.
The delay counts apply only when the current channel is operating in Master mode
(ECSPI_CONREG[CHANNEL MODE] = 1).ECSPI_PERIODREG also contains the
CSD CTRL field used to insert a delay between the Chip Select's active edge and the first
SPI Clock edge.
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
R
Reserved
CSD_CTL
W
Reset
0
0
0
0
0
0
0
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
CSRC
SAMPLE_PERIOD
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ECSPIx_PERIODREG field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
Table continues on the next page...
ECSPI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
816
NXP Semiconductors

<!-- page 817 -->

ECSPIx_PERIODREG field descriptions (continued)
Field
Description
21–16
CSD_CTL
Chip Select Delay Control bits. This field defines how many SPI clocks will be inserted between the chip
select's active edge and the first SPI clock edge. The range is from 0 to 63.
15
CSRC
Clock Source Control. This bit selects the clock source for the sample period counter.
0
SPI Clock (SCLK)
1
Low-Frequency Reference Clock (32.768 KHz)
SAMPLE_
PERIOD
Sample Period Control. These bits control the number of wait states to be inserted in data transfers.
During the idle clocks, the state of the SS output will operate according to the SS_CTL control field in the
ECSPI_CONREG register.
0x0000
0 wait states inserted
0x0001
1 wait state inserted
...
...
0x7FFE
32766 wait states inserted
0x7FFF
32767 wait states inserted
Chapter 20 Enhanced Configurable SPI (ECSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
817

<!-- page 818 -->

20.7.9
Test Control Register (ECSPIx_TESTREG)
The Test Control Register (ECSPI_TESTREG) provides software a mechanism to
internally connect the receive and transmit devices of the ECSPI, and monitor the
contents of the receive and transmit FIFOs.
Address: Base address + 20h offset
Bit
31
30
29
28
27
26
25
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
LBC
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
Reserv
ed
RXCNT
Reserved
TXCNT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ECSPIx_TESTREG field descriptions
Field
Description
31
LBC
Loop Back Control. This bit is used in Master mode only. When this bit is set, the ECSPI connects the
transmitter and receiver sections internally, and the data shifted out from the most-significant bit of the
shift register is looped back into the least-significant bit of the Shift register. In this way, a self-test of the
complete transmit/receive path can be made. The output pins are not affected, and the input pins are
ignored.
0
Not connected.
1
Transmitter and receiver sections internally connected for Loopback.
30–28
-
This field is reserved.
Reserved, all bits should be ignored.
27–15
-
This field is reserved.
Reserved
14–8
RXCNT
RXFIFO Counter. This field indicates the number of words in the RXFIFO.
Table continues on the next page...
ECSPI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
818
NXP Semiconductors

<!-- page 819 -->

ECSPIx_TESTREG field descriptions (continued)
Field
Description
7
-
This field is reserved.
Reserved
TXCNT
TXFIFO Counter. This field indicates the number of words in the TXFIFO.
20.7.10
Message Data Register (ECSPIx_MSGDATA)
The Message Data Register (ECSPI_MSGDATA) forms the top word of the 16 x 32
MSG Data FIFO. Only word-size accesses are allowed for this register. Reads to this
register return zero, and writes to this register store data in the MSG Data FIFO.
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
W
ECSPI_MSGDATA
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ECSPIx_MSGDATA field descriptions
Field
Description
ECSPI_
MSGDATA
ECSPI_MSGDATA holds the top word of MSG Data FIFO. The MSG Data FIFO is advanced for each
write of this register. The data read is zero. The data written to this register is stored in the MSG Data
FIFO.
Chapter 20 Enhanced Configurable SPI (ECSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
819

<!-- page 820 -->

ECSPI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
820
NXP Semiconductors

