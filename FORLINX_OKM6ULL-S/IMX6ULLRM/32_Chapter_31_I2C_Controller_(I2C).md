# Chapter 31: I2C Controller (I2C)

> Nguồn: `IMX6ULLRM.pdf` — trang 1445–1468

<!-- page 1445 -->

Chapter 31
I2C Controller (I2C)
31.1
Overview
This chapter describes block-level operation and programming of I2C. The chapter is
intended for a block-driver software developer. To understand how the block is integrated
at the SoC level, a system software developer should see discussions of the block in the
appropriate SoC-level chapter(s).
References: This document assumes an understanding of the following document:
• The I2C Bus Specification, Version 2.1, by Philips Semiconductor
The Inter IC (I2C) provides functionality of a standard I2C slave and master. The I2C is
designed to be compatible with the standard NXP I2C bus protocol.
NOTE
independent I2C channels are available.
I2C is a two-wire, bidirectional serial bus that provides a simple, efficient method of data
exchange, minimizing the interconnection between devices. This bus is suitable for
applications requiring occasional communications over a short distance between many
devices. The flexible I2C standard allows additional devices to be connected to the bus
for expansion and system development. See the connection diagram in the figure below.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1445

<!-- page 1446 -->

I2Cn_SCL (output)
I2Cn_SCL (input)
I2Cn_SDA (output)
I2Cn_SDA (input)
I2Cn_SCL (output)
I2Cn_SCL (input)
I2Cn_SDA (output)
I2Cn_SDA (input)
Rp
Rp
Pull-up
resistors
+Vdd
I2Cn_SDA (Serial Data line)
I2Cn_SCL (Serial Clock line)
Device 1
Device 2
Figure 31-1. Connection of devices to I2C bus
The I2C interface speed is dependent on the I2C bus loading and timing characteristics.
For pin requirement details, see The I2C Bus Specification. The I2C system is a true
multimaster bus including arbitration and collision detection that prevents data corruption
if multiple devices attempt to control the bus simultaneously. This feature supports
complex applications with multiprocessor control and can be used for rapid testing and
alignment of end products through external connections to an assembly-line computer.
The figure below shows the block diagram of I2C.
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1446
NXP Semiconductors

<!-- page 1447 -->

Clock
Control
Input
Sync
Start,  Stop,
and
Arbitration
Control
In / Out
Data
Shift
Register
Address
Compare
Module Clock Domain
  I2Cn_SCL      I2Cn_SDA
Signals Connected Off-Chip
Address Decode
Data MUX
Address
Data
Peripheral Bus
Interrupt Request
Peripheral Bus Clock Domain
I2C Frequency
Divider Register
(I2C_IFDR)
I2C Control
Register
(I2C_I2CR)
I2C Status
Register
(I2C_I2SR)
I2C Data
I/O Register
(I2C_I2DR)
I2C Address
Register
(I2C_IADR)
Figure 31-2. I2C block diagram
31.1.1
Features
The I2C has the following key features:
• Compatibility with I2C bus standard
• Multimaster operation
• Software programmability for one of 64 different serial clock frequencies
• Software-selectable acknowledge bit
• Interrupt-driven, byte-by-byte data transfer
• Arbitration-lost interrupt with automatic mode switching from master to slave
Chapter 31 I2C Controller (I2C)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1447

<!-- page 1448 -->

• Calling address identification interrupt
• Start and stop signal generation/detection
• Repeated Start signal generation
• Acknowledge bit generation/detection
• Bus-busy detection
31.1.2
Modes and operations
The I2C operates primarily in two functional modes: Standard mode and Fast mode.
• In Standard mode, I2C supports the data transfer rates up to 100 kbits/s.
• In Fast mode, data transfer rates up to 400 kbits/s can be achieved. Per block
operation, there is no special configuration required for Fast or Standard mode. It is
the data transfer rate that distinguishes Standard and Fast mode.
31.2
External Signals
This section discusses I2C signals that connect off-chip.
For I2C compliance, all devices connected to the I2Cn_SCL and I2Cn_SDA signals must
have open-drain or open-collector outputs. The logic AND function is implemented on
both lines with external pull-up resistors.
Inputs of I2Cn_SCL and I2Cn_SDA also need to be manually enabled by setting the
SION bit in the IOMUX after the corresponding PADs are selected as I2C function.
The table below describes all I2C signals that connect off-chip.
Table 31-1. I2C External Signals
Signal
Description
Pad
Mode
Direction
I2C1_SCL
Serial Clock
CSI_PIXCLK
ALT3
IO
GPIO1_IO02
ALT0
UART4_TX_DATA
ALT2
I2C1_SDA
Serial Data
CSI_MCLK
ALT3
IO
GPIO1_IO03
ALT0
UART4_RX_DATA
ALT2
I2C2_SCL
Serial Clock
CSI_HSYNC
ALT3
IO
GPIO1_IO00
ALT0
UART5_TX_DATA
ALT2
I2C2_SDA
Serial Data
CSI_VSYNC
ALT3
IO
Table continues on the next page...
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1448
NXP Semiconductors

<!-- page 1449 -->

Table 31-1. I2C External Signals (continued)
Signal
Description
Pad
Mode
Direction
GPIO1_IO01
ALT0
UART5_RX_DATA
ALT2
I2C3_SCL
Serial Clock
ENET2_RX_DATA0
ALT3
IO
LCD_DATA01
ALT4
UART1_TX_DATA
ALT2
I2C3_SDA
Serial Data
ENET2_RX_DATA1
ALT3
IO
LCD_DATA00
ALT4
UART1_RX_DATA
ALT2
I2C4_SCL
Serial Clock
ENET2_RX_EN
ALT3
IO
LCD_DATA03
ALT4
UART2_TX_DATA
ALT2
I2C4_SDA
Serial Data
ENET2_TX_DATA0
ALT3
IO
LCD_DATA02
ALT4
UART2_RX_DATA
ALT2
31.3
Clocks
There are two input clocks for I2C.
The following table describes the clock sources for I2C. Please see Clock Controller
Module (CCM) for clock setting, configuration and gating information.
Table 31-2. I2C Clocks
Clock name
Clock Root
Description
ipg_clk_patref
perclk_clk_root
Module clock
ipg_clk_s
ipg_clk_root
Peripheral access clock
• Peripheral clock: This clock is used for peripheral bus register read/writes.
• Module clock: This is the functional clock of the I2C. The serial bit clock frequency
is derived from the module clock. The module clock and peripheral clocks are
synchronous with each other. The minimum frequency of the module clock should be
12.8 MHz for Fast mode to achieve 400-kbps operation.
Chapter 31 I2C Controller (I2C)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1449

<!-- page 1450 -->

31.4
Functional description
This section provides a complete functional description of the block.
31.4.1
I2C system configuration
After a reset, the I2C defaults to Slave Receive operations. Thus, when not operating as a
master or responding to a slave transmit address, the I2C defaults to the Slave Receive
state.
For exceptions, see Initialization sequence.
NOTE
The I2C is designed to be compatible with the PhilipsTM I2C
bus protocol. For information on system configuration,
protocol, and restrictions, see the I2C Bus Specification, version
2.1, by Philips Semiconductors. The I2C supports Standard and
Fast modes only.
31.4.2
Arbitration procedure
If multiple devices simultaneously request the bus, the bus clock is determined by a
synchronization procedure in which the low period equals the longest clock-low period
among the devices, and the high period equals the shortest. A data arbitration procedure
determines the relative priority of competing devices.
A device loses arbitration if it sends logic high while another sends logic low; it
immediately switches to Slave Receive mode and stops driving I2Cn_SDA. In this case,
the transition from master to Slave mode does not generate a Stop condition. Meanwhile,
hardware sets the arbitration lost bit in the I2C Status register (I2C_I2SR[IAL] to indicate
loss of arbitration).
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1450
NXP Semiconductors

<!-- page 1451 -->

31.4.3
Clock synchronization
Because wire-AND logic is used, a high-to-low transition on SCL affects devices
connected to the bus. Devices start counting their low period when the master drives SCL
low. When a device clock goes low, it holds SCL low until the Clock High state is
reached. However, the low-to-high change in this device clock may not change the state
of SCL if another device clock is still in its low period. Therefore, the device with the
longest low period holds the synchronized clock SCL low.
Devices with shorter low periods enter a High Wait state during this time (see Figure
31-3). When all devices involved have counted off their low periods, the synchronized
clock SCL is released and pulled high. There is then no difference between device clocks
and the state of SCL, so all of the devices start counting their high periods. The first
device to complete its high period pulls SCL low again.
Wait
Start counting high period
Internal Counter Reset
SCL1
SCL2
SCL
Figure 31-3. Synchronized clock SCL
31.4.4
Handshaking
The clock synchronization mechanism can be used as a handshake in data transfers. Slave
devices can hold SCL low after completing one byte transfer (9 bits). In such a case, the
clock mechanism halts the bus clock and forces the master clock into a Wait state until
the slave releases SCL.
Chapter 31 I2C Controller (I2C)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1451

<!-- page 1452 -->

31.4.5
Clock stretching
Slaves can use the clock synchronization mechanism to slow down the transfer bit rate.
After the master has driven SCL low, the slave can drive SCL low for the required period
and then release it. If the slave SCL low period is longer than the master SCL low period,
the resulting SCL bus signal low period is stretched.
31.4.6
Peripheral bus accesses
I2C is a 16-bit block. Only half-word accesses should be performed to the block.
31.4.7
Generation of transfer error on IP bus
If an address is received on the peripheral slave bus interface but it is not implemented,
an access error is generated.
31.4.8
Reset
The I2C can be reset in the following ways:
• Global reset: A hard asynchronous reset of the whole I2C
• Software reset: An internal reset for the whole I2C (except for I2C_IADR and
I2C_IFDR registers) initiated by deasserting the I2C_I2CR[IEN] bit
31.4.9
Interrupts
There is only one interrupt from the block, which is enabled by setting the
I2C_I2CR[IIEN] bit.
The interrupt is generated in any one of the following conditions:
• One byte transfer is completed (the interrupt is set at the falling edge of the ninth
clock).
• An address is received that matches its own specific address in Slave Receive mode.
• Arbitration is lost.
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1452
NXP Semiconductors

<!-- page 1453 -->

31.4.10
Byte order
The block only supports the Little-Endian mode.
31.5
Initialization
NOTE
Ensure the input select pins for IOMUXC are configured
correctly for I2C.
31.5.1
Initialization sequence
Before the interface can transfer serial data, registers must be initialized, as listed here.
1. Set the data sampling rate (I2C_IFDR[IC] to obtain SCL frequency from the system
bus clock.
2. Update the address in the (I2C_IADR) to define its slave address (address can range
from 0 to 0x7f).
3. Set the I2C enable bit (I2C_I2CR[IEN]) to enable the I2C bus interface system.
4. Modify the bits in the I2C_I2CR to select Master/Slave mode, Transmit/Receive
mode, and Interrupt-Enable or not.
31.5.2
Generation of Start
After completion of the initialization procedure, serial data can be transmitted by
selecting the Master Transmit mode. On a multimaster bus system, the busy bus
(I2C_I2SR[IBB]) must be tested to determine whether the serial bus is free. If the bus is
free (IBB = 0), the Start signal and the first byte (the slave address) can be sent. The data
written to the data register comprises the address of the desired slave and the LSB
indicates the transfer direction.
The free time between a Stop and the next Start condition is built into the hardware that
generates the Start cycle. Depending on the relative frequencies of the system clock and
the SCL period, it may be necessary to wait until the I2C is not busy after writing the
calling address to the data register (I2C_I2DR), before proceeding to load data into the
data register (I2C_I2DR).
Chapter 31 I2C Controller (I2C)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1453

<!-- page 1454 -->

31.5.3
Post-transfer software response
Sending or receiving a byte sets the data transferring bit (I2C_I2SR[ICF]), which
indicates one byte of communication is finished. Upon completion, the interrupt status
(I2C_I2SR[IIF]) is also set. An external interrupt is generated if the interrupt enable
(I2C_I2CR[IIEN]) is set. The software must first clear the interrupt status
(I2C_I2SR[IIF]) in the interrupt routine.
See the flow chart in Figure 31-5.
The data transferring bit (I2C_I2SR[ICF]) is cleared either by reading from I2C_I2DR in
Receive mode or by writing to this register in Transmit mode.
The software can service the I2C I/O in the main program by monitoring the interrupt
status (I2C_I2SR[IIF]) if the interrupt enable is deasserted. In this case, the interrupt
status should be polled in the data transferring bit (I2C_I2SR[ICF]) because the operation
is different when arbitration is lost.
When an interrupt occurs at the end of the address cycle, the master is always in Transmit
mode; that is, the address is sent. If Master Receive mode is required, then
I2C_I2CR[MTX] should be toggled and a dummy read of the I2C_I2DR register must be
executed to trigger receive data.
During Slave-mode address cycles (I2C_I2SR[IAAS] = 1), the slave read/write bit
I2C_I2SR[SRW] is read to determine the direction of the next transfer. The transmit/
receive bit (I2C_I2CR[MTX]) should also be programmed accordingly. For Slave-mode
data cycles (IAAS = 0), SRW is invalid. MTX should be read to determine the current
transfer direction.
31.5.4
Generation of Stop
A data transfer ends when the master signals a Stop, which can occur after all data is sent.
For a master receiver to terminate a data transfer, it must inform the slave transmitter by
not acknowledging the last data byte. This is done by setting the transmit acknowledge
bit (I2C_I2CR[TXAK]) before reading the next-to-last byte. Before the last byte is read,
a Stop signal must be generated.
31.5.5
Generation of Repeated Start
After the data transfer, if the master still requires the bus, it can signal another Start
followed by another slave address without signaling a Stop.
Initialization
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1454
NXP Semiconductors

<!-- page 1455 -->

31.5.6
Slave mode
In the slave interrupt service routine (see Figure 31-5), the block addressed as slave bit
(IAAS) should be tested to check if a calling of its own address has just been received. If
IAAS is set, software should set the Transmit/Receive mode select bit (I2C_I2CR[MTX])
according to the I2C_I2SR[SRW]. Writing to the I2C_I2CR clears the IAAS
automatically. The only time IAAS is read as set is from the interrupt at the end of the
address cycle where an address match occurred; interrupts resulting from subsequent data
transfers will have IAAS cleared. A data transfer can now be initiated by writing
information to I2C_I2DR for slave transmits, or read from I2C_I2DR in Slave Receive
mode. A dummy read of I2C_I2DR in Slave Receive mode releases SCL, allowing the
master to send data.
In the slave transmitter routine, the receive acknowledge bit (I2C_I2SR[RXAK]) must be
tested before sending the next byte of data. Setting RXAK means an end-of-data signal
from the master receiver, after which the software must switch it from Transmit to
Receiver mode. Reading the data register (I2C_I2DR) then releases SCL so the master
can generate a Stop signal.
31.5.7
Arbitration lost
If several devices try to engage the bus at the same time, one becomes master. Hardware
immediately switches devices that lose arbitration to Slave Receive mode. Data output to
12Cn_SDA stops, but 12Cn_SCL is still generated until the end of the byte during which
arbitration is lost. An interrupt occurs at the falling edge of the ninth clock of this transfer
if the arbitration is lost (I2C_I2SR[IAL] = 1), and the Slave mode is selected
(I2C_I2CR[MSTA] = 0).
See the flow chart in Figure 31-5.
If a device that is not a master tries to transmit or do a Start, hardware inhibits the
transmission, clears MSTA without signaling a Stop, generates an interrupt to the Arm
platform, and sets I2C_I2SR[IAL] to indicate a failed attempt to engage the bus. When
considering these cases, the slave service routine should first test I2C_I2SR[IAL], and the
software should clear it if it is set.
For Multimaster mode, when an I2C is enabled when the bus is busy and asserts Start, the
I2C_I2SR[IAL] bit gets set only for 12Cn_SDA=0, 12Cn_SCL=0/1, 12Cn_SDA=1, and
12Cn_SCL=0; but not for 12Cn_SDA=1 and I2Cn_SCL=1, which is the equivalent of
Bus Idle state.
Chapter 31 I2C Controller (I2C)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1455

<!-- page 1456 -->

EXIT
ENTER
ENABLE
IBB=0
IBB=0
START
SEND
DATA
IIF=1
INTERRUPT
TX
COMPLETE
STOP
DISABLE
IBB=0 OR
TIMEOUT
IBB=1
IBB=1
ICF=1
RXAK=0
No More Data
RXAK=1
IAL=1
TIMEOUT
TIMEOUT
IBB=1
ERROR
HANDLER
I2C Interrupt Handler
sr = I2SR (status)
cr = I2CR (control)
Clear I2SR
If IAL=1 Then Arbitration Lost!
If RXAK=0 Then TX Success
IFDR
I2SR=0
IEN=IIEN=1
MSTA=1
MTX=1
I2DR
MSTA=0
MTX=0
I2CR=0
MSTA=0
MTX=0
Figure 31-4. I2C Programming state diagram
Initialization
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1456
NXP Semiconductors

<!-- page 1457 -->

Clear
IIF
Master
Mode 
Y
N
TX / RX
RX
TX
Last Byte
Transmitted
Y
N
RXAK = 0
N
Y
End of 
ADDR Cycle
(Master RX)
N
Y
Write Next Byte 
to I2C_I2DR
Switch to
RX Mode
Dummy Read
from I2C_I2DR
Generate
STOP Signal
Read Data
from I2C_I2DR
And Store
Last
Byte to be 
Read
Y
N
2nd Last
Byte to be
Read
N
Y
Set TXAK =1
Generate
STOP Signal
Return
Arbitration
Lost
Y
N
Clear IAL
IAAS = 1
N
Y
Y
IAAS = 1
N
TX/ RX
RX
TX
SRW = 1
N (WRITE)
(READ) Y
ACK from
Receiver
Set TX
Mode
Write Data
to I2C_I2DR
TX Next
Byte
Read Data
from I2C_I2DR
and Store
Set RX
Mode
Switch to 
RX Mode
Dummy Read
from I2C_I2DR 
Dummy Read
from I2C_I2DR
Address
Cycle
Data
Cycle
Y
N
Figure 31-5. Flowchart of typical I2C interrupt routine
Chapter 31 I2C Controller (I2C)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1457

<!-- page 1458 -->

NOTE
For a Repeated Start only, the Stop-generation stage does not
occur in Master mode. A loop repeats itself without stopping
for the next start.
For Master Receive mode, I2C is programmed as Master
Transmit during Address mode and after slave address transfer;
the MTX bit should be cleared and a dummy read on the
I2C_I2DR register should be performed so I2C can read the
next receive data.
Initialization
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1458
NXP Semiconductors

<!-- page 1459 -->

IIF = 1?
Clear IIF
Y
N
Master
Mode?
TX/RX?
TX
RX
Last Byte
Transmitted?
Y
N
RXAK = 0?
Y
N
End of
ADDR Cycle
(Master RX)
?
Write Next
Byte to I2DR
Switch to
RX Mode
Dummy Read
From I2DR
Generate
STOP Signal
Read Data
from I2DR
And Store
Set TXAK =1
Generate
STOP Signal
Y
Y
N
2nd Last
Byte to be
Read?
Last
Byte to be 
Read?
A1
IAAS =1
?
IAAS =1
?
TX/RX?
RX
TX
ACK from
Receiver
?
Tx Next
Byte
SRW =1
?
Address
Cycle
Y
N
(Read)Y
N(WRITE)
Set TX
Mode
Write Data
to I2DR
Set RX
Mode
Y
N
Read Data
from I2DR
And Store
Switch to
RX Mode
Dummy Read
From I2DR
Dummy Read
From I2DR
Clear IAL
Y
N
Arbitration
Lost?
A1
N
Y
N
N
Y
Y
N
Data
Cycle
Figure 31-6. Flowchart for typical I2C polling routine
Chapter 31 I2C Controller (I2C)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1459

<!-- page 1460 -->

NOTE
The timeout value depends on the bus frequency at which I2C
is operating. The minimum timeout for polling the IIF bit at a
maximum I2C bus frequency of 400 kHz is Tmin = 25 μs
(=2.5 x 10 μs). This value can be calculated for any bus
frequency. The formula is Tmin = 10/FSCL, where FSCL is the
frequency of the I2C clock (SCL).
Reset
Program IFDR
Enable I2C
(IEN = 1, IIEN = 1)
Program IADR
IBB=0?
Program MSTA and MTX
IBB=1?
Write Slave Address
to I2DR
Data Transmission
Interrupt Asserted
Interrupt Asserted
IAL=1
Interrupt Asserted
A
A
A
N
N
Y
Y
C
D
B
Figure 31-7. Detailed flowchart of a typical I2C Master Transmit mode, part 1
Initialization
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1460
NXP Semiconductors

<!-- page 1461 -->

Clear IIF
MSTA = 1?
RXAK = 0?
Clear IAL
D
B
C
B
Generate
STOP Signal
Generate RESTART
Signal
A
WriteNext
Byte to I2DR
Y
N
N
Y
Figure 31-8. Detailed flowchart of a typical I2C Master Transmit mode, part 2
Figure 31-7 and Figure 31-8 show the Master Transmit mode operation with interrupt
subroutine. If an interrupt is generated and the MSTA bit is 0, then bus arbitration is lost
and IAL is set. Software can clear the IAL bit and reprogram I2C. If the MSTA bit is 1,
then it is a transfer-generated interrupt. In this case, software can check the RXAK bit for
a data receive acknowledgement by the slave and, accordingly, decide to do one of the
following:
• Generate a STOP
• Generate a REPEATED START by writing to the I2C_I2CR register
• Perform the next data transfer by writing to the I2C_I2DR register
NOTE
The IBB bit is asserted by a Start condition on the bus, and it is
deasserted by a Stop condition on the bus. Therefore, if
arbitration is lost due to an unexpected Stop condition during
transfer, then IBB is cleared. If arbitration is lost due to a data
mismatch, then it is not cleared. Software should always clear
the IEN bit and then set it if arbitration is lost.
Chapter 31 I2C Controller (I2C)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1461

<!-- page 1462 -->

31.6
Software restriction
Software should ensure that there is a delay of at least two module clock cycles after it
sets the I2C_I2CR[RSTA] bit and before writing to the I2C_I2DR register. The
maximum possible clock period of the module clock is 78 ns.
31.7
I2C Memory Map/Register Definition
The I2C contains five 16-bit registers.
NOTE
Registers at offsets 0x0002, 0x0006, 0x000A, and 0x000E are
reserved for future additions.
I2C memory map
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
21A_0000
I2C Address Register (I2C1_IADR)
16
R/W
0000h
31.7.1/1463
21A_0004
I2C Frequency Divider Register (I2C1_IFDR)
16
R/W
0000h
31.7.2/1463
21A_0008
I2C Control Register (I2C1_I2CR)
16
R/W
0000h
31.7.3/1465
21A_000C
I2C Status Register (I2C1_I2SR)
16
R/W
0081h
31.7.4/1466
21A_0010
I2C Data I/O Register (I2C1_I2DR)
16
R/W
0000h
31.7.5/1468
21A_4000
I2C Address Register (I2C2_IADR)
16
R/W
0000h
31.7.1/1463
21A_4004
I2C Frequency Divider Register (I2C2_IFDR)
16
R/W
0000h
31.7.2/1463
21A_4008
I2C Control Register (I2C2_I2CR)
16
R/W
0000h
31.7.3/1465
21A_400C
I2C Status Register (I2C2_I2SR)
16
R/W
0081h
31.7.4/1466
21A_4010
I2C Data I/O Register (I2C2_I2DR)
16
R/W
0000h
31.7.5/1468
21A_8000
I2C Address Register (I2C3_IADR)
16
R/W
0000h
31.7.1/1463
21A_8004
I2C Frequency Divider Register (I2C3_IFDR)
16
R/W
0000h
31.7.2/1463
21A_8008
I2C Control Register (I2C3_I2CR)
16
R/W
0000h
31.7.3/1465
21A_800C
I2C Status Register (I2C3_I2SR)
16
R/W
0081h
31.7.4/1466
21A_8010
I2C Data I/O Register (I2C3_I2DR)
16
R/W
0000h
31.7.5/1468
21F_8000
I2C Address Register (I2C4_IADR)
16
R/W
0000h
31.7.1/1463
21F_8004
I2C Frequency Divider Register (I2C4_IFDR)
16
R/W
0000h
31.7.2/1463
21F_8008
I2C Control Register (I2C4_I2CR)
16
R/W
0000h
31.7.3/1465
21F_800C
I2C Status Register (I2C4_I2SR)
16
R/W
0081h
31.7.4/1466
21F_8010
I2C Data I/O Register (I2C4_I2DR)
16
R/W
0000h
31.7.5/1468
I2C Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1462
NXP Semiconductors

<!-- page 1463 -->

31.7.1
I2C Address Register (I2Cx_IADR)
Address: Base address + 0h offset
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
Read
0
ADR
0
Write
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
I2Cx_IADR field descriptions
Field
Description
15–8
Reserved
This read-only field is reserved and always has the value 0.
7–1
ADR
Slave address. Contains the specific slave address to be used by the I2C. Slave mode is the default I2C
mode for an address match on the bus.
NOTE: The I2C_IADR holds the address to which the I2C responds when addressed as a slave. The
slave address is not the address sent on the bus during the address transfer. The register is not
reset by a software reset.
0
Reserved
This read-only field is reserved and always has the value 0.
31.7.2
I2C Frequency Divider Register (I2Cx_IFDR)
The I2C_IFDR provides a programmable prescaler to configure the clock for bit-rate
selection. The register does not get reset by a software reset.
I2C clock is sourced from PERCLK_ROOT which is routed from IPG_CLK_ROOT. I2C
clock frequency can easily obtained by using the following formula:
I2C clock Frequency = (PERCLK_ROOT frequency)/(division factor corresponding
to IFDR)
By default, IPG_CLK_ROOT and PERCLK_ROOT frequencies are set to 49.5 MHz,
where the root clock is sourced from PLL2’s PFD2. Obtaining the frequencies can be
accomplished by:
PLL2 = 528 MHz
PLL2_PFD2 = 528 MHz * 18 / 24 = 396 MHz
IPG_CLK_ROOT = (PLL2_PFD2 / ahb_podf )/ ipg_podf = (396 MHz/4)/2 = 49.5
MHz
PER_CLK_ROOT = IPG_CLK_ROOT/perclk_podf = 49.5 MHz/1 = 49.5 MHz
Chapter 31 I2C Controller (I2C)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1463

<!-- page 1464 -->

NOTE
The above calculation assumes that the default CCM register
settings, routing, and division factors are used. If different
routing, PFD values, and/or division factors are used, the user
must adjust the parameters accordingly to calculate the correct
clock frequency.
The following table describes the divider and register values for the register field "IC."
Table 31-3. I2C_IFDR Register Field Values
IC
Divider
IC
Divider
IC
Divider
IC
Divider
0x00
30
0x10
288
0x20
22
0x30
160
0x01
32
0x11
320
0x21
24
0x31
192
0x02
36
0x12
384
0x22
26
0x32
224
0x03
42
0x13
480
0x23
28
0x33
256
0x04
48
0x14
576
0x24
32
0x34
320
0x05
52
0x15
640
0x25
36
0x35
384
0x06
60
0x16
768
0x26
40
0x36
448
0x07
72
0x17
960
0x27
44
0x37
512
0x08
80
0x18
1152
0x28
48
0x38
640
0x09
88
0x19
1280
0x29
56
0x39
768
0x0A
104
0x1A
1536
0x2A
64
0x3A
896
0x0B
128
0x1B
1920
0x2B
72
0x3B
1024
0x0C
144
0x1C
2304
0x2C
80
0x3C
1280
0x0D
160
0x1D
2560
0x2D
96
0x3D
1536
0x0E
192
0x1E
3072
0x2E
112
0x3E
1792
0x0F
240
0x1F
3840
0x2F
128
0x3F
2048
Address: Base address + 4h offset
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
Read
0
IC
Write
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
I2Cx_IFDR field descriptions
Field
Description
15–6
Reserved
This read-only field is reserved and always has the value 0.
IC
I2C clock rate. Prescales the clock for bit-rate selection. Due to potentially slow I2Cn_SCL and I2Cn_SDA
rise and fall times, bus signals are sampled at the prescaler frequency. The serial bit clock frequency may
be lower than IPG_CLK_ROOT divided by the divider shown in the I2C Data I/O Register.
NOTE: The IC value should not be changed during the data transfer, however, it can be changed before
a Repeat Start or Start programming sequence in I2C. The I2C protocol supports bit rates of up to
400 kbps. The IC bits need to be programmed in accordance with this constraint.
I2C Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1464
NXP Semiconductors

<!-- page 1465 -->

31.7.3
I2C Control Register (I2Cx_I2CR)
The I2C_I2CR is used to enable the I2C and the I2C interrupt. It also contains bits that
govern operation as a slave or a master.
Address: Base address + 8h offset
Bit
15
14
13
12
11
10
9
8
Read
0
Write
Reset
0
0
0
0
0
0
0
0
Bit
7
6
5
4
3
2
1
0
Read
IEN
IIEN
MSTA
MTX
TXAK
0
0
Write
RSTA
Reset
0
0
0
0
0
0
0
0
I2Cx_I2CR field descriptions
Field
Description
15–8
Reserved
This read-only field is reserved and always has the value 0.
7
IEN
I2C enable. Also controls the software reset of the entire I2C. Resetting the bit generates an internal reset
to the block. If the block is enabled in the middle of a byte transfer, Slave mode ignores the current bus
transfer and starts operating when the next Start condition is detected. Master mode is not aware that the
bus is busy, so initiating a start cycle may corrupt the current bus cycle, ultimately causing either the
current master or the I2C to lose arbitration. Subsequently, bus operation returns to normal.
0
The block is disabled, but registers can still be accessed.
1
The I2C is enabled. This bit must be set before any other I2C_I2CR bits have an effect.
6
IIEN
I2C interrupt enable.
NOTE: If data is written during the Start condition, that is, just after setting the I2C_I2CR[MSTA] and
I2C_I2CR[MTX] bits, then the ICF bit is cleared at the falling edge of SCLK after Start. If data is
written after the Start condition and falling edge of SCLK, then the ICF bit is cleared as soon as
data is written.
0
I2C interrupts are disabled, but the status flag I2C_I2SR[IIF] continues to be set when an Interrupt
condition occurs.
1
I2C interrupts are enabled. An I2C interrupt occurs if I2C_I2SR[IIF] is also set.
5
MSTA
Master/Slave mode select bit. If the master loses arbitration, MSTA is cleared without generating a Stop
signal.
NOTE: The module clock should be on for writing to the MSTA bit.
NOTE: The MSTA bit is cleared by software to generate a Stop condition; it can also be cleared by
hardware when the I2C loses the bus arbitration.
Table continues on the next page...
Chapter 31 I2C Controller (I2C)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1465

<!-- page 1466 -->

I2Cx_I2CR field descriptions (continued)
Field
Description
0
Slave mode. Changing MSTA from 1 to 0 generates a Stop and selects Slave mode.
1
Master mode. Changing MSTA from 0 to 1 signals a Start on the bus and selects Master mode.
4
MTX
Transmit/Receive mode select bit. Selects the direction of master and slave transfers.
0
Receive.
When a slave is addressed, the software should set MTX according to the slave read/write bit in the
I2C status register (I2C_I2SR[SRW]).
1
Transmit.
In Master mode, MTX should be set according to the type of transfer required. Therefore, for address
cycles, MTX is always 1.
3
TXAK
Transmit acknowledge enable. Specifies the value driven onto I2Cn_SDA during acknowledge cycles for
both master and slave receivers.
NOTE: Writing TXAK applies only when the I2C bus is a receiver.
0
An acknowledge signal is sent to the bus at the ninth clock bit after receiving one byte of data.
1
No acknowledge signal response is sent (that is, the acknowledge bit = 1).
2
RSTA
Repeat start. Always reads as 0. Attempting a repeat start without bus mastership causes loss of
arbitration.
0
No repeat start
1
Generates a Repeated Start condition
Reserved
This read-only field is reserved and always has the value 0.
31.7.4
I2C Status Register (I2Cx_I2SR)
The I2C_I2SR contains bits that indicate transaction direction and status.
Address: Base address + Ch offset
Bit
15
14
13
12
11
10
9
8
Read
0
Write
Reset
0
0
0
0
0
0
0
0
Bit
7
6
5
4
3
2
1
0
Read
ICF
IAAS
IBB
IAL
0
SRW
IIF
RXAK
Write
Reset
1
0
0
0
0
0
0
1
I2C Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1466
NXP Semiconductors

<!-- page 1467 -->

I2Cx_I2SR field descriptions
Field
Description
15–8
Reserved
This read-only field is reserved and always has the value 0.
7
ICF
Data transferring bit. While one byte of data is transferred, ICF is cleared.
0
Transfer is in progress.
1
Transfer is complete. This bit is set by the falling edge of the ninth clock of the last byte transfer.
6
IAAS
I2C addressed as a slave bit. The Arm platform is interrupted if the interrupt enable (I2C_I2CR[IIEN]) is
set. The Arm platform must check the slave read/write bit (SRW) and set its Transfer/Receive mode
accordingly. Writing to I2C_I2CR clears this bit.
0
Not addressed
1
Addressed as a slave. Set when its own address (I2C_IADR) matches the calling address.
5
IBB
I2C bus busy bit. Indicates the status of the bus.
NOTE: When I2C is enabled (I2C_I2CR[IEN] = 1), it continuously polls the bus data (SDA) and clock
(SCL) signals to determine a Start or Stop condition.
0
Bus is idle. If a Stop signal is detected, IBB is cleared.
1
Bus is busy. When Start is detected, IBB is set.
4
IAL
Arbitration lost. Set by hardware in the following circumstances (IAL must be cleared by software by
writing a "0" to it at the start of the interrupt service routine):
• I2Cn_SDA input samples low when the master drives high during an address or data-transmit cycle.
• I2Cn_SDA input samples low when the master drives high during the acknowledge bit of a data-
receive cycle.
For the above two cases, the bit is set at the falling edge of the ninth I2Cn_SCL clock during the ACK
cycle.
• A Start cycle is attempted when the bus is busy.
• A Repeated Start cycle is requested in Slave mode.
• A Stop condition is detected when the master did not request it.
NOTE: Software cannot set the bit.
0
No arbitration lost.
1
Arbitration is lost.
3
Reserved
This read-only field is reserved and always has the value 0.
2
SRW
Slave read/write. When the I2C is addressed as a slave, IAAS is set, and the slave read/write bit (SRW)
indicates the value of the R/W command bit of the calling address sent from the master. SRW is valid only
when a complete transfer has occurred, no other transfers have been initiated, and the I2C is a slave and
has an address match.
0
Slave receive, master writing to slave
1
Slave transmit, master reading from slave
1
IIF
I2C interrupt. Must be cleared by the software by writing a "0" to it in the interrupt routine.
NOTE: The software cannot set the bit.
0
No I2C interrupt pending.
1
An interrupt is pending.
Table continues on the next page...
Chapter 31 I2C Controller (I2C)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1467

<!-- page 1468 -->

I2Cx_I2SR field descriptions (continued)
Field
Description
This causes a processor interrupt request (if the interrupt enable is asserted [IIEN = 1]). The interrupt
is set when one of the following occurs:
• One byte transfer is completed (the interrupt is set at the falling edge of the ninth clock).
• An address is received that matches its own specific address in Slave Receive mode.
• Arbitration is lost.
0
RXAK
Received acknowledge. This is the value received from the I2Cn_SDA input for the acknowledge bit
during a bus cycle.
0
An "acknowledge" signal was received after the completion of an 8-bit data transmission on the bus.
1
A "No acknowledge" signal was detected at the ninth clock.
31.7.5
I2C Data I/O Register (I2Cx_I2DR)
In Master Receive mode, reading the data register allows a read to occur and initiates the
next byte to be received. In Slave mode, the same function is available after it is
addressed.
Address: Base address + 10h offset
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
Read
0
DATA
Write
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
I2Cx_I2DR field descriptions
Field
Description
15–8
Reserved
This read-only field is reserved and always has the value 0.
DATA
Data Byte. Holds the last data byte received or the next data byte to be transferred. Software writes the
next data byte to be transmitted or reads the data byte received.
NOTE: The core-written value in I2C_I2DR cannot be read back by the core. Only data written by the I2C
bus side can be read.
I2C Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1468
NXP Semiconductors

