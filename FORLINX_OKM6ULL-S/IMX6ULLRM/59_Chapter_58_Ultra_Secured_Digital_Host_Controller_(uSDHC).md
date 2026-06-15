# Chapter 58: Ultra Secured Digital Host Controller (uSDHC)

> Nguồn: `IMX6ULLRM.pdf` — trang 3947–4078

<!-- page 3947 -->

Chapter 58
Ultra Secured Digital Host Controller (uSDHC)
58.1
Overview
The Ultra Secured Digital Host Controller (uSDHC) provides the interface between the
host system and the SD/SDIO/MMC cards, as depicted in Figure 58-1.
The uSDHC acts as a bridge, passing host bus transactions to the SD/SDIO/MMC cards
by sending commands and performing data accesses to/from the cards.
It handles the SD/SDIO/MMC protocols at the transmission level.
The following are brief descriptions of the cards supported by the uSDHC:
The Multi Media Card (MMC) is a universal low cost data storage and communication
media designed to cover a wide array of applications including mobile video and gaming.
Previous MMC cards were based on a 7-pin serial bus with a single data pin, while the
new high speed MMC communication is based on an advanced 11-pin serial bus
designed to operate in the low voltage range.
The Secure Digital Card (SD) is an evolution of the old MMC technology. It is
specifically designed to meet the security, capacity, performance, and environment
requirements inherent in newly-emerging audio and video consumer electronic devices.
The physical form factor, pin assignment and data transfer protocol are forward-
compatible with the old MMC (with some additions).
Under the SD protocol, it can be categorized into Memory card, I/O card and Combo
card, which has both memory and I/O functions. The memory card invokes a copyright
protection mechanism that complies with the security of the SDMI standard. The I/O
card, which is also known as SDIO card, provides high-speed data I/O with low power
consumption for mobile electronic devices. For the sake of simplicity, the following
figure does not show cards with reduced size or mini cards.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3947

<!-- page 3948 -->

MMC/SD/SDIO
Host Controler
DMA Interface
IP Bus
Transceiver
Card Slot
MMC card
SD card
SDIO card
AHB Bus
IP Bus
Power Supply
Figure 58-1. System Connection of the uSDHC
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3948
NXP Semiconductors

<!-- page 3949 -->

CLK(input)
CLK(output)
DLL
ref_clk
Rising
Edge
Async.
FIFO
Falling
Edge
Async.
FIFO
CMD(input)/ 
DATA[7:0](input)
Interrupt Generator
Register Bank
CMD CTRL
DATA CTRL
CLK CTRL
AHB Bus
IPS Bus
IRQ
PIO
DMA
Buffer
Control
TX buffer
RX buffer
    SRAM
(128x32bit)
CMD(output) 
DAT[7:0](output)
CLK(output)
CLK(output) Domain
ipg_clk/ipg_clk_s/ahb_clk domain
/M
/N
usdhc_clk_root
card_clk
ref_clk (to DLL)
Figure 58-2. ultra Secure Digital Host Controller Block Diagram
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3949

<!-- page 3950 -->

58.1.1
Features
The features of the uSDHC module include the following:
• Conforms to the SD Host Controller Standard Specification version 3.0
• Compatible with the MMC System Specification version 4.2/4.3/4.4/4.41/4.5
• Compatible with the SD Memory Card Specification version 3.0 and supports the
Extended Capacity SD Memory Card
• Compatible with the SDIO Card Specification version 3.0
• Designed to work with SD Memory, miniSD Memory, SDIO, miniSDIO, SD
Combo, MMC, MMC plus, and MMC RS cards
• Card bus clock frequency up to 208 MHz
• Supports 1-bit / 4-bit SD and SDIO modes, 1-bit / 4-bit / 8-bit MMC modes
• Up to 832 Mbps of data transfer for SDIO cards using 4 parallel data lines in
SDR(Single Data Rate) mode
• Up to 400 Mbps of data transfer for SDIO card using 4 parallel data lines in
DDR(Dual Data Rate) mode
• Up to 832 Mbps of data transfer for SDXC cards using 4 parallel data lines in
SDR(Single Data Rate) mode
• Up to 400 Mbps of data transfer for SDXC card using 4 parallel data lines in
DDR(Dual Data Rate) mode
• Up to 416 Mbps of data transfer for MMC cards using 8 parallel data lines in
SDR(Single Data Rate) mode
• Up to 832 Mbps of data transfer for MMC cards using 8 parallel data lines in
DDR(Dual Data Rate) mode
• Supports single block/multi-block read and write
• Supports block sizes of 1 ~ 4096 bytes
• Supports the write protection switch for write operations
• Supports both synchronous and asynchronous abort
• Supports pause during the data transfer at block gap
• Supports SDIO Read Wait and Suspend Resume operations
• Supports Auto CMD12 for multi-block transfer
• Host can initiate non-data transfer command while data transfer is in progress
• Allows cards to interrupt the host in 1-bit and 4-bit SDIO modes, also supports
interrupt period
• Embodies a fully configurable 128x32-bit FIFO for read/write data
• Supports internal and external DMA capabilities
• Support voltage selection by configuring vendor specific register bit
• Supports Advanced DMA to perform linked memory access
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3950
NXP Semiconductors

<!-- page 3951 -->

58.1.2
Modes and Operations
58.1.2.1
Data Transfer Modes
The uSDHC can select the following modes for data transfer:
• SD 1-bit
• SD 4-bit
• MMC 1-bit
• MMC 4-bit
• MMC 8-bit
• Identification Mode (up to 400 kHz)
• MMC full speed mode (up to 26 MHz)
• MMC high speed mode (up to 52 MHz)
• MMC HS200 mode (up to 200 MHz)
• MMC DDR mode (52 MHz both edges)
• SD/SDIO full speed mode (up to 25 MHz)
• SD/SDIO high speed mode (up to 50 MHz)
• SD/SDIO UHS-I mode (up to 208 MHz in SDR mode, up to 50 MHz in DDR mode)
58.2
External Signals
The following table describes the external signals of USDHC:
Table 58-1. USDHC External Signals
Signal
Description
Pad
Mode
Direction
SD1_CD_B
Card detection pin If not used (for
the embedded memory), tie low to
indicate there is a card attached.
CSI_DATA05
ALT8
I
GPIO1_IO03
ALT4
UART1_RTS_B
ALT2
SD1_CLK
Clock for MMC/SD/SDIO card
SD1_CLK
ALT0
O
SD1_CMD
CMD line connect to card
SD1_CMD
ALT0
IO
SD1_DATA0
DATA0 line in all modes Also used
to detect busy state
SD1_DATA0
ALT0
IO
SD1_DATA1
DATA1 line in 4/8-bit mode Also
used to detect interrupt in 1/4-bit
mode
SD1_DATA1
ALT0
IO
SD1_DATA2
DATA2 line or Read Wait in 4-bit
mode Read Wait in 1-bit mode
SD1_DATA2
ALT0
IO
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3951

<!-- page 3952 -->

Table 58-1. USDHC External Signals (continued)
Signal
Description
Pad
Mode
Direction
SD1_DATA3
DATA3 line in 4/8-bit mode or
configured as card detection pin
May be configured as card detection
pin in 1-bit mode
SD1_DATA3
ALT0
IO
SD1_DATA4
DATA4 line in 8-bit mode, not used
in other modes
NAND_READY_B
ALT1
IO
SD1_DATA5
NAND_CE0_B
ALT1
IO
SD1_DATA6
NAND_CE1_B
ALT1
IO
SD1_DATA7
NAND_CLE
ALT1
IO
SD1_LCTL
LED control used to drive an
external LED Active high Fully
controlled by the driver Optional
output
ENET1_RX_DATA0
ALT8
O
SD1_RESET_B
Card hardware reset signal, active
LOW
CSI_DATA06
ALT8
O
GPIO1_IO04
ALT4
GPIO1_IO09
ALT6
NAND_WP_B
ALT1
SD1_TESTER_TRIGG
ER
-
UART1_RX_DATA
ALT7
IO
SD1_VSELECT
IO power voltage selection signal
CSI_DATA07
ALT8
O
ENET1_RX_EN
ALT8
GPIO1_IO05
ALT4
SD1_WP
Card write protect detect If not
used(for the embedded memory), tie
low to indicate it's not write
protected.
CSI_DATA04
ALT8
I
GPIO1_IO02
ALT4
UART1_CTS_B
ALT2
SD2_CD_B
Card detection pin If not used(for the
embedded memory),tie low to
indicate there is a card attached.
CSI_MCLK
ALT1
I
GPIO1_IO07
ALT4
UART1_RTS_B
ALT8
SD2_CLK
Clock for MMC/SD/SDIO card
CSI_VSYNC
ALT1
O
LCD_DATA19
ALT8
NAND_RE_B
ALT1
SD2_CMD
CMD line connect to card
CSI_HSYNC
ALT1
IO
LCD_DATA18
ALT8
NAND_WE_B
ALT1
SD2_DATA0
DATA0 line in all modes Also used
to detect busy state
CSI_DATA00
ALT1
IO
LCD_DATA20
ALT8
NAND_DATA00
ALT1
SD2_DATA1
DATA1 line in 4/8-bit mode Also
used to detect interrupt in 1/4-bit
mode
CSI_DATA01
ALT1
IO
LCD_DATA21
ALT8
NAND_DATA01
ALT1
SD2_DATA2
DATA2 line or Read Wait in 4-bit
mode Read Wait in 1-bit mode
CSI_DATA02
ALT1
IO
LCD_DATA22
ALT8
Table continues on the next page...
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3952
NXP Semiconductors

<!-- page 3953 -->

Table 58-1. USDHC External Signals (continued)
Signal
Description
Pad
Mode
Direction
NAND_DATA02
ALT1
SD2_DATA3
DATA3 line in 4/8-bit mode or
configured as card detection pin
May be configured as card detection
pin in 1-bit mode
CSI_DATA03
ALT1
IO
LCD_DATA23
ALT8
NAND_DATA03
ALT1
SD2_DATA4
DATA4 line in 8-bit mode, not used
in other modes
CSI_DATA04
ALT1
IO
LCD_DATA14
ALT8
NAND_DATA04
ALT1
SD2_DATA5
CSI_DATA05
ALT1
IO
LCD_DATA15
ALT8
NAND_DATA05
ALT1
SD2_DATA6
CSI_DATA06
ALT1
IO
LCD_DATA16
ALT8
NAND_DATA06
ALT1
SD2_DATA7
CSI_DATA07
ALT1
IO
LCD_DATA17
ALT8
NAND_DATA07
ALT1
SD2_LCTL
LED control used to drive an
external LED Active high Fully
controlled by the driver Optional
output
ENET1_RX_DATA1
ALT8
IO
SD2_RESET_B
Card hardware reset signal, active
LOW
GPIO1_IO09
ALT4
O
LCD_DATA13
ALT8
NAND_ALE
ALT1
SD2_TESTER_TRIGG
ER
-
UART1_CTS_B
ALT7
IO
SD2_VSELECT
IO power voltage selection signal
ENET1_TX_DATA0
ALT8
IO
GPIO1_IO08
ALT4
SD2_WP
Card write protect detect If not
used(for the embedded memory), tie
low to indicate it's not write
protected.
CSI_PIXCLK
ALT1
I
GPIO1_IO06
ALT4
UART1_CTS_B
ALT8
58.2.1
Signals Overview
The uSDHC has 14 associated I/O signals.
• The CLK is an internally generated clock used to drive the MMC, SD, SDIO cards.
• The CMD I/O is used to send commands and receive responses to and from the card.
Eight data lines (DAT7~DAT0) are used to perform data transfers between the
uSDHC and the card.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3953

<!-- page 3954 -->

• The CD and WP are card detection and write protection signals directly routed from
the socket. These two signals are active low (0). A low on CD# means that a card is
inserted, and a high on WP means that the write protect switch is active.
• LCTL is an output signal used to drive an external LED to indicate that the SD
interface is busy.
• RST is an output signal used to reset the MMC card.
• VSELECT is an output signal used to change the voltage of the external power
supplier.
CD, WP, LCTL, RST and VSELECT are all optional for system implementation. If the
uSDHC needs to support a 4-bit data transfer, DAT7~DAT4 can also be optional and tied
to high.
58.3
Clocks
The table found here describes the clock sources for uSDHC.
Please see Clock Controller Module (CCM) for clock setting, configuration and gating
information.
Table 58-2. uSDHC Clocks
Clock name
Clock Root
Description
hclk
ahb_clk_root
AHB bus clock
ipg_clk
ipg_clk_root
Peripheral clock
ipg_clk_perclk
usdhc_clk_root
Base clock
ipg_clk_s
ipg_clk_root
Peripheral access clock for register accesses
58.4
Functional Description
The following sections provide a brief functional description of the major system blocks,
including the Data Buffer, DMA AHB interface, register bank as well as IP Bus interface,
dual-port memory wrapper, data/command controller, clock and reset manager, and clock
generator.
Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3954
NXP Semiconductors

<!-- page 3955 -->

58.4.1
Data Buffer
The uSDHC uses one configurable data buffer to transfer data between the system bus (IP
Bus or AHB Bus) and the SD card in an optimized manner, maximizing throughput
between the two clock domains (IP peripheral clock and the master clock).
The buffer is used as temporary storage for data being transferred between the host
system and the card. The watermark levels for read and write are both configurable and
can be from 1 to 128 words. The burst lengths for read and write are also configurable
and can be from 1 to 31 words.
dma_req
uSDHC_irq
IP Bus
I/F
AHB
Bus
uSDHC Registers
Buffer Control
Internal
DMA
Buffer
RAM
Wrapper
Tx / Rx
FIFO
Sync
FIFOs
Status
Sync
SD Bus
I/F
Figure 58-3. uSDHC Buffer Scheme
There are 3 transfer modes to access the data buffer:
• CPU polling mode:
• For a host read operation, when the number of words received in the buffer
meets or exceeds the RD_WML watermark value, by polling the BRR bit, the
Host Driver can read the Buffer Data Port register to fetch the amount of words
set in the RD_WML register from the buffer. The write operation is similar.
• External DMA mode:
• For a read operation, when there are more words received in the buffer than the
amount set in the RD_WML register, a DMA request is sent out to inform the
external DMA to fetch the data. The request will be immediately de-asserted
when there is an access on the Buffer Data Port register. If the number of words
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3955

<!-- page 3956 -->

in the buffer after the current burst meets or exceeds RD_WML value, the DMA
request is asserted again. For instance, if there are twice as many words in the
buffer as there are in the RD_WML value, there are two successive DMA
requests with only one cycle of de-assertion between. The write operation is
similar. Note the accesses CPU polling mode and external DMA mode both use
the IP bus, and if the external DMA is enabled, in both modes an external DMA
request is sent when the buffer is ready.
• Internal DMA mode (includes simple and advanced DMA accesses):
• The internal DMA access, either by simple or advanced DMA, is over the AHB
bus. For internal DMA access mode, the external DMA request will never be
sent out.
For a read operation, when there are more words in the buffer than the amount set in the
RD_WML register, the internal DMA starts fetching data over the AHB bus. Except for
INCR4 and INCR8, the burst type is always INCR mode and the burst length depends on
the shortest of following factors:
• Burst length configured in the burst length field of the Watermark Level register
• Watermark Level boundary
• Block size boundary
• Data boundary configured in the current descriptor (if the ADMA is active)
• 1 Kbyte address boundary defined in the AHB protocol
Write operation is similar.
Sequential and contiguous access is necessary to ensure the pointer address value is
correct. Random or skipped access is not possible. The byte order, by reset, is little
endian mode. The actual byte order is swapped inside the buffer, according to the endian
mode configured by software (see the following figures). For a host write operation, byte
order is swapped after data is fetched from the buffer and ready to send to the SD Bus.
For a host read operation, byte order is swapped before the data is stored in the buffer.
System IP Bus or System AHB Bus
uSDHC Data buffer
31-24
23-16
15-8
7-0
31-24
23-16
15-8
7-0
Figure 58-4. Data Swap between System Bus and uSDHC Data Buffer in Byte Little
Endian Mode
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3956
NXP Semiconductors

<!-- page 3957 -->

System IP Bus or System AHB Bus
uSDHC Data buffer
31-24
23-16
15-8
7-0
31-24
23-16
15-8
7-0
Figure 58-5. Data Swap between System Bus and uSDHC Data Buffer in Half Word Big
Endian Mode
58.4.1.1
Write Operation Sequence
There are three ways to write data into the buffer when the user transfers data to the card:
• External DMA through the uSDHC DMA request signal
• Processor core polling through the BWR bit in Interrupt Status register (interrupt or
polling)
• Internal DMA
When the internal DMA is not used, (the DMAEN bit in the Transfer Type register is not
set when the command is sent), the uSDHC asserts a DMA request when the amount of
buffer space exceeds the value set in the WR_WML register, and is ready for receiving
new data. At the same time, the uSDHC sets the BWR bit. The buffer write ready
interrupt will be generated if it is enabled by software.
When internal DMA is used, the uSDHC will not inform the system before all the
required number of bytes are transferred (if no error was encountered). When an error
occurs during the data transfer, the uSDHC will abort the data transfer and abandon the
current block. The Host Driver should read the contents of the DMA System Address
register to obtain the starting address of the abandoned data block. If the current data
transfer is in multi-block mode, the uSDHC will not automatically send CMD12, even
though the AC12EN bit in the Transfer Type register is set. The Host Driver sends
CMD12 in this scenario and re-starts the write operation from that address. It is
recommended that a Software Reset for Data be applied before the transfer is re-started.
The uSDHC will not start data transmission until the number of words set in the
WR_WML register can be held in the buffer. If the buffer is empty and the Host System
does not write data in time, the uSDHC will stop the CLK to avoid the data buffer under-
run situation.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3957

<!-- page 3958 -->

58.4.1.2
Read Operation Sequence
There are three ways to read data from the buffer when the user transfers data to the card:
• External DMA through the uSDHC DMA request signal
• Processor core polling through the BRR bit in Interrupt Status register (interrupt or
polling)
• Internal DMA
When internal DMA is not used (DMAEN bit in Transfer Type register is not set when
the command is sent), the uSDHC asserts a DMA request when the amount of data
exceeds the value set in the RD_WML register, that is available and ready for system
fetching data. At the same time, the uSDHC sets the BRR bit. The buffer read ready
interrupt will be generated if it is enabled by software.
When internal DMA is used, the uSDHC will not inform the system before all the
required number of bytes are transferred (if no error was encountered). When an error
occurs during the data transfer, the uSDHC will abort the data transfer and abandon the
current block. The Host Driver should read the content of the DMA System Address
register to get the starting address of the abandoned data block. If the current data transfer
is in multi-block mode, the uSDHC will not automatically send CMD12, even though the
AC12EN bit in the Transfer Type register is set. The Host Driver sends CMD12 in this
scenario and re-starts the read operation from that address. It is recommended that a
Software Reset for Data be applied before the transfer is re-started.
For any write transfer mode, the uSDHC will not start data transmission until the number
of words set in the RD_WML register are in the buffer. If the buffer is full and the Host
System does not read data in time, the uSDHC will stop the CLK to avoid the data buffer
over-run situation.
58.4.1.3
Data Buffer and Block Size
The user needs to know the buffer size for the buffer operation during a data transfer to
utilize it in the most optimized way. In the uSDHC, the only data buffer can hold up to
128 words (32-bit) and the watermark levels for write and read can be configured
accordingly.
For both read and write, the watermark level can be from 1 to 128 words. For both read
and write the burst length can be from 1 to 31 words. The Host Driver may configure the
value according to the system situation and requirement.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3958
NXP Semiconductors

<!-- page 3959 -->

During a multi-block data transfer, the block length can be set to any value between 1 and
4096 bytes, satisfying the requirements of the external card. The only restriction is from
the external card, which can be limited in size or support of a partial block access (which
is not the integer times of 512 bytes).
As uSDHC treats each block individually, for block sizes which are not multiples of four
(not word-aligned) stuffed bytes are required at the end of each block. For example, if the
block size is 7 bytes and there are 12 blocks to write, the system side must write two
times for each block. For each block the ending byte will be abandoned by uSDHC
because it only sends 7 bytes to the card and picks data from the following system write,
resulting in 24 beats of write access in total.
58.4.1.4
Dividing Large Data Transfer
This SDIO command CMD53 definition limits the maximum data size of data transfers
according to the following formula:
Max data size = Block size x Block count
The length of a multiple block transfer needs to be in block size units. If the total data
length can't be divided evenly into a multiple of the block size, then there are two ways to
transfer the data which depend on the function and the card design. Option 1 is for the
Host Driver to split the transaction. The remainder of the block size data is then
transferred by using a single block command at the end. Option 2 is to add dummy data
in the last block to fill the block size. For option 2, the card must manage the removal of
the dummy data.
See the figure below for an example showing the dividing of large data transfers,
assuming a kind of WLAN SDIO card that only supports a block size up to 64 bytes.
Although the uSDHC supports a block size of up to 4096 bytes, the SDIO can only
accept a block size less than 64 bytes, so the data must be divided (see example below).
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3959

<!-- page 3960 -->

544 Bytes WLAN Frame
WLAN Frame is divided equally into 64 byte blocks plus the remainder 32 bytes
Eight 64 byte blocks are sent in Block Transfer mode and the
 remainder 32 bytes are sent in Byte Transfer mode
802.11
MAC Header
IV
Frame Body
ICV
FCS
Data
64 bytes
Data
64 bytes
Data
32 bytes
Data
64 bytes
SDIO Data
block #1
SDIO Data
block #2
SDIO Data
block #8
SDIO Data
32 bytes
CMD 53
SDIO Data
block #1
SDIO Data
block #2
SDIO Data
block #8
CMD 53
SDIO Data
32 bytes
Figure 58-6. Example for Dividing Large Data Transfers
58.4.1.5
External DMA Request
When the internal DMA is not in use and external DMA is enabled, the Data Buffer will
generate a DMA request to the system. During a write operation, when the number of
WR_WML words can be held in the buffer free space, the signal uSDHC_dreq_b is
asserted to 0, informing the Host System of a DMA write.
The BWR bit in the Interrupt Status register is also set, as long as the BWRSEN bit in the
Interrupt Status Enable register is set. The DMA request is de-asserted after several
accesses to the Data Port register are made while the buffer's free space can't meet the
watermark condition (free space> write watermark level).
On read operation, when the number of RD_WML words are already in the buffer, the
signal uSDHC_dreq_b is asserted to 0, informing the Host System for a DMA read. The
BRR bit in the Interrupt Status register is also set, as long as the BRRSEN bit in the
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3960
NXP Semiconductors

<!-- page 3961 -->

Interrupt Status Enable register is set. The DMA request is de-asserted after several
accesses to the Data Port register are made while the buffer's data can't meet the
watermark condition (the number of data in buffer > read watermark level).
If the DMA burst length can't change during a data transfer for an external DMA transfer,
the watermark level (read or write) must be a divisor of the block size. If it is not,
transferring the block may cause buffer under-run (read operation) or over-run (write
operation). For example, if the block size is 512 bytes, the watermark level of read (or
write) must be a power of two between 1 and 128. For processor core polling access there
is no such issue, as the last access in the block transfer can be controlled by software. The
watermark level can be any value, even larger than the block size (but no greater than 128
words) because the actual number of bytes transferred by the software can be controlled
and does not exceed the block size in each transfer.
The uSDHC also supports non-word aligned block size, as long as the card supports that
block size. In this case, the watermark level should be set as the number of words. For
example, if the block size is 31 bytes, the watermark level can be set to any number of
words. For this case, the BLKSIZE bits of the Block Attribute register will be set as 1fh.
For the CPU polling access, the burst length can be 1 to 128 words, without restriction.
This is because the software will transfer 8 words, and the uSDHC will also set the BWR
or BRR bits when the remaining data does not violate data buffer. See DMA Burst
Length for more details about the dynamic watermark level of the data buffer.
For the above example, even though 8 words are transferred via the Data Port register,
the uSDHC will transfer only 31 bytes over the SD Bus, as required by the BLKSIZE
bits. In this data transfer, with non-word aligned block size, the endian mode should be
set cautiously or invalid data will be transferred to and from the card.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3961

<!-- page 3962 -->

58.4.2
DMA AHB Interface
The internal DMA implements a DMA engine and the AHB master. When the internal
DMA is enabled, the uSDHC_dreq_b will not be asserted during the transfer, but the
BWR and BRR bits will be set if the BWRSEN and BRRSEN bits have been set in the
Interrupt Status Enable register.
See the figure below for an illustration of the DMA AHB interface block.
System Address
R/W Indication
Error Indication
Burst Length
Data Exchange
DMA Request
AHB signal
cluster
uSDHC Registers
Buffer Control
Master
Logic
AHB
Interface
DMA
Engine
Figure 58-7. DMA AHB Interface Block
58.4.2.1
Internal DMA Request
If the watermark level requirement is met in data transfer or if the last data of current
block is ready in the data buffer, and the Internal DMA is enabled, the Data Buffer block
will send a DMA request to AHB interface. Meanwhile, the external DMA request signal
(uSDHC_dreq_b) is disabled.
The delay in response from the internal DMA engine depends on the system AHB bus
loading and the priority assigned to the uSDHC. The DMA engine does not respond to
the request during its burst transfer, but is ready to serve as soon as the burst is over. The
Data Buffer de-asserts the request if the data buffer space(for write) or bytes in data
buffer is smaller than the watermark level. Upon access to the buffer by internal DMA,
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3962
NXP Semiconductors

<!-- page 3963 -->

the Data Buffer updates its internal buffer pointer, and when the watermark level is
satisfied or the last data of current block is ready in the data buffer, another DMA request
is sent.
The data transfer is in the block unit, and the subsequent watermark level is always set as
the remaining number of words. For instance, for a multi block data read with each block
size of 31 bytes, and the burst length set to 6 words. After the first burst transfer, if there
are more than 2 words in the buffer (which might contain some data of the next block),
another DMA request is sent. This is because the remaining number of words to send for
the current block is (31 - 6 * 4) / 4 = 2. The uSDHC will read 2 words out of the buffer,
with 7 valid bytes and 1 stuffed byte.
58.4.2.2
DMA Burst Length
Just like a CPU polling access, the DMA burst length for the internal DMA engine can be
from 1 to 16 words. The actual burst length for the DMA depends on the lesser of the
configured burst length or the remaining words of the current block.
See the example in Internal DMA Request. After 6 words are read, the burst length will
be 2 words, then the next burst length will be 6 words. This is because the next block
starts, which is 31 bytes, more than 6 words. The Host Driver may take this variable burst
length into account. It is also acceptable to configure the burst length as the divisor of the
block size, so that each time the burst length will be the same.
58.4.2.3
AHB Master Interface
It is possible that the internal AHB DMA engine could fail during the data transfer. Upon
detection of an AHB bus error during DMA transfer, the DMA engine stops the transfer
and goes to the idle state.At that point, the internal data buffer stops receiving incoming
data and sending out data. The DMAE bit in the Interrupt Status register will be
generated to host CPU to report a bus error condition.
Once the DMAE interrupt is received, the software shall send a CMD12 to abort the
current transfer and read the DS_ADDR bits of the DMA System Address register to get
the starting address of the corrupted block. After the DMA error is fixed, the software
should apply a data reset and re-start the transfer from this address to recover the
corrupted block. DMA operation will resume when the interrupt is serviced by software.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3963

<!-- page 3964 -->

58.4.2.4
ADMA Engine
In the SD Host Controller Standard, a new DMA transfer algorithm called the ADMA
(Advanced DMA) is defined. For Simple DMA, once the page boundary is reached, a
DMA interrupt will be generated and the new system address shall be programmed by the
Host Driver.
The ADMA defines the programmable descriptor table in the system memory. The Host
Driver can calculate the system address at the page boundary and program the descriptor
table before executing ADMA. It reduces the frequency of interrupts to the host system.
Therefore, higher speed DMA transfers could be realized since the Host MCU
intervention would not be needed during long DMA based data transfers.
There are two types of ADMA: ADMA1 and ADMA2 in Host Controller. ADMA1 can
support data transfer of 4KB aligned data in system memory. ADMA2 improves the
restriction so that data of any location and any size can be transferred in system memory.
Their formats of Descriptor Table are different.
ADMA can recognize all kinds of descriptors define in SD Host Controller Standard, and
if 'End' flag is detected in the descriptor, ADMA will stop after this descriptor is
processed.
58.4.2.4.1
ADMA Concept and Descriptor Format
For ADMA1, including the following descriptors:
• Valid/Invalid descriptor.
• Nop descriptor.
• Set data length descriptor.
• Set data address descriptor.
• Link descriptor.
• Interrupt flag and End flag in descriptor.
For ADMA2, including the following descriptors:
• Valid/Invalid descriptor.
• Nop descriptor.
• Rsv descriptor.
• Set data length & address descriptor.
• Link descriptor.
• Interrupt flag and End flag in descriptor.
See Figure 58-8 for the format of the descriptor table for ADMA1.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3964
NXP Semiconductors

<!-- page 3965 -->

Figure 58-11 explains the ADMA2 format. ADMA2 deals with the lower 32-bit first, and
then the higher 32-bit. If the 'Valid' flag of descriptor is 0, it will ignore the high 32-bit.
Address field shall be set on word aligned(lower 2-bit is always set to 0). Data length is
in byte unit.
ADMA will start read/write operation after it reaches the Tran state, using the data length
and data address analyzed from most recent descriptor(s).
For ADMA1, the valid data length descriptor is the last Set type descriptor before Tran
type descriptor. Every Tran type will trigger a transfer, and the transfer data length is
extracted from the most recent Set type descriptor. If there is no Set type descriptor after
the previous Trans descriptor, the data length will be the value for previous transfer, or 0
if no Set descriptor is ever met.
For ADMA2, Tran type descriptor contains both data length and transfer data address, so
only a Tran type descriptor can start a data transfer
Address/ Page Field
Address/ Page Field
Attribute Field
0
1
2
3
4
5
6
11
12
31
Address or Data Length
000000
Act 2
Act 1
0
Int
End
Valid
Act 2
Act1
Symbol
Comment
31- 28
27- 12
0
0
1
1
0
1
0
1
Nop
Set
Tran
Link
No Operation
Set Data Length
Transfer Data
Link Descriptor
Don't Care
Data Address
0000
Data Length
Descriptor Address
Valid
End
Int
Valid = 1 indicates this line of descriptor is effective. If Valid = 0 generate ADMA Error Interrupt and stop ADMA.
End = 1 indicates current descriptor is the ending one.
Int = 1 generates DMA Interrupt when this descriptor is processed.
Figure 58-8. Format of the ADMA1 Descriptor Table
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3965

<!-- page 3966 -->

System Address Register
Data Length (invisible)
Data Address (invisible)
SDMA
Flags
State
Machine
Address/Length
Attribute
Address
Tran
Address
Link
Address/Length
Attribute
Data Length
Set
Address
Tran, End
Descriptor Table
Page Data
Page Data
DMA Interrupt
Transfer Complete
Block Gap Event
System Memory
Advanced DMA
System Address Register points to 
the head node of Descriptor Table
Figure 58-9. Concept and Access Method of ADMA1 Descriptor Table
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3966
NXP Semiconductors

<!-- page 3967 -->

Address Field
Length
Attribute Field
00
01
02
03
04
05
06
31
32
63
32-bit Address
Act 2
Act 1
0
Int
End
Valid
Act 2
Act1
Symbol
Comment
Operation
0
0
1
1
0
1
0
1
Nop
Rsv
Tran
Link
No Operation
Reserved
Transfer Data
Link Descriptor
Don't Care
Transfer data with address and length 
set in this descriptor line
Same as Nop. Read this line and go to next one
Link to another descriptor
Valid
End
Int
Valid = 1 indicates this line of descriptor is effective. If Valid = 0 generate ADMA Error Interrupt and stop ADMA.
End = 1 indicates current descriptor is the ending one.
Int = 1 generates DMA Interrupt when this descriptor is processed.
Reserved
16 15
16-bit length
0000000000
Figure 58-10. Format of the ADMA2 Descriptor Table
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3967

<!-- page 3968 -->

System Address Register
Data Length (invisible)
Data Address (invisible)
SDMA
Flags
State
Machine
Address
Address1
Address2
Descriptor Table
Page Data
Page Data
DMA Interrupt
Transfer Complete
ADMA Error
System Memory
Advanced DMA
System Address Register points to 
the head node of Descriptor Table
Length
Attribute
Length1
Tran
Length2
Link
Address
Address3
Attribute
Tran, End
Figure 58-11. Concept and Access Method of ADMA2 Descriptor Table
58.4.2.4.2
ADMA Interrupt
If the interrupt flag descriptor is set, ADMA will generate an interrupt according to
various types of descriptors:
For ADMA1:
• Set type of descriptor: interrupt is generated when data length is set.
• Tran type descriptor: interrupt is generated when this transfer is complete.
• Link type of descriptor: interrupt is generated when new descriptor address is set.
• Nop type of descriptor: interrupt is generated just after this descriptor is fetched.
For ADMA2:
• Tran type of descriptor: interrupt is generated when this transfer is complete.
• Link type of descriptor: interrupt is generated when new descriptor address is set.
• Nop/Rsv type of descriptor: interrupt is generated just after this descriptor is fetched.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3968
NXP Semiconductors

<!-- page 3969 -->

58.4.2.4.3
ADMA Error
The ADMA will stop whenever any error is encountered. These errors include:
• Fetching descriptor error
• AHB response error
• Data length mismatch error
An ADMA descriptor error will be generated when it fails to detect a 'Valid' flag in the
descriptor. If an ADMA descriptor error occurs, the interrupt is not generated even if the
'Interrupt' flag of this descriptor is set.
When BLKCNTEN bit is set, data length set in buffer must be equal to the whole data
length set in descriptor nodes, otherwise data length mismatch error will be generated.
When BLKCNTEN bit is not set, then whole data length set in descriptor should be a
multiple of block lengths; otherwise, when data set in the descriptor nodes are not
performed at block boundaries, then data mismatch errors will occur.
58.4.3
Register Bank with IP Bus Interface
Register accesses via the IP Bus interface are actually on the Register Bank.
See Figure 58-12 below for the block diagram.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3969

<!-- page 3970 -->

Register Bank
"0"
"0"
ips_xfr_err
ips_xfr_wait
IP Bus
Signals
Software
Visible
Registers
Write 1 Clear
Function
Array
Data Port
Buffer Control
Synchronizer
Control/ Status
Signals
with other domains
Control/ Status
Signals
Status Signals
to other modules
Control Signals
to other modules
Figure 58-12. Register Bank Diagram
Only 32-bit access is allowed, and no partial read / write is supported, thus all accesses
are word aligned.
58.4.3.1
SD Protocol Unit
The SD protocol unit deals with all SD protocol affairs.
The SD Protocol Unit performs the following functions:
• Acts as the bridge between the internal buffer and the SD bus
• Sends the command data as well as its argument serially
• Stores the serial response bit stream into corresponding registers
• Detects the bus state on the CMD/DAT lines
• Monitors the interrupt from the SDIO card
• Asserts the read wait signal
• Gates off the SD clock when buffer is announcing danger status
• Detects the write protect state
The SD Protocol Unit consists of four sub modules:
1. SD control misc.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3970
NXP Semiconductors

<!-- page 3971 -->

2. Command control.
3. Data control.
4. Clock control
58.4.3.2
SD control misc
In the SD control misc unit, the card detect(include the CD_B and DATA3 used as Card
Detection), write protection and card interrupt are implemented.
This module monitors the signal level on all 8 data lines, the command lines, and directly
routes the level values into the Register Bank. The driver can use this for debug purposes.
The module also detects the WP (Write Protect) line. If WP is active, writes to the
register bank will be ignored.
This module also drives the LCTL output signal when the LCTL bit is set by the driver.
58.4.3.3
SD Clock control
If the internal data buffer is near full(for read) or near empty(for write), the SD clock
must be gated off to avoid buffer over/under-run, this module will assert the gate of the
output SD clock to shut the clock off. After the buffer has space(for read) or has data(for
write), the clock gate of this module will open and the SD clock will be active again.
58.4.3.4
Command control
The Command Control module deals with the transactions on the CMD line.
See the figure below for an illustration of the structure for the Command CRC Shift
Register.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3971

<!-- page 3972 -->

CLR_CRC
ZERO
CRC_IN
CRC OUT
CRC
Bus [0]
CRC
Bus [1]
CRC
Bus [2]
CRC
Bus [3]
CRC
Bus [4]
CRC
Bus [5]
CRC
Bus [6]
Figure 58-13. Command CRC Shift Register
The CRC polynomials for the CMD are as follows:
Generator polynomial: G(x) = x7 + x3 + 1
M(x) = (first bit) * xn + (second bit) * xn-1 +...+ (last bit) * x0
CRC[6:0] = Remainder [(M(x) * x7) / G(x)]
58.4.3.5
Data control
The Data Agent deals with the transactions on the eight data lines. Moreover, this module
also detects the busy state on the DATA0 line, and generates the Read Wait state by the
request from the Transceiver.
The CRC polynomials for the DATA are as follows:
Generator polynomial: G(x) = x16 + x12 + x5 +1
M(x) = (first bit) * xn + (second bit) * xn-1 +...+ (last bit) * x0
CRC[15:0] = Remainder [(M(x) * x16) / G(x)]
58.4.4
Clock & Reset Manager
This module controls all the reset signals within the uSDHC.
There are four kinds of reset signals within uSDHC:
1. Hardware reset.
2. Software reset for all logic.
3. Software reset for the data logic.
4. Software reset for the command logic.
All these signals are fed into this module and stable signals are generated inside the
module to reset all other modules. The module also gates off all the inside signals.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3972
NXP Semiconductors

<!-- page 3973 -->

58.4.5
Clock Generator
The Clock Generator generates the card CLK by peripheral source clock in two stages.
Refer to the figure below for the structure of the divider. The term "Base" represents the
frequency of peripheral source clock.
Base
1st divisor
by 1, 2, 3, ..., 16
DIV
2nd divisor
by (1*), 2, 4, ..., 256
/2
DDR_EN
card_clk
CLK
Figure 58-14. Two Stages of the Clock Divider
The first divisor stage (controlled by uSDHCx_SYS_CTRL[DVS]) outputs an
intermediate clock (DIV), which can be Base, Base/2, Base/3, ..., or Base/16.
The second divisor stage (controlled by uSDHCx_SYS_CTRL[SDCLKFS]) outputs the
actual internal working clock (card_clk). This clock is the driving clock for all sub
modules of the SD Protocol Unit, and the sync FIFOs (see Figure 58-3) to synchronize
with the data rate from the internal data buffer.
Please note, in SDR mode and DDR mode, the CLK are different.
- In SDR mode, CLK is equal to the internal working clock(card_clk).
- In DDR mode, CLK is equal to the card_clk/2.
58.4.6
SDIO Card Interrupt
Information on Interrupts in 1-bit Mode, Interrupts in 4-bit Mode, and Card Interrupt
Handling are detailed in the sections below.
58.4.6.1
Interrupts in 1-bit Mode
In this case the DATA1 pin is dedicated to providing the interrupt function. An interrupt
is asserted by pulling the DATA1 low from the SDIO card, until the interrupt service is
finished to clear the interrupt.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3973

<!-- page 3974 -->

58.4.6.2
Interrupt in 4-bit Mode
Since the interrupt and data line 1 share Pin 8 in 4-bit mode, an interrupt will only be sent
by the card and recognized by the host during a specific time. This is known as the
Interrupt Period. The uSDHC will only sample the level on Pin 8 during the Interrupt
Period. At all other times, the host will ignore the level on Pin 8, and treat it as the data
signal. The definition of the Interrupt Period is different for operations with single block
and multiple block data transfers.
In the case of normal single data block transmissions, the Interrupt Period becomes active
two clock cycles after the completion of a data packet. This Interrupt Period lasts until
after the card receives the end bit of the next command that has a data block transfer
associated with it.
For multiple block data transfers in 4-bit mode, there is only a limited period of time that
the Interrupt Period can be active due to the limited period of data line availability
between the multiple blocks of data. This requires a more strict definition of the Interrupt
Period. For this case, the Interrupt Period is limited to two clock cycles. This begins two
clocks after the end bit of the previous data block. During this 2-clock cycle interrupt
period, if an interrupt is pending, the DATA1 line will be held low for one clock cycle
with the last clock cycle pulling DATA1 high. On completion of the Interrupt Period, the
card releases the DATA1 line into the high Z state. The uSDHC samples the DATA1
during the Interrupt Period when the IABG bit in the Protocol Control register is set.
Refer to SDIO Card Specification v1.10f for further information about the SDIO card
interrupt.
58.4.6.3
Card Interrupt Handling
When the CINTIEN bit in the Interrupt Signal Enable Register is set to 0, the uSDHC
clears the interrupt request to the Host System. The Host Driver should clear this bit
before servicing the SDIO Interrupt and should set this bit again after all interrupt
requests from the card are cleared to prevent inadvertent interrupts.
The SDIO Card Interrupt Status can be cleared by writing 1 to this bit. But as the
interrupt source from the SDIO card does not clear, this bit is set again. In order to clear
this bit, it is required to reset the interrupt source from the external card followed by a
writing 1 to this bit. In 1-bit mode, the uSDHC will detect the SDIO Interrupt with or
without the SD clock (to support wakeup). In 4-bit mode, the interrupt signal is sampled
during the Interrupt Period, so there are some sample delays between the interrupt signal
from the SDIO card and the interrupt to the Host System Interrupt Controller. When the
SDIO status has been set, and the Host Driver needs to service this interrupt, so the SDIO
bit in the Interrupt Control Register of SDIO card will be cleared. This is required to clear
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3974
NXP Semiconductors

<!-- page 3975 -->

the SDIO interrupt status latched in the uSDHC and to stop driving the interrupt signal to
the System Interrupt Controller. The Host Driver must issue a CMD52 to clear the card
interrupt. After completion of the card interrupt service, the SDIO Interrupt Status Enable
bit is set to 1, and the uSDHC starts sampling the interrupt signal again.
See the figure below for an illustration of the SDIO card interrupt scheme and for the
sequences of software and hardware events that take place during a card interrupt
handling procedure.
Start
Enable card IRQ in Host
Detect and steer card IRQ
Read IRQ Status Register
Disable Card Interrupt Status enable in Host,
THEN write 1 to clear Card Interrupt status
Interrogate and Service Card IRQ
Response 
Error ?
Yes
No
Clear Card IRQ in Card
Enable card IRQ in Host
End
IP Bus
IRQ to CPUm
uSDHC Registers
SDIO IRQ Status
SDIO IRQ Enable
Command/
Response
Handling
IRQ Detecting & Steering
SDIO Card
IRQ Routing
IRQ0
IRQ1
Function 0
Function 1
Clear IRQ1
Clear IRQ0
SD Host
SDIO Card
Figure 58-15. Card Interrupt Scheme and Card Interrupt Detection and Handling
Procedure
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3975

<!-- page 3976 -->

58.4.7
Card Insertion and Removal Detection
The uSDHC uses either the DATA3 pin or the CD_B pin to detect card insertion or
removal. When there is no card on the MMC/SD bus, the DATA3 will be pulled to a low
voltage level by default.
When any card is inserted to or removed from the socket, the uSDHC detects the logic
value changes on the DATA3 pin and generates an interrupt. When the DATA3 pin is not
used for card detection (for example, it is implemented in GPIO), the CD_B pin must be
connected for card detection. Whether DATA3 is configured for card detection or not, the
CD_B pin is always a reference for card detection. Whether the DATA3 pin or the CD_B
pin is used to detect card insertion, the uSDHC will send an interrupt (if enabled) to
inform the Host system that a card is inserted.
58.4.8
Power Management and Wake Up Events
When there is no operation between the uSDHC and the card through the SD bus, the
user can completely disable the ipg_clk and ipg_perclk in the chip level clock control
module to save power. When the user needs to use the uSDHC to communicate with the
card, it can enable the clock and start the operation.
In some circumstances, when the clocks to the uSDHC are disabled, for instance, when
the system is in low power mode, there are some events for which the user needs to
enable the clock and handle the event. These events are called wakeup interrupts. The
uSDHC can generate these interrupt even when there are no clocks enabled. The three
interrupts which can be used as wake up events are:
1. Card Removal Interrupt
2. Card Insertion Interrupt
3. Interrupt from SDIO card
The uSDHC offers a power management feature. By clearing the clock enabled bits in the
System Control Register, the clocks are gated in the low position to the uSDHC. For
maximum power saving, the user can disable all the clocks to the uSDHC when there is
no operation in progress.
These three wake up events (or wakeup interrupts) can also be used to wake up the
system from low-power modes.
NOTE
To make the interrupt a wakeup event, when all the clocks to
the uSDHC are disabled or when the whole system is in low
power mode, the corresponding wakeup enabled bit needs to be
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3976
NXP Semiconductors

<!-- page 3977 -->

set. Refer to Protocol Control (uSDHC_PROT_CTRL) for
more information on the uSDHC Protocol Control register.
58.4.8.1
Setting Wake Up Events
For the uSDHC to respond to a wakeup event, the software must set the respective
wakeup enable bit before the CPU enters sleep mode.
Before the software disables the host clock, it should ensure that all of the following
conditions have been met:
• No Read or Write Transfer is active
• Data and Command lines are not active
• No interrupts are pending
• Internal data buffer is empty
58.4.9
MMC fast boot
The Embedded MultiMediaCard (eMMC4.3) specification adds a fast boot feature which
requires hardware support. There are two types of fast boot mode, boot operation, and
alternative boot operation in the eMMC4.3 specification. Each type also has with-
acknowledge and without-acknowledge modes.
In boot operation mode, the master (MultiMediaCard host) can read boot data from the
slave (MMC device) by keeping CMD line low after power-on, or sending CMD0 with
argument + 0xFFFFFFFA (optional for slave), before issuing CMD1.
NOTE
For the eMMC4.3 card setting, please see the eMMC4.3
specification.
58.4.9.1
Boot operation
NOTE
For the purposes of this documentation, fast boot is called
"normal fast boot mode".
If the CMD line is held LOW for 74 clock cycles and more after power-up before the first
command is issued, the slave recognizes that boot mode is being initiated and starts
preparing boot data internally.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3977

<!-- page 3978 -->

Within 1 second after the CMD line goes LOW, the slave starts to send the first boot data
to the master on the DATA line(s). The master must keep the CMD line LOW to read all
of the boot data.
If boot acknowledge is enabled, the slave has to send acknowledge pattern '010' to the
master within 50ms after the CMD line goes LOW. If boot acknowledge is disabled, the
slave will not send out acknowledge pattern '010'.
The master can terminate boot mode with the CMD line HIGH.
Boot operation will be terminated when all contents of the enabled boot data are sent to
the master. After boot operation is executed, the slave shall be ready for CMD1 operation
and the master needs to start a normal MMC initialization sequence by sending CMD1.
CLK
CMD
DATA0
S
010
E
50ms
max
1 sec. max
S
512bytes
+ CRC
E
S 512bytes
+ CRC
E
Boot terminated
Min 8 clocks + 48 clocks = 56 clocks required from
CMD signal high to next MMC command
CMD1
RESP
CMD2
RESP
CMD3
RESP
Figure 58-16. MultiMediaCard state diagram (normal boot mode)
58.4.9.2
Alternative boot operation
This boot function is optional for the device. If bit 0 in the extended CSD byte[228] is set
to '1', the device supports the alternative boot operation.
After power-up, if the host issues CMD0 with the argument of 0xFFFFFFFA after 74
clock cycles, before CMD1 is issued or the CMD line goes low, the slave recognizes that
boot mode is being initiated and starts preparing boot data internally.
Within 1 second after CMD0 with the argument of 0xFFFFFFFA is issued, the slave
starts to send the first boot data to the master on the DATA line(s).
If boot acknowledge is enabled, the slave has to send the acknowledge pattern '010' to the
master within 50ms after the CMD0 with the argument of 0xFFFFFFFA is received. If
boot acknowledge is disabled, theslave will not send out acknowledge pattern '010'.
The master can terminate boot mode by issuing CMD0 (Reset).
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3978
NXP Semiconductors

<!-- page 3979 -->

Boot operation will be terminated when all contents of the enabled boot data are sent to
the master. After boot operation is executed, the slave shall be ready for CMD1 operation
and the master needs to start a normal MMC initialization sequence by sending CMD1.
CLK
CMD
DATA0
Min 74
clocks
required
after
power is
stable to
start boot
command.
NOTE 1. CMD0 with argument 0xFFFFFFFA
CMD0
1
CMDO/Reset
RESP
CMD1
CMD2
RESP
CMD3
RESP
S
010
E
512 BYTES
+CRC 
S
S
E
E
512 BYTES
+CRC 
50 ms
max
1 sec. max
Figure 58-17. MultiMediaCard state diagram (alternative boot mode)
58.5
Initialization/Application of uSDHC
All communication between the system and cards are controlled by the host. The host
sends commands of two types: broadcast and addressed (point-to-point).
Broadcast commands are intended for all cards, such as GO_IDLE_STATE,
SEND_OP_COND, ALL_SEND_CID. In Broadcast mode, all cards are in the open-drain
mode to avoid bus contention. Refer to Commands for MMC/SD/SDIO for the
commands of bc and bcr categories.
After the Broadcast command CMD3 is issued, the cards enter standby mode. Addressed
type commands are used from this point. In this mode, the CMD/DATA I/O pads will
turn to push-pull mode, to have the driving capability for maximum frequency operation.
Refer to Commands for MMC/SD/SDIO for the commands of ac and adtc categories.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3979

<!-- page 3980 -->

58.5.1
Command Send & Response Receive Basic Operation
Assuming the data type WORD is an unsigned 32-bit integer, the below flow is a
guideline for sending a command to the card(s):
send_command(cmd_index, cmd_arg, other requirements)
{
WORD wCmd; // 32-bit integer to make up the data to write into Transfer Type register, it is 
recommended to implement in a bit-field manner
wCmd = (<cmd_index> & 0x3f) >> 24; // set the first 8 bits as '00'+<cmd_index>
set CMDTYP, DPSEL, CICEN, CCCEN, RSTTYP, DTDSEL accorind to the command index;
if (internal DMA is used) wCmd |= 0x1;
if (multi-block transfer) {
          set MSBSEL bit;
          if (finite block number) {
                    set BCEN bit;
                    if (auto12 command is to use) set AC12EN bit;
          }
}
write_reg(CMDARG, <cmd_arg>); // configure the command argument
write_reg(XFERTYP, wCmd); // set Transfer Type register as wCmd value to issue the command
}
wait_for_response(cmd_index)
{
while (CC bit in IRQ Status register is not set); // wait until Command Complete bit is set
read IRQ Status register and check if any error bits about Command are set
if (any error bits are set) report error;
write 1 to clear CC bit and all Command Error bits;
}
For the sake of simplicity, the function wait_for_response is implemented here by means
of polling. For an effective and formal way, the response is usually checked after the
Command Complete Interrupt is received. When doing this, make sure the corresponding
interrupt status bits are enabled.
For some scenarios, the response time-out is expected. For instance, after all cards
respond to CMD3 and go to the Standby State, no response to the Host when CMD2 is
sent. The Host Driver will deal with "fake" errors like this with caution.
58.5.2
Card Identification Mode
When a card is inserted to the socket or the card was reset by the host, the host needs to
validate the operation voltage range, identify the cards, request the cards to publish the
Relative Card Address (RCA) or to set the RCA for the MMC cards.
58.5.2.1
Card Detect
See the figure below for a flow diagram showing the detection of MMC, SD and SDIO
cards using the uSDHC.
Initialization/Application of uSDHC
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3980
NXP Semiconductors

<!-- page 3981 -->

Enable card detection irq
Wait for uSDHC interrupt
Check CINS bit
Yes cards present
No cards present
Clear CINSIEN to disable
card detection irq
Voltage validation
(2)
(1)
Figure 58-18. Flow Diagram for Card Detection
Here is the card detect sequence:
• Set the CINSIEN bit to enable card detection interrupt
• When an interrupt from the uSDHC is received, check the CINS bit in the Interrupt
Status register to see if it was caused by card insertion
• Clear the CINSIEN bit to disable the card detection interrupt and ignore all card
insertion interrupts afterwards
58.5.2.2
Reset
The host consists of three types of resets:
• Hardware reset (Card and Host) which is driven by POR (Power On Reset)
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3981

<!-- page 3982 -->

• Software reset (Host Only) is initiated by the write operation on the RSTD, RSTC, or
RSTA bits of the System Control register to reset the data part, command part, or all
parts of the Host Controller, respectively
• Card reset (Card Only). The command, "Go_Idle_State" (CMD0), is the software
reset command for all types of MMC cards, SD Memory cards. This command sets
each card into the Idle State regardless of the current card state. For an SD I/O Card,
CMD52 is used to write an I/O reset in the CCCR. The cards are initialized with a
default relative card address (RCA=0x0000) and with a default driver stage register
setting (lowest speed, highest driving current capability).
After the card is reset, the host needs to validate the voltage range of the card. See the
figure below for the software flow to reset both the uSDHC and the card.
write "1" to RSTA bit to reset uSDHC
Send 80 clocks to card
Send CMD0/ CMD52 to card to reset card
Voltage Validation
Figure 58-19. Flow Chart for Reset of the uSDHC and SD I/O Card
software_reset()
{
set_bit(SYSCTRL, RSTA); // software reset the Host
set DTOCV and SDCLKFS bit fields to get the CLK of frequency around 400kHz
configure IO pad to set the power voltage of external card to around 3.0V
poll bits CIHB and CDIHB bits of PRSSTAT to wait both bits are cleared
set_bit(SYSCTRL, INTIA); // send 80 clock ticks for card to power up
send_command(CMD_GO_IDLE_STATE, <other parameters>); // reset the card with CMD0
or send_command(CMD_IO_RW_DIRECT, <other parameters>);
}
58.5.2.3
Voltage Validation
All cards should be able to establish communication with the host using any operation
voltage in the maximum allowed voltage range specified in the card specification.
However, the supported minimum and maximum values for Vdd are defined in the
Operation Conditions Register (OCR) and may not cover the whole range.
Initialization/Application of uSDHC
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3982
NXP Semiconductors

<!-- page 3983 -->

Cards that store the CID and CSD data in the preload memory are only able to
communicate this information under data transfer Vdd conditions. This means if the host
and card have non-common Vdd ranges, the card will not be able to complete the
identification cycle, nor will it be able to send CSD data.
Therefore, a special command Send_Op_Cont (CMD1 for MMC), SD_Send_Op_Cont
(ACMD41 for SD Memory) and IO_Send_Op_Cont (CMD5 for SD I/O) is used. The
voltage validation procedure is designed to provide a mechanism to identify and reject
cards which do not match the Vdd range(s) desired by the host. This is accomplished by
the host sending the desired Vdd voltage window as the operand of this command. Cards
that can't perform the data transfer in the specified range must discard themselves from
further bus operations and go into the Inactive State. By omitting the voltage range in the
command, the host can query each card and determine the common voltage range before
sending out-of-range cards into the Inactive State. This query should be used if the host is
able to select a common voltage range or if a notification shall be sent to the system when
a non-usable card in the stack is detected.
The following steps show how to perform voltage validation when a card is inserted:
voltage_validation(voltage_range_arguement)
{
label the card as UNKNOWN;
send_command(IO_SEND_OP_COND, 0x0, <other parameters are omitted>); // CMD5, check SDIO 
operation voltage, command argument is zero
if (RESP_TIMEOUT != wait_for_response(IO_SEND_OP_COND)) { // SDIO command is accepted
          if (0 < number of IO functions) {
                    label the card as SDIO;
                    IORDY = 0;
                    while (!(IORDY in IO OCR response)) { // set voltage range for each IO 
function
                               send_command(IO_SEND_OP_COND, <voltage range>, <other 
parameter>);
                               wait_for_response(IO_SEND_OP_COND);
                    } // end of while ...
          } // end of if (0 < ...
          if (memory part is present inside SDIO card) Label the card as SDCombo; // this is 
an 
SD-Combo card
} // end of if (RESP_TIMEOUT ...
if (the card is labelled as SDIO card) return; // card type is identified and voltage range 
is 
set, so exit the function;
send_command(APP_CMD, 0x0, <other parameters are omitted>); // CMD55, Application specific 
CMD 
prefix
if (no error calling wait_for_response(APP_CMD, <...>) { // CMD55 is accepted
          send_command(SD_APP_OP_COND, <voltage range>, <...>); // ACMD41, to set voltage 
range 
for memory part or SD card
          wait_for_response(SD_APP_OP_COND); // voltage range is set
          if (card type is UNKNOWN) label the card as SD;
          return; // 
} // end of if (no error ...
else if (errors other than time-out occur) { // command/response pair is corrupted
          deal with it by program specific manner;
} // of else if (response time-out
else { // CMD55 is refuse, it must be MMC card  if (card is already labelled as SDCombo) 
{ // 
change label
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3983

<!-- page 3984 -->

                    re-label the card as SDIO;
                    ignore the error or report it;
                    return; // card is identified as SDIO card
          } // of if (card is ...
          send_command(SEND_OP_COND, <voltage range>, <...>);
          if (RESP_TIMEOUT == wait_for_response(SEND_OP_COND)) { // CMD1 is not accepted, 
either
                    label the card as UNKNOWN;
                    return;
          } // of if (RESP_TIMEOUT ...
} // of else
}
58.5.2.4
Card Registry
Card registry for the MMC and SD/SDIO/SD Combo cards are different. For the SD
Card, the Identification process starts at a clock rate lower than 400 kHz and the power
voltage higher than 2.7 V (as defined by the Card spec). At this time, the CMD line
output drives are push-pull drivers instead of open-drain. After the bus is activated, the
host will request the card to send their valid operation conditions.
The response to ACMD41 is the operation condition register of the card. The same
command shall be send to all of the new cards in the system. Incompatible cards are put
into the Inactive State. The host then issues the command, All_Send_CID (CMD2), to
each card to get its unique card identification (CID) number. Cards that are currently
unidentified (in the Ready State), send their CID number as the response. After the CID
is sent by the card, the card goes into the Identification State.
The host then issues Send_Relative_Addr (CMD3), requesting the card to publish a new
relative card address (RCA) that is shorter than the CID. This RCA will be used to
address the card for future data transfer operations. Once the RCA is received, the card
changes its state to the Standby State. At this point, if the host wants the card to have an
alternative RCA number, it may ask the card to publish a new number by sending another
Send_Relative_Addr command to the card. The last published RCA is the actual RCA of
the card.
The host repeats the identification process with CMD2 and CMD3 for each card in the
system until the last CMD2 gets no response from any of the cards in system.
For MMC operation, the host starts the card identification process in open-drain mode
with the identification clock rate lower than 400 kHz and the power voltage higher than
2.7 V. The open drain driver stages on the CMD line allow parallel card operation during
card identification. After the bus is activated the host will request the cards to send their
valid operation conditions (CMD1). The response to CMD1 is the "wired OR" operation
on the condition restrictions of all cards in the system. Incompatible cards are sent into
the Inactive State. The host then issues the broadcast command All_Send_CID (CMD2),
asking all cards for their unique card identification (CID) number. All unidentified cards
Initialization/Application of uSDHC
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3984
NXP Semiconductors

<!-- page 3985 -->

(the cards in Ready State) simultaneously start sending their CID numbers serially, while
bit-wise monitoring their outgoing bit stream. Those cards, whose outgoing CID bits do
not match the corresponding bits on the command line in any one of the bit periods, stop
sending their CID immediately and must wait for the next identification cycle. Since the
CID is unique for each card, only one card can be successfully send its full CID to the
host. This card then goes into the Identification State. Thereafter, the host issues
Set_Relative_Addr (CMD3) to assign to the card a relative card address (RCA). Once the
RCA is received the card state changes to the Stand-by State, and the card does not react
in further identification cycles, and its output driver switches from open-drain to push-
pull. The host repeats the process, mainly CMD2 and CMD3, until the host receives a
time-out condition to recognize the completion of the identification process.
For operation as MMC cards:
card_registry()
{
do { // decide RCA for each card until response time-out
          if(card is labelled as SDCombo or SDIO) { // for SDIO card like device
                    send_command(SET_RELATIVE_ADDR, 0x00, <...>); // ask SDIO card to 
publish its 
RCA
                    retrieve RCA from response;
          } // end if (card is labelled as SDCombo ...
          else if (card is labelled as SD) { // for SD card
                    send_command(ALL_SEND_CID, <...>);
                    if (RESP_TIMEOUT == wait_for_response(ALL_SEND_CID)) break;
                    send_command(SET_RELATIVE_ADDR, <...>);
                    retrieve RCA from response;
          } // else if (card is labelled as SD ...
          else if (card is labelled as MMC) {
                    send_command(ALL_SEND_CID, <...>);
                    rca = 0x1; // arbitrarily set RCA, 1 here for example
                    send_command(SET_RELATIVE_ADDR, 0x1 << 16, <...>); // send RCA at upper 
16 
bits
          } // end of else if (card is labelled as MMC ...
} while (response is not time-out);
}
58.5.3
Card Access
Information about Block Write, Block Read, Suspense Resume, ADMA Usage, Transfer
Error, and Card Interrupt are detailed in the sections below.
58.5.3.1
Block Write
Information on Normal Write, DDR Write, and Write with Pause are detailed in the
sections below.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3985

<!-- page 3986 -->

58.5.3.1.1
Normal Write
During a block write (CMD24 - 27, CMD60, CMD61), one or more blocks of data are
transferred from the host to the card with a CRC appended to the end of each block by the
host. If the CRC fails, the card shall indicate the failure on the DATA line. The
transferred data will be discarded and not written, and all further transmitted blocks (in
multiple block write mode) will be ignored.
If the host uses partial blocks whose accumulated length is not block aligned and block
misalignment is not allowed (CSD parameter WRITE_BLK_MISALIGN is not set), the
card detects the block misalignment error and aborts the programming before the
beginning of the first misaligned block. The card sets the ADDRESS_ERROR error bit in
the status register, and while ignoring all further data transfer, waits in the Receive-data-
State for a stop command. The write operation is also aborted if the host tries to write
over a write protected area.
For MMC and SD cards, programming of the CID and CSD registers does not require a
previous block length setting. The transferred data is also CRC protected. If a part of the
CSD or CID register is stored in ROM, then this unchangeable part must match the
corresponding part of the receive buffer. If this match fails, then the card will report an
error and not change any register contents.
For all types of cards, some may require long and unpredictable periods of time to write a
block of data. After receiving a block of data and completing the CRC check, the card
will begin writing and hold the DATA line low if its write buffer is full and unable to
accept new data from a new WRITE_BLOCK command. The host may poll the status of
the card with a SEND_STATUS command (CMD13) or other means for SDIO cards at
any time, and the card will respond with its status. The responded status indicates
whether the card can accept new data or whether the write process is still in progress. The
host may deselect the card by issuing a CMD7 (to select a different card) to place the
card into the Standby State and release the DATA line without interrupting the write
operation. When re-selecting the card, it will reactivate the busy indication by pulling
DATA to low if the programming is still in progress and the write buffer is unavailable.
The software flow to write to a card incorporates the internal DMA and the write
operation is a multi-block write with the Auto CMD12 enabled. For the other two
methods (by means of external DMA or CPU polling status) with different transfer
methods, the internal DMA parts should be removed and the alternative steps should be
straightforward.
The software flow to write to a card is described below:
1. Check the card status, wait until the card is ready for data.
2. Set the card block length/size:
Initialization/Application of uSDHC
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3986
NXP Semiconductors

<!-- page 3987 -->

• For SD/MMC cards, use SET_BLOCKLEN (CMD16)
• For SDIO cards or the I/O portion of SDCombo cards, use IO_RW_DIRECT
(CMD52) to set the I/O Block Size bit field in the CCCR register (for function 0)
or FBR register (for functions 1~7)
3. Set the uSDHC block length register to be the same as the block length set for the
card in Step 2.
4. Set the uSDHC number block register (NOB), nob is 5 (for instance).
5. Disable the buffer write ready interrupt, configure the DMA settings and enable the
uSDHC DMA when sending the command with data transfer. The AC12EN bit
should also be set.
6. Wait for the Transfer Complete interrupt.
7. Check the status bit to see if a write CRC error occurred, or some another error, that
occurred during the auto12 command sending and response receiving.
58.5.3.1.2
DDR Write
uSDHC supports dual data rate mode.
The software flow to write to a card in ddr mode is described as below:
1. Check the card status, wait until the card is ready for data.
2. For eMMC4.4 card, block length only can be set to 512byte.
3. Set the uSDHC number block register (NOB), nob is 5 (for instance).
4. Set eMMC4.4 card to high speed mode, use SWITCH(CMD6).
5. Set eMMC4.4 card bus with (4-bit /8-bit ddr mode), use SWITCH(CMD6).
6. Disable the buffer write ready interrupt, configure the DMA settings and enable the
uSDHC DMA when sending the command with data transfer.The DDR_EN bit
should be set. The AC12EN bit should also be set.
7. Wait for the Transfer Complete interrupt.
8. Check the status bit to see if a write CRC error occurred, or some another error, that
occurred during the auto12 command sending and response receiving.
58.5.3.1.3
Write with Pause
The write operation can be paused during the transfer. Instead of stopping the CLK at any
time to pause all the operations, which is also inaccessible to the Host Driver, the Driver
can set the Stop At Block Gap Request(SABGREQ) bit in the Protocol Control register to
pause the transfer between the data blocks. As there is no time-out condition in a write
operation during the data blocks, a write to all types of cards can be paused in this way,
and if the DATA0 line is not required to de-assert to release the busy state, no suspend
command is needed.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3987

<!-- page 3988 -->

Like in the flow described in Normal Write, the write with pause is shown with the same
kind of write operation:
1. Check the card status, wait until card is ready for data.
2. Set the card block length/size:
• For SD/MMC, use SET_BLOCKLEN (CMD16)
• For SDIO cards or the I/O portion of SDCombo cards, use
IO_RW_DIRECT(CMD52) to set the I/O Block Size bit field in the CCCR
register (for function 0) or FBR register (for functions 1~7)
3. Set the uSDHC block length register to be the same as the block length set for the
card in Step 2.
4. Set the uSDHC number block register (NOB), nob is 5 (for instance).
5. Disable the buffer write ready interrupt, configure the DMA settings and enable the
uSDHC DMA when sending the command with data transfer. The AC12EN bit
should also be set.
6. Set the SABGREQ bit.
7. Wait for the Transfer Complete interrupt.
8. Clear the SABGREQ bit.
9. Check the status bit to see if a write CRC error occurred.
10. Set the CREQ bit to continue the write operation.
11. Wait for the Transfer Complete interrupt.
12. Check the status bit to see if a write CRC error occurred, or some another error, that
occurred during the auto12 command sending and response receiving.
The number of blocks left during the data transfer is accessible by reading the contents of
the BLKCNT field in the Block Attribute register. As the data transfer and the setting of
the SABGREQ bit are concurrent, and the delay of register read and the register setting,
the actual number of blocks left may not be exactly the value read earlier. The Driver
shall read the value of BLKCNT after the transfer is paused and the Transfer Complete
interrupt is received.
It is also possible the last block has begun when the Stop At Block Gap Request is sent to
the buffer. In this case, the next block gap is actually the end of the transfer. These types
of requests are ignored and the Driver should treat this as a non-pause transfer and deal
with it as a common write operation.
When the write operation is paused, the data transfer inside the Host System is not
stopped, and the transfer is active until the data buffer is full. Because of this (if not
needed), it is recommended to avoid using the Suspend Command for the SDIO card.
This is because when such a command is sent, the uSDHC thinks the System will switch
to another function on the SDIO card, and flush the data buffer. The uSDHC takes the
Resume Command as a normal command with data transfer, and it is left for the Driver to
set all the relevant registers before the transfer is resumed. If there is only one block to
Initialization/Application of uSDHC
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3988
NXP Semiconductors

<!-- page 3989 -->

send when the transfer is resumed, the MSBSEL and BCEN bits of the Transfer Type
register are set as well as the AC12EN bit. However, the uSDHC will automatically send
a CMD12 to mark the end of the multi-block transfer.
58.5.3.2
Block Read
Information about Normal Read, DDR Read, Read with Pause, and DLL (Delay Line) in
Read Path are detailed in the sections below.
58.5.3.2.1
Normal Read
For block reads, the basic unit of data transfer is a block whose maximum size is stored in
areas defined by the corresponding card specification. A CRC is appended to the end of
each block, ensuring data transfer integrity. The CMD17, CMD18, CMD53, CMD60,
CMD61, and so on, can initiate a block read. After completing the transfer, the card
returns to the Transfer State. For multi blocks read, data blocks will be continuously
transferred until a stop command is issued.
The software flow to read from a card incorporates the internal DMA and the read
operation is a multi-block read with the Auto CMD12 enabled. For the other two methods
(by means of external DMA or CPU polling status) with different transfer methods, the
internal DMA parts should be removed and the alternative steps should be
straightforward.
The software flow to read from a card is described below:
1. Check the card status, wait until card is ready for data.
2. Set the card block length/size:
• For SD/MMC, use SET_BLOCKLEN (CMD16)
• For SDIO cards or the I/O portion of SDCombo cards, use
IO_RW_DIRECT(CMD52) to set the I/O Block Size bit field in the CCCR
register (for function 0) or FBR register (for functions 1~7)
3. Set the uSDHC block length register to be the same as the block length set for the
card in Step 2.
4. Set the uSDHC number block register (NOB), nob is 5 (for instance).
5. Disable the buffer read ready interrupt, configure the DMA settings and enable the
uSDHC DMA when sending the command with data transfer. The AC12EN bit
should also be set.
6. Wait for the Transfer Complete interrupt.
7. Check the status bit to see if a read CRC error occurred, or some another error,
occurred during the auto12 command sending and response receiving.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3989

<!-- page 3990 -->

58.5.3.2.2
DDR Read
uSDHC supports dual data rate mode.
The software flow to write to a card in ddr mode is described below:
1. Check the card status, wait until the card is ready for data.
2. For eMMC4.4 card, block length only can be set to 512byte.
3. Set the uSDHC number block register (NOB), nob is 5 (for instance).
4. Set eMMC4.4 card to high speed mode, use SWITCH(CMD6).
5. Set eMMC4.4 card bus with (4-bit /8-bit ddr mode), use SWITCH(CMD6).
6. Disable the buffer write ready interrupt, configure the DMA settings and enable the
uSDHC DMA when sending the command with data transfer.The DDR_EN bit
should be set. The AC12EN bit should also be set.
7. Wait for the Transfer Complete interrupt.
8. Check the status bit to see if a write CRC error occurred, or some another error, that
occurred during the auto12 command sending and response receiving.
58.5.3.2.3
Read with Pause
The read operation is not generally able to pause. Only the SDIO card (and SDCombo
card working under I/O mode) supporting the Read Wait feature can pause during the
read operation. If the SDIO card supports Read Wait (SRW bit in CCCR register is 1),
the Driver can set the SABGREQ bit in the Protocol Control register to pause the transfer
between the data blocks.
Before setting the SABGREQ bit, make sure the RWCTL bit in the Protocol Control
register is set, otherwise the uSDHC will not assert the Read Wait signal during the block
gap and data corruption occurs. It is recommended to set the RWCTL bit once the Read
Wait capability of the SDIO card is recognized.
Like in the flow described in Normal Read, the read with pause is shown with the same
kind of read operation:
1. Check the SRW bit in the CCR register on the SDIO card to confirm the card
supports Read Wait.
2. Set the RWCTL bit.
3. Check the card status and wait until the card is ready for data.
4. Set the card block length/size:
• For SD/MMC, use SET_BLOCKLEN (CMD16)
• For SDIO cards or the I/O portion of SDCombo cards, use
IO_RW_DIRECT(CMD52) to set the I/O Block Size bit field in the CCCR
register (for function 0) or FBR register (for functions 1~7)
Initialization/Application of uSDHC
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3990
NXP Semiconductors

<!-- page 3991 -->

5. Set the uSDHC block length register to be the same as the block length set for the
card in Step 2.
6. Set the uSDHC number block register (NOB), nob is 5 (for instance).
7. Disable the buffer read ready interrupt, configure the DMA setting and enable the
uSDHC DMA when sending the command with data transfer. The AC12EN bit
should also be set
8. Set the SABGREQ bit.
9. Wait for the Transfer Complete interrupt.
10. Clear the SABGREQ bit.
11. Check the status bit to see if read CRC error occurred.
12. Set the CREQ bit to continue the read operation.
13. Wait for the Transfer Complete interrupt.
14. Check the status bit to see if a read CRC error occurred, or some another error,
occurred during the auto12 command sending and response receiving.
Like the write operation, it is possible to meet the ending block of the transfer when
paused. In this case, the uSDHC will ignore the Stop At Block Gap Request and treat it as
a command read operation.
Unlike the write operation, there is no remaining data inside the buffer when the transfer
is paused. All data received before the pause will be transferred to the Host System. No
matter if the Suspend Command is sent or not, the internal data buffer is not flushed.
If the Suspend Command is sent and the transfer is later resumed by means of a Resume
Command, the uSDHC takes the command as a normal one accompanied with data
transfer. It is left for the Driver to set all the relevant registers before the transfer is
resumed. If there is only one block to send when the transfer is resumed, the MSBSEL
and BCEN bits of the Transfer Type register are set, as well as the AC12EN bit.
However, the uSDHC will automatically send the CMD12 to mark the end of multi-block
transfer.
58.5.3.2.4
DLL (Delay Line) in Read Path
The DLL(Delay Line) is newly added to assist in sampling read data. The DLL provides
the ability to programmatically select a quantized delay (in fractions of the clock period)
regardless of on-chip variations such as process, voltage and temperature (PVT).
The reasons why the DLL is needed for uSDHC are 1.) the path of read data traveling
from card to host varies. 2.) in SD/MMC DDR mode the minimum input setup and hold
time are both at 2.5 ns. The data sampling window is so small that the delay of loopback
clock needs to be accurate and consistent regardless of PVT. The DLL takes the divided
card_clk as the reference clock and loopback clock as the input clock. It then generates a
delayed version of the input clock according to the programmed target delay.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3991

<!-- page 3992 -->

The DLL can be disabled or bypassed, and it can also be manually set for a fixed delay in
override mode. The override value set is the number of delay cells. In override mode,
there is no need to set the DLL_enable. Another DLL mode is target value mode. In this
mode, the DLL will automatically adjust the number of delay cells according to target
value set by user and PVT changes. Be aware that target value is in units of 1/32 of the
clock reference period. If the card_clk is 100Mhz, then the reference clock period is 10ns,
setting target vaule of 16 means 5ns =(16/32)*10ns. Software can disable automatic
update by setting dll_gate_update bit. Please refer to Figure 58-20.
Since the user may change the frequency of the card_clk from time to time by changing
SDCLKFS[7:0]/DVS[3:0], the software must adjust the delay value to ensure it works
correctly when the reference clock (card_clk) is changed. The following is the correct
flow, which should be ignored if DLL_CTRL_ENABLE is not set.
Step 1: Set DLL_CTRL_RESET bit
Step 2: Configure the SDCLKFS[7:0] and DVS[3:0]
Step 3: Wait until SDSTB is asserted
Step 4: clear DLL_CTRL_RESET bit
Step 5: Wait until both DLL_STS_SLV_LOCK and DLL_STS_REF_LOCK are asserted
Step 6: set DLL_CTRL_SLV_FORCE_UPD
Step 7: clear DLL_CTRL_SLV_FORCE_UPD
NOTE:Software should make sure the DLL_CTRL_SLV_FORCE_UPD is lasted for at
least one card_clk. So software may need to add some delay between step6 and step7.
Initialization/Application of uSDHC
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3992
NXP Semiconductors

<!-- page 3993 -->

Read Data
Async
Buffer
6
5
4
3
1
2
Delay line
DDR_EN
/2
Card_clk
uSDHC
ipp_card_clk_in
ipp_card_clk_in_dll
card_clk_pad
DATA
8
SD/MMC
Figure 58-20. DLL(Delay Line) in Read Path
58.5.3.3
Suspend Resume
The uSDHC supports the Suspend Resume operations of SDIO cards, although slightly
differently than the suggested implementation of Suspend in the SDIO card specification.
58.5.3.3.1
Suspend
After setting the SABGREQ bit, the Host Driver may send a Suspend command to switch
to another function of the SDIO card. The uSDHC does not monitor the content of the
response, so it doesn't know if the Suspend command succeeded or not. Accordingly, it
doesn't de-assert Read Wait for read pause. To solve this problem, the Driver shall not
mark the Suspend command as a "Suspend", (i.e. setting the CMDTYP bits to 01).
Instead, the Driver shall send this command as if it were a normal command, and only
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3993

<!-- page 3994 -->

when the command succeeds, and the BS bit is set in the response, can the Driver send
another command marked as "Suspend" to inform the uSDHC that the current transfer is
suspended. As shown in the following sequence for Suspend operation:
1. Set the SABREQ bit to pause the current data transfer at block gap.
2. After the BGE bit is set, send the Suspend command to suspend the active function.
The CMDTYP bit field must be 2'b00.
3. Check the BS bit of the CCCR in the response. If it is 1, repeat this step until the BS
bit is cleared or abandon the suspend operation according to the Driver strategy.
4. Send another normal I/O command to the suspended function. The CMDTYP of this
command must be 2'b01, so the uSDHC can detect this special setting and be
informed that the paused operation has successfully suspended. If the paused transfer
is a read operation, the uSDHC stops driving DATA2 and goes to the idle state.
5. Save the context registers in the system memory for later use, including the DMA
System Address Register (for internal DMA operation), and the Block Attribute
Register.
6. Begin operation for another function on the SDIO card.
58.5.3.3.2
Resume
To resume the data transfer, a Resume command shall be issued:
1. To resume the suspended function, restore the context register with the saved value
in step #5 of the Suspend operation above.
2. Send the Resume command. In the Transfer Type register, all bit fields are set to the
value as if this were another ordinary data transfer, instead of a transfer resume
(except the CMDTYP is set to 2'b10).
3. If the Resume command has responded, the data transfer will be resumed.
58.5.3.4
ADMA Usage
To use the ADMA in a data transfer, the Host Driver must prepare the correct descriptor
chain prior to sending the read/write command.
The steps to prepare the correct descriptor chain are:
1. Create a descriptor to set the data length that the current descriptor group is about to
transfer. The data length should be even numbers of the block size.
2. Create another descriptor to transfer the data from the address setting in this
descriptor. The data address must be at a page boundary (4kB address aligned).
3. If necessary, create a Link descriptor containing the address of the next descriptor.
The descriptor group is created in steps 1 ~ 3.
Initialization/Application of uSDHC
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3994
NXP Semiconductors

<!-- page 3995 -->

4. Repeat steps 1 ~ 3 until all descriptors are created.
5. In the last descriptor, set the End flag to 1 and make sure the total length of all
descriptors match the product of the block size and block number configured in the
Block Attribute Register.
6. Set the ADMA System Address Register to the address of the first descriptor and set
the DMAS field in the Protocol Control Register to 01 to select the ADMA.
7. Issue a write or read command with the DMAEN bit set to 1 in the Transfer Type
Register.
Steps 1 ~ 5 are independent of step 6, so step 6 can finish before steps 1 ~ 5. Regarding
the descriptor configuration, it is recommended not to use the Link descriptor as it
requires extra system memory access.
58.5.3.5
Transfer Error
Information about CRC, Internal DMA, Transfer ADMA, and Auto CMD12 Errors are
detailed in the sections below.
58.5.3.5.1
CRC Error
It is possible at the end of a block transfer, that a write CRC status error or read CRC
error occurs. For this type of error the latest block received shall be discarded. This is
because the integrity of the data block is not guaranteed. It is recommended to discard the
following data blocks and re-transfer the block from the corrupted one.
For a multi-block transfer, the Host Driver shall issue a CMD12 to abort the current
process and start the transfer by a new data command. In this scenario, even when the
AC12EN and BCEND bits are set, the uSDHC does not automatically send a CMD12
because the last block is not transferred. On the other hand, if it is within the last block
that the CRC error occurs, an Auto CMD12 will be sent by the uSDHC. In this case, the
Driver shall re-send or re-obtain the last block with a single block transfer.
58.5.3.5.2
Internal DMA Error
During the data transfer with internal Simple DMA, if the DMA engine encounters some
error on the AHB bus, the DMA operation is aborted and DMA Error interrupt is sent to
the Host System. When acknowledged by such an interrupt, the Driver shall calculate the
start address of data block in which the error occurs.
The start address can be calculated by either:
1. Reading the DMA System Address register. The error occurs during the previous
burst. Taking the block size, the previous burst length and the start address of the
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3995

<!-- page 3996 -->

next burst transfer into account, it is straight forward to obtain the start address of the
corrupted block.
2. Reading the BLKCNT field of the Block Attribute register. By the number of blocks
left, the total number to transfer, the start address of transfer, and the size of each
block, the start address of corrupted block can be determined. When the BCEN bit is
not set, the contents of the Block Attribute register does not change, so this method
does not work.
When a DMA error occurs, it is recommended to abort the current transfer by means of a
CMD12 (for multi block transfer), apply a reset for data, and re-start the transfer from the
corrupted block to recover from the error.
58.5.3.5.3
Transfer ADMA Error
There are 3 kinds of possible ADMA errors. The AHB transfer, invalid descriptor, and
data-length mismatch errors. Whenever these errors occur, the DMA transfer stops and
the corresponding error status bit is set.
For acknowledging the status, the Host Driver should recover the error as shown below
and re-transfer from the place of interruption.
1. AHB transfer error: Such errors may occur during data transfer or descriptor fetch.
For either scenario, it is recommended to retrieve the transfer context, reset for the
data part and re-transfer the block that was corrupted, or the next block if no block is
corrupted.
2. Invalid descriptor error: For such errors, it is recommended to retrieve the transfer
context, reset for the data part and re-create the descriptor chain from the invalid
descriptor and issue a new transfer. As the data to transfer now may be less than the
previous setting, the data length configured in the new descriptor chain should match
the new value.
3. Data-length mismatch error: It is similar to recover from this error. The Host Driver
polls relating registers to retrieve the transfer context, apply a reset for the data part,
configure a new descriptor chain, and make another transfer if there is data left. Like
the previous scenario of the invalid descriptor error, the data length must match the
new transfer.
58.5.3.5.4
Auto CMD12 Error
After the last block of the multi block transfer is sent or received, and the AC12EN bit is
set when the data transfer is initiated by the data command, the uSDHC automatically
sends a CMD12 to the card to stop the transfer.
Initialization/Application of uSDHC
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3996
NXP Semiconductors

<!-- page 3997 -->

When errors with this command occur, it is recommended to the Driver to deal with the
situations in the following manner:
1. Auto CMD12 response time-out. It is not certain whether the command is accepted
by the card or not. The Driver should clear the Auto CMD12 error status bits and re-
send the CMD12 until it is accepted by the card.
2. Auto CMD12 response CRC error. Since card responds to the CMD12, the card will
abort the transfer. The Driver may ignore the error and clear the error status bit.
3. Auto CMD12 conflict error or not sent. The command is not sent, so the Driver shall
send a CMD12 manually.
58.5.3.6
Card Interrupt
The external cards can inform the Host Controller by means of some special signals. For
the SDIO card, it can be the low level on the DATA1 line during some special period.
The uSDHC only monitors the DATA1 line and supports the SDIO interrupt.
When the SDIO interrupt is captured by the uSDHC, and the Host System is informed by
the uSDHC asserting the uSDHC interrupt line, the interrupt service from the Host Driver
is called.
As the interrupt source is controlled by the external card, the interrupt from the SDIO
card must be serviced before the CINT bit is cleared by written. Refer to Card Interrupt
Handling for the card interrupt handling flow.
58.5.4
Switch Function
A switch command must be issued by the Host Driver to enable new features added to the
SD/MMC spec. SD/MMC cards can transfer data at bus widths other than 1-bit. Different
speed mode are also defined. To enable these features, a switch command shall be issued
by the Host Driver.
For SDIO cards, the high speed mode/DDR50/SDR50/SDR104 are enabled by writing
the EHS bit in the CCCR register after the SHS bit is confirmed. For SD cards, the high
speed mode/DDR50/SDR50/SDR104 are queried and enabled by a CMD6 (with the
mnemonic symbol as SWITCH_FUNC). For MMC cards, the high speed mode/HS200
are queried by a CMD8 and enabled by a CMD6 (with the mnemonic symbol as
SWITCH).
The SDR4-bit, SDR8-bit, DDR4-bit and DDR8-bit width of the MMC is also enabled by
the SWITCH command, but with a different argument.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3997

<!-- page 3998 -->

These new functions can also be disabled by a software reset. For SDIO cards it can be
done by setting the RES bit in the CCCR register. For other cards, it can be accomplished
by issuing a CMD0. This method of restoring to the normal mode is not recommended
because a complete identification process is needed before the card is ready for data
transfer.
For the sake of simplicity, the following pseudocode examples do not show current
capability check, which is recommended in the function switch process.
58.5.4.1
Query, Enable and Disable SDIO High Speed Mode
enable_sdio_high_speed_mode(void)
{
send CMD52 to query bit SHS at address 0x13;
if (SHS bit is '0') report the SDIO card does not support high speed mode and return;
send CMD52 to set bit EHS at address 0x13 and read after write to confirm EHS bit is set;
change clock divisor value or configure the system clock feeding into uSDHC to generate the 
card_clk of around 50MHz;
(data transactions like normal peers)
}
disable_sdio_high_speed_mode(void)
{
send CMD52 to clear bit EHS at address 0x13 and read after write to confirm EHS bit is 
cleared;
change clock divisor value or configure the system clock feeding into uSDHC to generate the 
card_clk of the desired value below 25MHz;
(data transactions like normal peers)
}
58.5.4.2
Query, Enable and Disable SD High Speed Mode/SDR50/
SDR104/DDR50
enable_sd_speed_mode(void)
{
set BLKCNT field to 1 (block), set BLKSIZE field to 64 (bytes);
send CMD6, with argument 0xFFFFFx and read 64 bytes of data accompanying the R1 response;
(high speed mode,x=1; SDR50,x=2; SDR104,x=3; DDR50,x=4;)
wait data transfer done bit is set;
check if the bit x of received 512 bits is set;
if (bit 401 is '0') report the SD card does not support high speed mode and return;
if (bit 402 is '0') report the SD card does not support SDR50 mode and return;
if (bit 403 is '0') report the SD card does not support SDR104 mode and return;
if (bit 404 is '0') report the SD card does not support DDR50 mode and return;
send CMD6, with argument 0x80FFFFFx and read 64 bytes of data accompanying the R1 response;
(high speed mode,x=1; SDR50,x=2; SDR104 x=3; DDR50 x=4;)
check if the bit field 379~376 is 0xF;
if (the bit field is 0xF) report the function switch failed and return;
change clock divisor value or configure the system clock feeding into uSDHC to generate the 
card_clk of around 50MHz for high speed mode, 100Mhz for SDR50, 200Mhz for SDR104, 50Mhz for 
DDR50;
(data transactions like normal peers)
}
disable_sd_speed_mode(void)
{
set BLKCNT field to 1 (block), set BLKSIZE field to 64 (bytes);
send CMD6, with argument 0x80FFFFF0 and read 64 bytes of data accompanying the R1 response;
check if the bit field 379~376 is 0xF;
Initialization/Application of uSDHC
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3998
NXP Semiconductors

<!-- page 3999 -->

if (the bit field is 0xF) report the function switch failed and return;
change clock divisor value or configure the system clock feeding into uSDHC to generate the 
card_clk of the desired value below 25MHz;
(data transactions like normal peers)
}
58.5.4.3
Query, Enable and Disable MMC High Speed Mode
enable_mmc_high_speed_mode(void)
{
send CMD9 to get CSD value of MMC;
check if the value of SPEC_VER field is 4 or above;
if (SPEC_VER value is less than 4) report the MMC does not support high speed mode and 
return;
set BLKCNT field to 1 (block), set BLKSIZE field to 512 (bytes);
send CMD8 to get EXT_CSD value of MMC;
extract the value of CARD_TYPE field to check the 'high speed mode' in this MMC is 26MHz or 
52MHz;
send CMD6 with argument 0x1B90100;
send CMD13 to wait card ready (busy line released);
send CMD8 to get EXT_CSD value of MMC;
check if HS_TIMING byte (byte number 185) is 1;
if (HS_TIMING is not 1) report MMC switching to high speed mode failed and return;
change clock divisor value or configure the system clock feeding into uSDHC to generate the 
card_clk of around 26MHz or 52MHz according to the CARD_TYPE;
(data transactions like normal peers)
}
disable_mmc_high_speed_mode(void)
{
send CMD6 with argument 0x2B90100;
set BLKCNT field to 1 (block), set BLKSIZE field to 512 (bytes);
send CMD8 to get EXT_CSD value of MMC;
check if HS_TIMING byte (byte number 185) is 0;
if (HS_TIMING is not 0) report the function switch failed and return;
change clock divisor value or configure the system clock feeding into uSDHC to generate the 
card_clk of the desired value below 20MHz;
(data transactions like normal peers)
}
58.5.4.4
Set MMC Bus Width
change_mmc_bus_width(void)
{
send CMD9 to get CSD value of MMC;
check if the value of SPEC_VER field is 4 or above;
if (SPEC_VER value is less than 4) report the MMC does not support multiple bit width and 
return;
send CMD6 with argument 0x3B70x00; (8-bit(dual data rate), x=6; 4-bit(dual data rate), x=5;8-
bit, x=2; 4-bit, x=1; 1-bit, x=0)
send CMD13 to wait card ready (busy line released);
(data transactions like normal peers)
}
58.5.5
ADMA Operation
Code for ADMA1 Operation and ADMA2 Operation can be found here.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3999

<!-- page 4000 -->

58.5.5.1
ADMA1 Operation
Set_adma1_descriptor
{
if (to start data transfer) {
// Make sure the address is 4KB align.
Set 'Set' type descriptor;
{
Set Act bits to 01;
Set [31:12] bits data length (byte unit);
}
Set 'Tran' type descriptor;
{
Set Act bits to 10;
Set [31:12] bits address (4KB align);
}
}
else if (to fetch descriptor at non-continuous address) {
Set Act bits to 11;
Set [31:12] bits the next descriptor address (4KB aligned);
}
else { // other types of descriptor
Set Act bits accordingly
}
if (this descriptor is the last one) {
Set End bit to 1;
}
if (to generate interrupt for this descriptor) {
Set Int bit to 1;
}
Set Valid bit to 1;
}
58.5.5.2
ADMA2 Operation
Set_adma2_descriptor
{
if (to start data transfer) {
// Make sure the address is a 32-bit boundary (lower 2-bit are always '00').
Set higher 32-bit of descriptor for this data transfer initial address;
Set [31:16] bits data length (byte unit);
Set Act bits to '10';
}
else if (to fetch descriptor at non-continuous address) {
Set Act bits to '11';
// Make sure the address is 32-bit boundary (lower 2-bit are always set to '00').
Set higher 32-bit of descriptor for the next descriptor address;
}
else { // other types of descriptor
Set Act bits accordingly
}
if (this descriptor is the last one) {
Set 'End' bit '1';
}
if (to generate interrupt for this descriptor) {
Set 'Int' bit '1';
}
Set the 'Valid' bit to '1';
}
Initialization/Application of uSDHC
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4000
NXP Semiconductors

<!-- page 4001 -->

58.5.6
Fast Boot Operation
58.5.6.1
Normal fast boot flow
1. Software must configure init_active bit (system control register bit 27) to make sure
74 card clocks are finished.
2. Software must configure the MMC Boot Register (offset 0xc4) bit 6 to 1 (enable
boot), and bit 5 to 0 (normal fast boot), and bit 4 to select the ack mode or not. If the
data will be sent through DMA mode, the software should configure bit 7 to enable
the automatic stop at block gap feature, and configure bit 3-bit 0 to select the ack
timeout value according to the SD CLK frequency.
3. Software then needs to configure the Block Attributes Register to set the block size
and count. If in DDR fast boot mode, the block size only can be configured to 512
bytes.
4. Software must configure the Protocol control register to set DTW (data transfer
width). If in DDR fast boot mode, DTW only can be configured to 4-bit/8-bit
dataline mode.
5. Software needs to configure the Command Argument Register to set argument if
needed (no need in normal fast boot).
6. Software must configure the Transfer Type Register to start the boot process. In
normal boot mode, CMDINX, CMDTYP, RSPTYP, CICEN, CCCEN, AC12EN,
BCEN and DMAEN are kept at the default value. DPSEL bit is set to 1, DTDSEL is
set to 1, MSBSEL is set to 1.
7. DMAEN should be configured as 0 in polling mode. And if BCEN is configured as
1, it is recommended to configure the number of blocks in the Block Attributes
Register to the maximum value. If in DDR fast boot mode, DDR_EN needs to be set
to 1.
8. When the step 6 is configured, the boot process will begin. Software needs to poll the
data buffer ready status to read the data from the buffer in time. If a boot timeout
happens (ack times out or the first data read times out), an interrupt will be triggered,
and software must configure MMC Boot Register to bit 6 to 0 to disable boot. This
makes CMD high, then after at least 56 clocks, it is ready to begin a normal
initialization process.
9. If there is no timeout, software needs to determine when the data read is finished and
then configure MMC Boot Register bit 6 to 0 to disable boot. This will make CMD
line high and command completed asserted. After at least 56 clocks, it is ready to
begin normal initialization process.
10. Reset the host and then can begin the normal process.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4001

<!-- page 4002 -->

58.5.6.2
Alternative fast boot flow
1. Software needs to configure init_active bit (system control register bit 27) to make
sure 74 card clocks are finished.
2. Software needs to configure MMC Boot Register (offset 0xc4) bit 6 to 1 (enable
boot), and bit 5 to 1 (alternative boot), and bit 4 to select the ack mode or not. If data
needs to be sent through DMA mode, then configure bit 7 to enable the automatic
stop at block gap feature. Software should also configure bit 3-bit 0 to select the ack
timeout value according to the SD clock frequency.
3. Software then needs to configure Block Attributes Register to set the block size and
count. If in DDR fast boot mode, the block size only can be configured to 512 bytes.
4. Software needs to configure the Protocol control register to set the DTW (data
transfer width). If in ddr fast boot mode, DTW only can be configure to 4-bit/8-bit
dataline mode.
5. Software needs to configure Command Argument Register to set argument to
0xFFFFFFFA.
6. Software needs to configure the Transfer Type Register to start the boot process by
CMD0 with 0xFFFFFFFA argument . In alternative boot, CMDINX, CMDTYP,
RSPTYP, CICEN, CCCEN, AC12EN, BCEN and DMAEN are kept default value.
DPSEL bit is set to 1, DTDSEL is set to 1, MSBSEL is set to 1. Note DMAEN
should be configured as 0 in polling mode. And if BCEN is configured as 1 in
polling mode, it is recommended to configure the block count in the Block Attributes
Register to the maximum value. If in DDR fast boot mode, DDR_EN needs to be set
to 1.
7. When the step 6 is configured, the boot process will begin. Software needs to poll the
data buffer ready status to read the data from the buffer in time. If there is a boot
timeout (ack data timeout in 50ms or data timeout in 1s), the host will send out the
interrupt and software needs to send CMD0 with reset and then configure the boot
enable bit to 0 to stop this process..
8. If there is no time out, software needs to decide when to stop the boot process, and
send out the CMD0 with reset and then after the command is completed, configure
the MMC Boot Register bit 6 to stop the process. After 8 clocks from the command
completion, the slave (card) is ready for the identification step.
9. Reset the host and then begin the normal process.
58.5.6.3
Fast boot application case (in DMA mode)
In the boot application case, because the image destination and the image size are
contained in the beginning of the image, it is necessary to switch DMA parameters on the
fly during MMC fast boot.
Initialization/Application of uSDHC
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4002
NXP Semiconductors

<!-- page 4003 -->

In fast boot, the host can use ADMA2 (Advanced DMA2) with two destinations.
The detail flow is described below:
1. Software needs to configure INIT_ACTIVE bit (system control register bit 27) to
make sure 74 card clocks are finished.
2. Software needs to configure the MMC Boot Register (offset 0xc4) bit 6 to 1 (enable
boot); and bit 5 to 0 (normal fast boot) or 1 (alternative boot); and bit 4 to select the
ack mode or not. In DMA mode, configure bit 7 to 1 to enable the automatic stop at
block gap feature. Also configure bits[31-16] to set the (BLK_CNT -
VALUE1).Here VALUE1 is the value of the block count that needs to transfer the
first time, so that that the hostwill stop at the block gap when the uSDHC controller
gets VAULE1 blocks from the device. Also configure bits[3-0] to select the ack
timeout value according to the SD clock frequency.
3. Software then needs to configure the Block Attributes Register to set block size and
count. If in DDR fast boot mode, the block size only can be configured to 512 bytes.
In DMA mode, it is recommended to set the block count (BLK_CNT) to the max
value (16'hffff).
4. Software needs to configure Protocol Control Register to set DTW (data transfer
width). If in DDR fast boot mode, the DTW only can be configured to 4-bit/8-bit
dataline mode.
5. Software enbable ADMA2 by configuring Protocol Control Register bits [9-8].
6. Software need to set at least three pairs ADMA2 descriptor in boot memory (ie, in
IRAM, at least 6 word). The first pair descriptor define the start address (ie,
IRAM)and data length(ie,512byte*VALUE1) of fisrt part boot code. Software also
need to set the second pair descriptor, the second start address (any value that is
writeable), data length is suggest to set 1~2word(record as VALUE2). Note: the
second couple desc also transfer useful data even at lease 1 word. Because our
ADMA2 can't support 0 data_length data transfer descriptor.
7. Software needs to configure Command Argument Register to set argument to
0xFFFFFFFA in alternative fast boot, and don't need set in normal fast boot.
8. Software needs to configure Transfer Type Register to start the boot process .
CMDINX, CMDTYP, RSPTYP, CICEN, CCCEN, AC12EN, BCEN and DMAEN
are kept default value. DPSEL bit is set to 1, DTDSEL is set to 1, MSBSEL is set to
1. DMAEN is configured as 1 in DMA mode. And if BCEN is configured as 1, better
to configure blk no in Bock Attributes Register to the max value. And if in ddr fast
boot mode, DDR_EN need to be set to 1.
9. When the step 8 is configured, boot process will begin, the first VALUE1 block
number data has transfer. Software need to polling TC bit (bit1 in Interrupt Status
Register) to determine first transfer is end. Also software need to polling BGE bit
(bit2 in Interrupt Status Register) to determine if first transfer stop at block gap.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4003

<!-- page 4004 -->

10. When TC, BGE bit is 1, . SW can analyzes the first code of VALUE1 block,
initializes the new memory device, if required, and sets the third pair of descriptors to
define the start address and length of the remaining part of boot code(VALUE3 the
remain boot code block). Remeber set the last descriptor with END.
11. Software needs to configure MMC Boot Register (offset 0xc4) again. Set bit 6 to
1(enable boot); and bit 5 to 0(normal fast boot), to 1(alternative boot); and bit 4 to
select the ack mode or not. In DMA mode, configure bit 7 to 1 for enable
automatically stop at block gap feature. Also configure bit31-bit16 to set the
(BLK_CNT - (VALUE1+1+VALUE3)), that host will stop at block gap when the
uSDHC controller gets (VALUE1+1+VALUE3)) blocks from device totally include
the blocks received in step 9. And need to configure bit 3-bit0 to select the ack
timeout value according to the sd clk frequence. Please note, Software doesn't need
to configure the BLK_CNT again, because it's counted down automatically by the
uSDHC controller.
12. Software needs to clear TC and BGE bit. And software needs to clear SABGREQ(bit
16 in Protocol control register), and set CREQ(bit17 Protocol control register) to 1 to
resume the data transfer. Host will transfer the VALUE2 and VALUE3 data to the
destination that is set by descriptor.
13. Software need to polling BGE bit to determine if the fast boot is over.
Note:
1. When ADMA boot flow is started, for uSDHC, it is like a normal ADMA read
operation. So setting ADMA2 descriptor as the normal ADMA2 transfer.
2. Need a few words length memory to keep descriptor.
3. For the 1~2 word data in second descriptor setting, it is the useful data, so software
need to deal the data due to the application case.
58.6
Commands for MMC/SD/SDIO
A table containing the list of commands for the MMC/SD/SDIO cards can be found here.
Refer to the corresponding specifications for more details about the command
information.
There are four kinds of commands defined to control the MultiMediaCard:
1. broadcast commands (bc), no response.
2. broadcast commands with response (bcr), response from all cards simultaneously.
3. addressed (point-to-point) commands (ac), no data transfer on the DATA.
4. addressed (point-to-point) data transfer commands (adtc).
Commands for MMC/SD/SDIO
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4004
NXP Semiconductors

<!-- page 4005 -->

Response: a response is a token which is sent from the card to the host as an answner to a
previously received command. A response is transferred serially on the CMD line.
Table 58-3. Commands for MMC/SD/SDIO Cards
CMD INDEX
Type
Argument
Response
type
Abbreviation
Description
CMD0
bc
[31:0] stuff bits
-
GO_IDLE_STATE
Resets all MMC and SD memory
cards to idle state.
CMD1
bcr
[31:0] OCR without
busy
R3
SEND_OP_COND
Asks all MMC and SD Memory
cards in idle state to send their
operation conditions register
contents in the response on the
CMD line.
CMD2
bcr
[31:0] stuff bits
R2
ALL_SEND_CID
Asks all cards to send their CID
numbers on the CMD line.
CMD31
ac
[31:6] RCA
[15:0] stuff bits
R1
R6 (SDIO)
SET/
SEND_RELATIVE_AD
DR
Assigns relative address to the
card.
CMD4
bc
[31:0] DSR
[15:0] stuff bits
-
SET_DSR
Programs the DSR of all cards.
CMD5
bc
[31:0] OCR without
busy
R4
IO_SEND_OP_COND
Asks all SDIO cards in idle state to
send their operation conditions
register contents in the response
on the CMD line.
CMD62
adtc
[31] Mode
0: Check function
1: Switch function
[30:8] Reserved for
function groups 6 ~ 3
(All 0 or 0xFFFF)
[7:4] Function group1
for command system
[3:0] Function group2
for access mode
R1
SWITCH_FUNC
Checks switch ability (mode 0) and
switch card function (mode 1).
Refer to "SD Physical Specification
V1.1" for more details.
CMD63
ac
[31:26] Set to 0
[25:24] Access
[23:16] Index
[15:8] Value
[7:3] Set to 0
[2:0] Cmd Set
R1b
SWITCH
Switches the mode of operation of
the selected card or modifies the
EXT_CSD registers. Refer to "The
MultiMediaCard System
Specification Version 4.0 Final draft
2" for more details.
CMD7
ac
[31:6] RCA
[15:0] stuff bits
R1b
SELECT/
DESELECT_CARD
Toggles a card between the stand-
by and transfer states or between
the programming and disconnect
states. In both cases, the card is
selected by its own relative address
and gets deselected by any other
address. Address 0 deselects all.
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4005

<!-- page 4006 -->

Table 58-3. Commands for MMC/SD/SDIO Cards (continued)
CMD INDEX
Type
Argument
Response
type
Abbreviation
Description
CMD8
adtc
[31:0] stuff bits
R1
SEND_EXT_CSD
The card sends its EXT_CSD
register as a block of data, with a
block size of 512 bytes.
CMD9
ac
[31:6] RCA
[15:0] stuff bits
R2
SEND_CSD
Addressed card sends its card-
specific data (CSD) on the CMD
line.
CMD10
ac
[31:6] RCA
[15:0] stuff bits
R2
SEND_CID
Addressed card sends its card-
identification (CID) on the CMD
line.
CMD11
adtc
[31:0] data address
R1
READ_DAT_UNTIL_S
TOP
Reads data stream from the card,
starting at the given address, until a
STOP_TRANSMISSION follows.
CMD12
ac
[31:0] stuff bits
R1b
STOP_TRANSMISSIO
N
Forces the card to stop
transmission.
CMD13
ac
[31:6] RCA
[15:0] stuff bits
R1
SEND_STATUS
Addressed card sends its status
register.
CMD14
Reserved
CMD15
ac
[31:6] RCA
[15:0] stuff bits
-
GO_INACTIVE_STAT
E
Sets the card to inactive state in
order to protect the card stack
against communication
breakdowns.
CMD16
ac
[31:0] block length
R1
SET_BLOCKLEN
Sets the block length (in bytes) for
all following block commands (read
and write). Default block length is
specified in the CSD.
CMD17
adtc
[31:0] data address
R1
READ_SINGLE_BLOC
K
Reads a block of the size selected
by the SET_BLOCKLEN command.
CMD18
adtc
[31:0] data address
R1
READ_MULTIPLE_BL
OCK
Continuously transfers data blocks
from card to host until interrupted
by a stop command.
CMD19
Reserved
CMD20
adtc
[31:0] data address
R1
WRITE_DAT_UNTIL_
STOP
Writes data stream from the host,
starting at the given address, until a
STOP_TRANSMISION follows.
CMD21-23
Reserved
CMD24
adtc
[31:0] data address
R1
WRITE_BLOCK
Writes a block of the size selected
by the SET_BLOCKLEN command.
CMD25
adtc
[31:0] data address
R1
WRITE_MULTIPLE_B
LOCK
Continuously writes blocks of data
until a STOP_TRANSMISSION
follows.
CMD26
adtc
[31:0] stuff bits
R1
PROGRAM_CID
Programming of the card
identification register. This
command shall be issued only
once per card. The card contains
hardware to prevent this operation
Table continues on the next page...
Commands for MMC/SD/SDIO
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4006
NXP Semiconductors

<!-- page 4007 -->

Table 58-3. Commands for MMC/SD/SDIO Cards (continued)
CMD INDEX
Type
Argument
Response
type
Abbreviation
Description
after the first programming.
Normally this command is reserved
for the manufacturer.
CMD27
adtc
[31:0] stuff bits
R1
PROGRAM_CSD
Programming of the programmable
bits of the CSD.
CMD28
ac
[31:0] data address
R1b
SET_WRITE_PROT
If the card has write protection
features, this command sets the
write protection bit of the
addressed group. The properties of
write protection are coded in the
card specific data
(WP_GRP_SIZE).
CMD29
ac
[31:0] data address
R1b
CLR_WRITE_PROT
If the card provides write protection
features, this command clears the
write protection bit of the
addressed group.
CMD30
adtc
[31:0] write protect
data address
R1
SEND_WRITE_PROT
If the card provides write protection
features, this command asks the
card to send the status of the write
protection bits.
CMD31
Reserved
CMD32
ac
[31:0] data address
R1
TAG_SECTOR_STAR
T
Sets the address of the first sector
of the erase group.
CMD33
ac
[31:0] data address
R1
TAG_SECTOR_END
Sets the address of the last sector
in a continuous range within the
selection of a single sector to be
selected for erase.
CMD34
ac
[31:0] data address
R1
UNTAG_SECTOR
Removes one previously selected
sector from the erase selection.
CMD35
ac
[31:0] data address
R1
TAG_ERASE_GROUP
_START
Sets the address of the first erase
group within a range to be selected
for erase.
CMD36
ac
[31:0] data address
R1
TAG_ERASE_GROUP
_END
Sets the address of the last erase
group within a continuous range to
be selected for erase.
CMD37
ac
[31:0] data address
R1
UNTAG_ERASE_GRO
UP
Removes one previously selected
erase group from the erase
selection.
CMD38
ac
[31:0] stuff bits
R1b
ERASE
Erase all previously selected
sectors.
CMD39
ac
[31:0] RCA
[15] register write flag
[14:8] register
address
[7:0] register data
R4
FAST_IO
Used to write and read 8-bit
(register) data fields. The command
addresses a card, and a register,
and provides the data for writing if
the write flag is set. The R4
response contains data read from
the address register. This
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4007

<!-- page 4008 -->

Table 58-3. Commands for MMC/SD/SDIO Cards (continued)
CMD INDEX
Type
Argument
Response
type
Abbreviation
Description
command accesses application
dependent registers which are not
defined in the MMC standard.
CMD40
bcr
[31:0] stuff bits
R5
GO_IRQ_STATE
Sets the system into interrupt
mode.
CMD41
Reserved
CDM42
adtc
[31:0] stuff bits
R1b
LOCK_UNLOCK
Used to set/reset the password or
lock/unlock the card. The size of
the data block is set by the
SET_BLOCK_LEN command.
CMD43~51
Reserved
CMD52
ac
[31:0] stuff bits
R5
IO_RW_DIRECT
Access a single register within the
total 128k of register space in any
I/O function.
CMD53
ac
[31:0] stuff bits
R5
IO_RW_EXTENDED
Accesses a multiple I/O register
with a single command. Allows the
reading or writing of a large number
of I/O registers.
CMD54
Reserved
CMD55
ac
[31:16] RCA
[15:0] stuff bits
R1
APP_CMD
Indicates to the card that the next
command is an application specific
command rather that a standard
command.
CMD56
adtc
[31:1] stuff bits
[0]: RD/WR
R1b
GEN_CMD
Used either to transfer a data block
to the card or to get a data block
from the card for general purpose /
application specific commands.
The size of the data block is set by
the SET_BLOCK_LEN command.
CMD57-59
Reserved
CMD60
adtc
[31] WR
[30:24] stuff bits
[23:16] address
[15:8] stuff bits
[7:0] byte count
R1b
RW_MULTIPLE_REGI
STER
These registers are used to control
the behavior of the device and to
retrieve status information
regarding the operation of the
device. All Status and Control
registers are WORD (32-bit) in size
and are WORD aligned. CMD60
shall be used to read and write
these registers.
CMD61
adtc
[31] WR
[30:16] stuff bits
[15:0] data unit count
R1b
RW_MULTIPLE_BLO
CK
The host issues a
RW_MULTIPLE_BLOCK (CMD61)
to begin the data transfer.
CMD62-63
Reserved
ACMD64
ac
[31:2] stuff bits
[1:0] bus width
R1
SET_BUS_WIDTH
Defines the data bus width
('00'=1bit or '10'=4bit bus) to be
used for data transfer. The allowed
data bus widths are given in SCR
register.
Table continues on the next page...
Commands for MMC/SD/SDIO
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4008
NXP Semiconductors

<!-- page 4009 -->

Table 58-3. Commands for MMC/SD/SDIO Cards (continued)
CMD INDEX
Type
Argument
Response
type
Abbreviation
Description
ACMD134
adtc
[31:0] stuff bits
R1
SD_STATUS
Send the SD Memory Card status.
ACMD224
adtc
[31:0] stuff bits
R1
SEND_NUM_WR_SE
CTORS
Send the number of the written
sectors (without errors). Responds
with 32-bit plus the CRC data
block.
ACMD234
ac
[31:23] stuff bits
[22:0] Number of
blocks
R1
SET_WR_BLK_ERAS
E_COUNT
Set the number of write blocks to
be pre-erased before writing (to be
used for fast Multiple Block WR
command). "1"=default(one write
block).
ACMD414
bcr
[31:0] OCR
R3
SD_APP_OP_COND
Asks the accessed card to send its
operating condition register (OCR)
contents in the response on the
CMD line.
ACMD424
ac
[31:1] stuff bits
[0] set_cd
R1
SET_CLR_CARD_DE
TECT
Connect(1)/Disconnect(0) the
50KOhm pull-up resistor on CD_B/
DATA3 of the card.
ACMD514
adtc
[31:0] stuff bits
R1
SEND_SCR
Reads the SD Configuration
Register (SCR).
1.
CMD3 differs for MMC and SD cards. For MMC cards, it is referred to as SET_RELATIVE_ADDR, with a response type of
R1. For SD cards, it is referred to as SEND_RELATIVE_ADDR, with a response type of R6 (with RCA inside).
2.
CMD6 differs completely between high speed MMC cards and high speed SD cards. Command SWITCH_FUNC is for
high speed SD cards.
3.
Command SWITCH is for high speed MMC cards . The Index field can contain any value from 0-255, but only values
0-191 are valid. If the Index value is in the 192-255 range the card does not perform any modification and the
SWITCH_ERROR status bit in the EXT_CSD register is set. The Access Bits are shown in Table 2.
4.
ACMDs shall be preceded with the APP_CMD command. (Commands listed are used for SD only, other SD commands
not listed are not supported on this module).
The Access Bits for the EXT_CSD Access Modes are shown below.
Table 58-4. EXT_CSD Access Modes
Bits
Access Name
Operation
00
Command Set
The command set is changed according to the Cmd Set field of the argument
01
Set Bits
The bits in the pointed byte are set, according to the 1 bits in the Value field.
10
Clear Bits
The bits in the pointed byte are cleared, according to the 1 bits in the Value field.
11
Write Byte
The Value field is written into the pointed byte.
58.7
Software Restrictions
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4009

<!-- page 4010 -->

58.7.1
Initialization Active
The driver cannot set INITA bit in System Control register when any of the command
line or data lines is active, so the driver must ensure both CDIHB and CIHB bits are
cleared.
58.7.2
Software Polling Procedure
For polling read or write, once the software begins a buffer read or write, it must access
exactly the number of times as the values set in the Watermark Level Register; moreover,
if the block size is not a multiple of the value in Watermark Level Register (read and
write respectively), the software must access exactly the remaining number of words at
the end of each block.
For example, for a read operation, if the RD_WML is 4, indicating the watermark level is
16 bytes, block size is 40 bytes, and the block number is 2, then the access times for the
burst sequence in the whole transfer process must be 4, 4, 2, 4, 4, 2.
58.7.3
Suspend Operation
In order to suspend the data transfer, the software must inform uSDHC that the suspend
command is successfully accepted. To achieve this, after the Suspend command is
accepted by the SDIO card, software must send another normal command marked as
suspend command (CMDTYP bits set as '01') to inform uSDHC that the transfer is
suspended.
If software needs to resume the suspended trasnfer, it should read the value in BLKCNT
register to save the remaining number of blocks before sending the normal command
marked as suspend, otherwise on sending such 'suspend' command, uSDHC will regard
the current transfer is aborted and change BLKCNT register to its original value, instead
of keeping the remained number of blocks.
58.7.4
Data Length Setting
For either ADMA (ADMA1 or ADMA2) transfer, the data in the data buffer must be
word aligned, so the data length set in the descriptor must be a multiple of 4.
Software Restrictions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4010
NXP Semiconductors

<!-- page 4011 -->

58.7.5
(A)DMA Address Setting
To configure ADMA1/ADMA2/DMA address register, when TC bit is set, the register
will always update itself with the internal address value to support dynamic address
synchronization, so the software must ensure that the TC bit is cleared prior to
configuring ADMA1/ADMA2/DMA address register.
58.7.6
Data Port Access
Data Port does not support parallel access. For example, during an external DMA access,
it is not allowed to write any data to the Data Port by CPU; or during a CPU read
operation, it is also prohibited to write any data to the Data Port, by either CPU or
external DMA. Otherwise the data would be corrupted inside the uSDHC buffer.
58.7.7
Change Clock Frequency
uSDHC does not automatically gate off the card clock when the Host Driver changes the
clock frequency. To prevent possible glitch on the card clock, clear the
FRC_SDCLK_ON bit when changing clock divisor value(SDCLKFS or DVS in System
Control Register) or setting RSTA bit.
Also before changing the clock divisor value, Host Driver should make sure the SDSTB
bit is high.
58.7.8
Multi-block Read
For pre-defined multi-block read operation, i.e., the number of blocks to read has been
defined by previous CMD23 for MMC, or pre-defined number of blocks in CMD53 for
SDIO/SDCombo, or whatever multi-block read without abort command at card side, an
abort command, either automatic or manual CMD12/CMD52, is still required by uSDHC
after the pre-defined number of blocks are done, to drive the internal state machine to idle
mode.
In this case, the card may not respond to this extra abort command and uSDHC will get
Response Timeout. It is recommended to manually send an abort command with
RSPTYP[1:0] both bits cleared.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4011

<!-- page 4012 -->

58.8
uSDHC Memory Map/Register Definition
This section includes the module memory map and detailed descriptions of all registers.
See the table below for the register memory map for the uSDHC. All these registers only
support 32-bit accesses.
NOTE
The uSDHC registers are 32-bit wide and only support 32-bit
access.
uSDHC memory map
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
219_0000
DMA System Address (uSDHC1_DS_ADDR)
32
R/W
0000_0000h
58.8.1/4014
219_0004
Block Attributes (uSDHC1_BLK_ATT)
32
R/W
0000_0000h
58.8.2/4015
219_0008
Command Argument (uSDHC1_CMD_ARG)
32
R/W
0000_0000h
58.8.3/4017
219_000C
Command Transfer Type (uSDHC1_CMD_XFR_TYP)
32
R/W
0000_0000h
58.8.4/4017
219_0010
Command Response0 (uSDHC1_CMD_RSP0)
32
R
0000_0000h
58.8.5/4021
219_0014
Command Response1 (uSDHC1_CMD_RSP1)
32
R
0000_0000h
58.8.6/4021
219_0018
Command Response2 (uSDHC1_CMD_RSP2)
32
R
0000_0000h
58.8.7/4022
219_001C
Command Response3 (uSDHC1_CMD_RSP3)
32
R
0000_0000h
58.8.8/4022
219_0020
Data Buffer Access Port
(uSDHC1_DATA_BUFF_ACC_PORT)
32
R/W
0000_0000h
58.8.9/4024
219_0024
Present State (uSDHC1_PRES_STATE)
32
R
0000_8080h
58.8.10/
4024
219_0028
Protocol Control (uSDHC1_PROT_CTRL)
32
R/W
0880_0020h
58.8.11/
4030
219_002C
System Control (uSDHC1_SYS_CTRL)
32
R/W
8080_800Fh
58.8.12/
4035
219_0030
Interrupt Status (uSDHC1_INT_STATUS)
32
w1c
0000_0000h
58.8.13/
4038
219_0034
Interrupt Status Enable (uSDHC1_INT_STATUS_EN)
32
R/W
0000_0000h
58.8.14/
4044
219_0038
Interrupt Signal Enable (uSDHC1_INT_SIGNAL_EN)
32
R/W
0000_0000h
58.8.15/
4047
219_003C
Auto CMD12 Error Status
(uSDHC1_AUTOCMD12_ERR_STATUS)
32
R
0000_0000h
58.8.16/
4050
219_0040
Host Controller Capabilities (uSDHC1_HOST_CTRL_CAP)
32
R
07F3_B407h
58.8.17/
4053
219_0044
Watermark Level (uSDHC1_WTMK_LVL)
32
R/W
0810_0810h
58.8.18/
4056
219_0048
Mixer Control (uSDHC1_MIX_CTRL)
32
R/W
8000_0000h
58.8.19/
4057
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4012
NXP Semiconductors

<!-- page 4013 -->

uSDHC memory map (continued)
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
219_0050
Force Event (uSDHC1_FORCE_EVENT)
32
W
(always
reads 0)
0000_0000h
58.8.20/
4059
219_0054
ADMA Error Status Register
(uSDHC1_ADMA_ERR_STATUS)
32
R
0000_0000h
58.8.21/
4062
219_0058
ADMA System Address (uSDHC1_ADMA_SYS_ADDR)
32
R/W
0000_0000h
58.8.22/
4064
219_0060
DLL (Delay Line) Control (uSDHC1_DLL_CTRL)
32
R/W
0000_0200h
58.8.23/
4065
219_0064
DLL Status (uSDHC1_DLL_STATUS)
32
R
0000_0000h
58.8.24/
4067
219_0068
CLK Tuning Control and Status
(uSDHC1_CLK_TUNE_CTRL_STATUS)
32
R/W
0000_0000h
58.8.25/
4068
219_00C0
Vendor Specific Register (uSDHC1_VEND_SPEC)
32
R/W
2000_7809h
58.8.26/
4070
219_00C4
MMC Boot Register (uSDHC1_MMC_BOOT)
32
R/W
0000_0000h
58.8.27/
4073
219_00C8
Vendor Specific 2 Register (uSDHC1_VEND_SPEC2)
32
R/W
0000_0006h
58.8.28/
4074
219_00CC
Tuning Control Register (uSDHC1_TUNING_CTRL)
32
R/W
0021_2800h
58.8.29/
4076
219_4000
DMA System Address (uSDHC2_DS_ADDR)
32
R/W
0000_0000h
58.8.1/4014
219_4004
Block Attributes (uSDHC2_BLK_ATT)
32
R/W
0000_0000h
58.8.2/4015
219_4008
Command Argument (uSDHC2_CMD_ARG)
32
R/W
0000_0000h
58.8.3/4017
219_400C
Command Transfer Type (uSDHC2_CMD_XFR_TYP)
32
R/W
0000_0000h
58.8.4/4017
219_4010
Command Response0 (uSDHC2_CMD_RSP0)
32
R
0000_0000h
58.8.5/4021
219_4014
Command Response1 (uSDHC2_CMD_RSP1)
32
R
0000_0000h
58.8.6/4021
219_4018
Command Response2 (uSDHC2_CMD_RSP2)
32
R
0000_0000h
58.8.7/4022
219_401C
Command Response3 (uSDHC2_CMD_RSP3)
32
R
0000_0000h
58.8.8/4022
219_4020
Data Buffer Access Port
(uSDHC2_DATA_BUFF_ACC_PORT)
32
R/W
0000_0000h
58.8.9/4024
219_4024
Present State (uSDHC2_PRES_STATE)
32
R
0000_8080h
58.8.10/
4024
219_4028
Protocol Control (uSDHC2_PROT_CTRL)
32
R/W
0880_0020h
58.8.11/
4030
219_402C
System Control (uSDHC2_SYS_CTRL)
32
R/W
8080_800Fh
58.8.12/
4035
219_4030
Interrupt Status (uSDHC2_INT_STATUS)
32
w1c
0000_0000h
58.8.13/
4038
219_4034
Interrupt Status Enable (uSDHC2_INT_STATUS_EN)
32
R/W
0000_0000h
58.8.14/
4044
219_4038
Interrupt Signal Enable (uSDHC2_INT_SIGNAL_EN)
32
R/W
0000_0000h
58.8.15/
4047
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4013

<!-- page 4014 -->

uSDHC memory map (continued)
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
219_403C
Auto CMD12 Error Status
(uSDHC2_AUTOCMD12_ERR_STATUS)
32
R
0000_0000h
58.8.16/
4050
219_4040
Host Controller Capabilities (uSDHC2_HOST_CTRL_CAP)
32
R
07F3_B407h
58.8.17/
4053
219_4044
Watermark Level (uSDHC2_WTMK_LVL)
32
R/W
0810_0810h
58.8.18/
4056
219_4048
Mixer Control (uSDHC2_MIX_CTRL)
32
R/W
8000_0000h
58.8.19/
4057
219_4050
Force Event (uSDHC2_FORCE_EVENT)
32
W
(always
reads 0)
0000_0000h
58.8.20/
4059
219_4054
ADMA Error Status Register
(uSDHC2_ADMA_ERR_STATUS)
32
R
0000_0000h
58.8.21/
4062
219_4058
ADMA System Address (uSDHC2_ADMA_SYS_ADDR)
32
R/W
0000_0000h
58.8.22/
4064
219_4060
DLL (Delay Line) Control (uSDHC2_DLL_CTRL)
32
R/W
0000_0200h
58.8.23/
4065
219_4064
DLL Status (uSDHC2_DLL_STATUS)
32
R
0000_0000h
58.8.24/
4067
219_4068
CLK Tuning Control and Status
(uSDHC2_CLK_TUNE_CTRL_STATUS)
32
R/W
0000_0000h
58.8.25/
4068
219_40C0
Vendor Specific Register (uSDHC2_VEND_SPEC)
32
R/W
2000_7809h
58.8.26/
4070
219_40C4
MMC Boot Register (uSDHC2_MMC_BOOT)
32
R/W
0000_0000h
58.8.27/
4073
219_40C8
Vendor Specific 2 Register (uSDHC2_VEND_SPEC2)
32
R/W
0000_0006h
58.8.28/
4074
219_40CC
Tuning Control Register (uSDHC2_TUNING_CTRL)
32
R/W
0021_2800h
58.8.29/
4076
58.8.1
DMA System Address (uSDHCx_DS_ADDR)
This register contains the physical system memory address used for DMA transfers.
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
DS_ADDR
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4014
NXP Semiconductors

<!-- page 4015 -->

uSDHCx_DS_ADDR field descriptions
Field
Description
DS_ADDR
DMA System Address / Argument 2
When ACMD23_ARGU2_EN is set to 0, SDMA uses this register as system address and supports only
32-bit addressing mode. Auto CMD23 cannot be used with SDMA. When ACMD23_ARGU2_EN is set to
1, SDMA uses ADMA System Address register (05Fh – 058h) instead of this register to support both 32-bit
and 64-bit addressing. This register is used only for Argument2 and SDMA may use Auto CMD23.
1. SDMA System Address
Since the address must be word (4 bytes) aligned, the least 2 bits are reserved, always 0. When the
uSDHC stops a DMA transfer, this register points out the system address of the next contiguous
data position. It can be accessed only when no transaction is executing (i.e. after a transaction has
stopped). Read operation during transfers may return an invalid value. The Host Driver shall
initialize this register before starting a DMA transaction. After DMA has stopped, the system address
of the next contiguous data position can be read from this register.
This register is protected during a data transfer. When data lines are active, write to this register is
ignored. The Host driver shall wait, until the DLA bit in the Present State register is cleared, before
writing to this register.
The uSDHC internal DMA does not support a virtual memory system. It only supports continuous
physical memory access. And due to AHB burst limitations, if the burst must cross the 1 KB
boundary, uSDHC will automatically change SEQ burst type to NSEQ.
Since this register supports dynamic address reflecting, when TC bit is set, it automatically alters the
value of internal address counter, so SW cannot change this register when TC bit is set. Such
restriction is also listed in Software Restrictions.
2. Argument 2
This register is used with the Auto CMD23 to set a 32-bit block count value to the argument of the
CMD23 while executing Auto CMD23.
If Auto CMD23 is used with ADMA, the full 32-bit block count value can be used. If Auto CMD23 is
used without ADMA, the available block count value is limited by the Block Count register. 65535
blocks is the maximum value in this case.
58.8.2
Block Attributes (uSDHCx_BLK_ATT)
This register is used to configure the number of data blocks and the number of bytes in
each block.
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
BLKCNT
0
BLKSIZE[12:0]
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_BLK_ATT field descriptions
Field
Description
31–16
BLKCNT
Blocks Count For Current Transfer:
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4015

<!-- page 4016 -->

uSDHCx_BLK_ATT field descriptions (continued)
Field
Description
This register is enabled when the Block Count Enable bit in the Transfer Mode register is set to 1 and is
valid only for multiple block transfers. For single block transfer, this register will always read as 1. The
Host Driver shall set this register to a value between 1 and the maximum block count. The uSDHC
decrements the block count after each block transfer and stops when the count reaches zero. Setting the
block count to 0 results in no data blocks being transferred.
This register should be accessed only when no transaction is executing (i.e. after transactions are
stopped). During data transfer, read operations on this register may return an invalid value and write
operations are ignored.
When saving transfer content as a result of a Suspend command, the number of blocks yet to be
transferred can be determined by reading this register. The reading of this register should be applied after
transfer is paused by stop at block gap operation and before sending the command marked as suspend.
This is because when Suspend command is sent out, uSDHC will regard the current transfer is aborted
and change BLKCNT register back to its original value instead of keeping the dynamical indicator of
remained block count.
When restoring transfer content prior to issuing a Resume command, the Host Driver shall restore the
previously saved block count.
NOTE: Although the BLKCNT field is 0 after reset, the read of reset value is 0x1. This is because when
MSBSEL bit is indicating a single block transfer, the read value of BLKCNT is always 1.
FFFF
65535 blocks
0002
2 blocks
0001
1 block
0000
Stop Count
15–13
Reserved
This read-only field is reserved and always has the value 0.
BLKSIZE[12:0]
Transfer Block Size:
This register specifies the block size for block data transfers. Values ranging from 1 byte up to the
maximum buffer size can be set. It can be accessed only when no transaction is executing (i.e. after a
transaction has stopped). Read operations during transfers may return an invalid value, and write
operations will be ignored.
1000
4096 Bytes
800
2048 Bytes
200
512 Bytes
1FF
511 Bytes
004
4 Bytes
003
3 Bytes
002
2 Bytes
001
1 Byte
000
No data transfer
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4016
NXP Semiconductors

<!-- page 4017 -->

58.8.3
Command Argument (uSDHCx_CMD_ARG)
This register contains the SD / MMC Command Argument.
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
CMDARG[31:0]
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_CMD_ARG field descriptions
Field
Description
CMDARG[31:0]
Command Argument
The SD / MMC Command Argument is specified as bits 39-8 of the Command Format in the SD or MMC
Specification.This register is write protected when the Command Inhibit (CMD) bit in the Present State
register is set.
58.8.4
Command Transfer Type (uSDHCx_CMD_XFR_TYP)
This register is used to control the operation of data transfers. The Host Driver shall set
this register before issuing a command followed by a data transfer, or before issuing a
Resume command. To prevent data loss, the uSDHC prevents writing to the bits, that are
involved in the data transfer of this register, when data transfer is active. These bits are
DPSEL, MBSEL, DTDSEL, AC12EN, BCEN and DMAEN.
The Host Driver shall check the Command Inhibit DAT bit (CDIHB) and the Command
Inhibit CMD bit (CIHB) in the Present State register before writing to this register. When
the CDIHB bit in the Present State register is set, any attempt to send a command with
data by writing to this register is ignored; when the CIHB bit is set, any write to this
register is ignored.
On sending commands with data transfer invovled, it is mandatory that the block size is
non-zero. Block count must also be non-zero, or indicated as single block transfer (bit 5
of this register is '0' when written), or block count is disabled (bit 1 of this register is '0'
when written), otherwise uSDHC will ignore the sending of this command and do
nothing. For write command, with all above restrictions, it is also mandatory that the
write protect switch is not active (WPSPL bit of Present State Register is '1'), otherwise
uSDHC will also ignore the command.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4017

<!-- page 4018 -->

If the commands with data transfer does not receive the response in 64 clock cycles, i.e.,
response time-out, uSDHC will regard the external device does not accept the command
and abort the data transfer. In this scenario, the driver should issue the command again to
re-try the transfer. It is also possible that for some reason the card responds the command
but uSDHC does not receive the response, and if it is internal DMA (either simple DMA
or ADMA) read operation, the external system memory is over-written by the internal
DMA with data sent back from the card.
The table below shows the summary of how register settings determine the type of data
transfer.
Table 58-5. Transfer Type Register Setting for Various Transfer Types
Multi/Single Block Select
Block Count Enable
Block Count
Function
0
Don't Care
Don't Care
Single Transfer
1
0
Don't Care
Infinite Transfer
1
1
Positive Number
Multiple Transfer
1
1
Zero
No Data Transfer
The table below shows the relationship between the Command Index Check Enable and
the Command CRC Check Enable, in regards to the Response Type bits as well as the
name of the response type.
Table 58-6. Relationship Between Parameters and the Name of the Response Type
Response Type
Index Check Enable
CRC Check Enable
Name of Response Type
00
0
0
No Response
01
0
1
R2
10
0
0
R3,R4
10
1
1
R1,R5,R6
11
1
1
R1b,R5b
• In the SDIO specification, response type notation for R5b is not defined. R5 includes
R5b in the SDIO specification. But R5b is defined in this specification to specify that
the uSDHC will check the busy status after receiving a response. For example,
usually CMD52 is used with R5, but the I/O abort command shall be used with R5b.
• The CRC field for R3 and R4 is expected to be all 1 bits. The CRC check shall be
disabled for these response types.
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4018
NXP Semiconductors

<!-- page 4019 -->

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
CMDINX[5:0]
CMDTYP[1:0]
DPSEL
CICEN
CCCEN
Reserved
RSPTYP[1:0]
W
Reset
0
0
0
0
0
0
0
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
uSDHCx_CMD_XFR_TYP field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
CMDINX[5:0]
Command Index
These bits shall be set to the command number that is specified in bits 45-40 of the Command-Format in
the SD Memory Card Physical Layer Specification and SDIO Card Specification.
23–22
CMDTYP[1:0]
Command Type
There are three types of special commands: Suspend, Resume and Abort. These bits shall be set to 00b
for all other commands.
• Suspend Command: If the Suspend command succeeds, the uSDHC shall assume that the card
bus has been released and that it is possible to issue the next command which uses the DATA line.
Since the uSDHC does not monitor the content of command response, it does not know if the
Suspend command succeeded or not. It is the Host Driver's responsibility to check the status of the
Suspend command and send another command marked as Suspend to inform the uSDHC that a
Suspend command was successfully issued. Refer to Suspend Resume for more details. After the
end bit of command is sent, the uSDHC de-asserts Read Wait for read transactions and stops
checking busy for write transactions. In 4-bit mode, the interrupt cycle starts. If the Suspend
command fails, the uSDHC will maintain its current state, and the Host Driver shall restart the
transfer by setting the Continue Request bit in the Protocol Control register.
• Resume Command: The Host Driver re-starts the data transfer by restoring the registers saved
before sending the Suspend Command and then sends the Resume Command. The uSDHC will
check for a pending busy state before starting write transfers.
• Abort Command: If this command is set when executing a read transfer, the uSDHC will stop reads
to the buffer. If this command is set when executing a write transfer, the uSDHC will stop driving the
DATA line. After issuing the Abort command, the Host Driver should issue a software reset (Abort
Transaction).
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4019

<!-- page 4020 -->

uSDHCx_CMD_XFR_TYP field descriptions (continued)
Field
Description
11
Abort CMD12, CMD52 for writing I/O Abort in CCCR
10
Resume CMD52 for writing Function Select in CCCR
01
Suspend CMD52 for writing Bus Suspend in CCCR
00
Normal Other commands
21
DPSEL
Data Present Select
This bit is set to 1 to indicate that data is present and shall be transferred using the DATA line. It is set to 0
for the following:
• Commands using only the CMD line (e.g. CMD52).
• Commands with no data transfer, but using the busy signal on DATA0 line (R1b or R5b e.g. CMD38)
NOTE: In resume command, this bit shall be set, and other bits in this register shall be set the same as
when the transfer was initially launched. When the Write Protect switch is on, (i.e. the WPSPL bit
is active as '0'), any command with a write operation will be ignored. That is to say, when this bit
is set, while the DTDSEL bit is 0, writes to the register Transfer Type are ignored.
1
Data Present
0
No Data Present
20
CICEN
Command Index Check Enable
If this bit is set to 1, the uSDHC will check the Index field in the response to see if it has the same value as
the command index. If it is not, it is reported as a Command Index Error. If this bit is set to 0, the Index
field is not checked.
1
Enable
0
Disable
19
CCCEN
Command CRC Check Enable
If this bit is set to 1, the uSDHC shall check the CRC field in the response. If an error is detected, it is
reported as a Command CRC Error. If this bit is set to 0, the CRC field is not checked. The number of bits
checked by the CRC field value changes according to the length of the response. (Refer to RSPTYP[1:0]
and Command Transfer Type (uSDHC_CMD_XFR_TYP) .)
1
Enable
0
Disable
18
-
This field is reserved.
Reserved
17–16
RSPTYP[1:0]
Response Type Select
00
No Response
01
Response Length 136
10
Response Length 48
11
Response Length 48, check Busy after response
Reserved
This read-only field is reserved and always has the value 0.
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4020
NXP Semiconductors

<!-- page 4021 -->

58.8.5
Command Response0 (uSDHCx_CMD_RSP0)
This register is used to store part 0 of the response bits from the card.
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
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CMDRSP0[31:0]
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_CMD_RSP0 field descriptions
Field
Description
CMDRSP0[31:0]
Command Response 0
Refer to Command Response3 (uSDHC_CMD_RSP3) for the mapping of command responses from the
SD Bus to this register for each response type.
58.8.6
Command Response1 (uSDHCx_CMD_RSP1)
This register is used to store part 1 of the response bits from the card.
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
CMDRSP1[31:0]
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_CMD_RSP1 field descriptions
Field
Description
CMDRSP1[31:0]
Command Response 1
Refer to Command Response3 (uSDHC_CMD_RSP3) for the mapping of command responses from the
SD Bus to this register for each response type.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4021

<!-- page 4022 -->

58.8.7
Command Response2 (uSDHCx_CMD_RSP2)
This register is used to store part 2 of the response bits from the card.
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
CMDRSP2[31:0]
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_CMD_RSP2 field descriptions
Field
Description
CMDRSP2[31:0]
Command Response 2
Refer to Command Response3 (uSDHC_CMD_RSP3) for the mapping of command responses from the
SD Bus to this register for each response type.
58.8.8
Command Response3 (uSDHCx_CMD_RSP3)
This register is used to store part 3 of the response bits from the card.
The table below describes the mapping of command responses from the SD Bus to
Command Response registers for each response type. In the table, R[ ] refers to a bit
range within the response data as transmitted on the SD Bus.
Table 58-7. Response Bit Definition for Each Response Type
Response Type
Meaning of Response
Response Field
Response Register
R1,R1b (normal response)
Card Status
R[39:8]
CMDRSP0
R1b (Auto CMD12 response)
Card Status for Auto CMD12
R[39:8]
CMDRSP3
R2 (CID, CSD register)
CID/CSD register [127:8]
R[127:8]
{CMDRSP3[23:0],
CMDRSP2,
CMDRSP1,
CMDRSP0}
R3 (OCR register)
OCR register for memory
R[39:8]
CMDRSP0
R4 (OCR register)
OCR register for I/O etc.
R[39:8]
CMDRSP0
R5, R5b
SDIO response
R[39:8]
CMDRSP0
R6 (Publish RCA)
New Published RCA[31:16]
and card status[15:0]
R[39:9]
CMDRSP0
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4022
NXP Semiconductors

<!-- page 4023 -->

This table shows that most responses with a length of 48 (R[47:0]) have 32-bits of the
response data (R[39:8]) stored in the CMDRSP0 register. Responses of type R1b (Auto
CMD12 responses) have response data bits (R[39:8]) stored in the CMDRSP3 register.
Responses with length 136 (R[135:0]) have 120-bits of the response data (R[127:8])
stored in the CMDRSP0, 1, 2, and 3 registers.
To be able to read the response status efficiently, the uSDHC only stores part of the
response data in the Command Response registers. This enables the Host Driver to
efficiently read 32-bits of response data in one read cycle on a 32-bit bus system. Parts of
the response, the Index field and the CRC, are checked by the uSDHC (as specified by
the Command Index Check Enable and the Command CRC Check Enable bits in the
Transfer Type register) and generate an error interrupt if any error is detected. The bit
range for the CRC check depends on the response length. If the response length is 48, the
uSDHC will check R[47:1], and if the response length is 136 the uSDHC will check
R[119:1].
Since the uSDHC may have a multiple block data transfer executing concurrently with a
CMD_wo_DAT command, the uSDHC stores the Auto CMD12 response in the
CMDRSP3 register. The CMD_wo_DAT response is stored in CMDRSP0. This allows
the uSDHC to avoid overwriting the Auto CMD12 response with the CMD_wo_DAT
and vice versa. When the uSDHC modifies part of the Command Response registers, as
shown in the table above, it preserves the unmodified bits.
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
CMDRSP3[31:0]
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_CMD_RSP3 field descriptions
Field
Description
CMDRSP3[31:0]
Command Response 3
Refer to Command Response3 (uSDHC_CMD_RSP3) for the mapping of command responses from the
SD Bus to this register for each response type.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4023

<!-- page 4024 -->

58.8.9
Data Buffer Access Port
(uSDHCx_DATA_BUFF_ACC_PORT)
This is a 32-bit data port register used to access the internal buffer.
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
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
DATCONT[31:0]
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_DATA_BUFF_ACC_PORT field descriptions
Field
Description
DATCONT[31:0]
Data Content
The Buffer Data Port register is for 32-bit data access by the Arm platform or the external DMA. When
the internal DMA is enabled, any write to this register is ignored, and any read from this register will
always yield 0s.
58.8.10
Present State (uSDHCx_PRES_STATE)
The Host Driver can get status of the uSDHC from this 32-bit read only register.
• The Host Driver can issue CMD0, CMD12, CMD13 (for memory) and CMD52 (for
SDIO) when the DATA lines are busy during a data transfer. These commands can
be issued when Command Inhibit (CMD) is set to zero. Other commands shall be
issued when Command Inhibit (DATA) is set to zero. Possible changes to the SD
Physical Specification may add other commands to this list in the future.
• Note: the reset value of Present State Register depend on testbench connectivity.
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4024
NXP Semiconductors

<!-- page 4025 -->

Address: Base address + 24h offset
Bit
31
30
29
28
27
26
25
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
DLSL[7:0]
CLSL
0
WPSPL
CDPL
0
CINST
W
Reset
0
0
0
0
0
0
0
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
TSCD
0
RTR
BREN
BWEN
RTA
WTA
SDOFF
PEROFF
HCKOFF
IPGOFF
SDSTB
DLA
CDIHB
CIHB
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
1
0
0
0
0
0
0
0
uSDHCx_PRES_STATE field descriptions
Field
Description
31–24
DLSL[7:0]
DATA[7:0] Line Signal Level
This status is used to check the DATA line level to recover from errors, and for debugging.This is
especially useful in detecting the busy signal level from DATA0. The reset value is affected by the external
pull-up / pull-down resistors. By default, the read value of this bit field after reset is 8'b11110111, when
DATA3 is pulled down and the other lines are pulled up.
DATA7
Data 7 line signal level
DATA6
Data 6 line signal level
DATA5
Data 5 line signal level
DATA4
Data 4 line signal level
DATA3
Data 3 line signal level
DATA2
Data 2 line signal level
DATA1
Data 1 line signal level
DATA0
Data 0 line signal level
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4025

<!-- page 4026 -->

uSDHCx_PRES_STATE field descriptions (continued)
Field
Description
23
CLSL
CMD Line Signal Level
This status is used to check the CMD line level to recover from errors, and for debugging. The reset value
is affected by the external pull-up / pull-down resistor, by default, the read value of this bit after reset is
1'b1, when the command line is pulled up.
22–20
Reserved
This read-only field is reserved and always has the value 0.
19
WPSPL
Write Protect Switch Pin Level
The Write Protect Switch is supported for memory and combo cards.This bit reflects the inverted value of
the WP pin of the card socket. A software reset does not affect this bit. The reset value is effected by the
external write protect switch. If the WP pin is not used, it should be tied low, so that the reset value of this
bit is high and write is enabled.
1
Write enabled (WP = 0)
0
Write protected (WP = 1)
18
CDPL
Card Detect Pin Level
This bit reflects the inverse value of the CD_B pin for the card socket. Debouncing is not performed on this
bit. This bit may be valid, but is not guaranteed, because of propagation delay. Use of this bit is limited to
testing since it must be debounced by software. A software reset does not effect this bit. A write to the
Force Event Register does not effect this bit. The reset value is effected by the external card detection pin.
This bit shows the value on the CD_B pin (i.e. when a card is inserted in the socket, it is 0 on the CD_B
input, and consequently the CDPL reads 1.)
1
Card present (CD_B = 0)
0
No card present (CD_B = 1)
17
Reserved
This read-only field is reserved and always has the value 0.
16
CINST
Card Inserted
This bit indicates whether a card has been inserted. The uSDHC debounces this signal so that the Host
Driver will not need to wait for it to stabilize. Changing from a 0 to 1 generates a Card Insertion interrupt in
the Interrupt Status register. Changing from a 1 to 0 generates a Card Removal interrupt in the Interrupt
Status register. A write to the Force Event Register does not effect this bit.
The Software Reset For All in the System Control register does not effect this bit. A software reset does
not effect this bit.
1
Card Inserted
0
Power on Reset or No Card
15
TSCD
Tape Select Change Done
This bit indicates the dealy setting is effective after write CLK_TUNE_CTRL_STATUS register.
1
Delay cell select change is finished.
0
Delay cell select change is not finished.
14–13
Reserved
This read-only field is reserved and always has the value 0.
12
RTR
Re-Tuning Request (only for SD3.0 SDR104 mode)
Host Controller may request Host Driver to execute re-tuning sequence by setting this bit when the data
window is shifted by temperature drift and a tuned sampling point does not have a good margin to receive
correct data.
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4026
NXP Semiconductors

<!-- page 4027 -->

uSDHCx_PRES_STATE field descriptions (continued)
Field
Description
This bit is cleared when a command is issued with setting Execute Tuning bit in MIXER_CTRL register.
Changing of this bit from 0 to 1 generates Re-Tuning Event. Refer to Interrupt status registers for more
detail.
This bit isn't set to 1 if Sampling Clock Select in the MIXER_CTRL register is set to 0 (using fixed sampling
clock).
1
Sampling clock needs re-tuning
0
Fixed or well tuned sampling clock
11
BREN
Buffer Read Enable
This status bit is used for non-DMA read transfers. The uSDHC implements an internal buffer to transfer
data efficiently. This read only flag indicates that valid data exists in the host side buffer. If this bit is high,
valid data greater than the watermark level exist in the buffer. A change of this bit from 1 to 0 occurs when
some reads from the buffer(read DATPORT (Base + 0x20)) are made and the buffer hasn't valid data
greater than the watermark level. A change of this bit from 0 to1 occurs when there is enough valid data
ready in the buffer and the Buffer Read Ready interrupt has been generated and enabled.
1
Read enable
0
Read disable
10
BWEN
Buffer Write Enable
This status bit is used for non-DMA write transfers. The uSDHC implements an internal buffer to transfer
data efficiently. This read only flag indicates if space is available for write data. If this bit is 1, valid data
greater than the watermark level can be written to the buffer. A change of this bit from 1 to 0 occurs when
some writes to the buffer(write DATPORT(Base + 0x20)) are made and the buffer hasn't valid space
greater than the watermark level. A change of this bit from 0 to 1 occurs when the buffer can hold valid
data greater than the write watermark level and the Buffer Write Ready interrupt is generated and enabled.
1
Write enable
0
Write disable
9
RTA
Read Transfer Active
This status bit is used for detecting completion of a read transfer.
This bit is set for either of the following conditions:
• After the end bit of the read command.
• When writing a 1 to the Continue Request bit in the Protocol Control register to restart a read
transfer.
A Transfer Complete interrupt is generated when this bit changes to 0. This bit is cleared for either of the
following conditions:
• When the last data block as specified by block length is transferred to the System, i.e. all data are
read away from uSDHC internal buffer.
• When all valid data blocks have been transferred from uSDHC internal buffer to the System and no
current block transfers are being sent as a result of the Stop At Block Gap Request being set to 1.
1
Transferring data
0
No valid data
8
WTA
Write Transfer Active
This status bit indicates a write transfer is active. If this bit is 0, it means no valid write data exists in the
uSDHC.
This bit is set in either of the following cases:
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4027

<!-- page 4028 -->

uSDHCx_PRES_STATE field descriptions (continued)
Field
Description
• After the end bit of the write command.
• When writing 1 to the Continue Request bit in the Protocol Control register to restart a write transfer.
This bit is cleared in either of the following cases:
• After getting the CRC status of the last data block as specified by the transfer count (Single and
Multiple).
• After getting the CRC status of any block where data transmission is about to be stopped by a Stop
At Block Gap Request.
During a write transaction, a Block Gap Event interrupt is generated when this bit is changed to 0, as
result of the Stop At Block Gap Request being set. This status is useful for the Host Driver in determining
when to issue commands during Write Busy state.
1
Transferring data
0
No valid data
7
SDOFF
SD Clock Gated Off Internally
This status bit indicates that the SD Clock is internally gated off, because of buffer over / under-run or read
pause without read wait assertion, or the driver set FRC_SDCLK_ON bit is 0 to stop the SD clock in idle
status. Set IPG_PERCLK_SOFT_EN and CARD_CLK_SOFT_EN to 0 also gate off SD clock. This bit is
for the Host Driver to debug data transaction on the SD bus.
1
SD Clock is gated off.
0
SD Clock is active.
6
PEROFF
IPG_PERCLK Gated Off Internally
This status bit indicates that the IPG_PERCLK is internally gated off. This bit is for the Host Driver to
debug transaction on the SD bus. When IPG_CLK_SOFT_EN is cleared, IPG_PERCLK will be gated off,
otherwise IPG_PERCLK will be always active.
1
IPG_PERCLK is gated off.
0
IPG_PERCLK is active.
5
HCKOFF
HCLK Gated Off Internally
This status bit indicates that the HCLK is internally gated off. This bit is for the Host Driver to debug during
a data transfer.
1
HCLK is gated off.
0
HCLK is active.
4
IPGOFF
IPG_CLK Gated Off Internally
This status bit indicates that the ipg_clk is internally gated off. This bit is for the Host Driver to debug.
1
IPG_CLK is gated off.
0
IPG_CLK is active.
3
SDSTB
SD Clock Stable
This status bit indicates that the internal card clock is stable. This bit is for the Host Driver to poll clock
status when changing the clock frequency. It is recommended to clear FRC_SDCLK_ON bit in System
Control register to remove glitches on the card clock when the frequency is changing.
Before changing clock divisor value(SDCLKFS or DVS), Host Driver should make sure the SDSTB bit is
high.
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4028
NXP Semiconductors

<!-- page 4029 -->

uSDHCx_PRES_STATE field descriptions (continued)
Field
Description
1
Clock is stable.
0
Clock is changing frequency and not stable.
2
DLA
Data Line Active
This status bit indicates whether one of the DATA lines on the SD Bus is in use.
In the case of read transactions:
This status indicates if a read transfer is executing on the SD Bus. Changes in this value from 1 to 0,
between data blocks, generates a Block Gap Event interrupt in the Interrupt Status register.
This bit will be set in either of the following cases:
• After the end bit of the read command.
• When writing a 1 to the Continue Request bit in the Protocol Control register to restart a read
transfer.
This bit will be cleared in either of the following cases:
(1) When the end bit of the last data block is sent from the SD Bus to the uSDHC.
(2) When the Read Wait state is stopped by a Suspend command and the DATA2 line is released.
The uSDHC will wait at the next block gap by driving Read Wait at the start of the interrupt cycle. If the
Read Wait signal is already driven (data buffer cannot receive data), the uSDHC can wait for a current
block gap by continuing to drive the Read Wait signal. It is necessary to support Read Wait in order to use
the suspend / resume function. This bit will remain 1 during Read Wait.
In the case of write transactions:
This status indicates that a write transfer is executing on the SD Bus. Changes in this value from 1 to 0
generate a Transfer Complete interrupt in the Interrupt Status register.
This bit will be set in either of the following cases:
• After the end bit of the write command.
• When writing to 1 to the Continue Request bit in the Protocol Control register to continue a write
transfer.
This bit will be cleared in either of the following cases:
• When the SD card releases Write Busy of the last data block, the uSDHC will also detect if the
output is not busy. If the SD card does not drive the busy signal after the CRC status is received, the
uSDHC shall assume the card drive "Not Busy".
• When the SD card releases write busy, prior to waiting for write transfer, and as a result of a Stop At
Block Gap Request.
In the case of command with busy pending:
This status indicates that a busy state follows the command and the data line is in use. This bit will be
cleared when the DATA0 line is released.
1
DATA Line Active
0
DATA Line Inactive
1
CDIHB
Command Inhibit (DATA)
This status bit is generated if either the DAT Line Active or the Read Transfer Active is set to 1. If this bit is
0, it indicates that the uSDHC can issue the next SD / MMC Command. Commands with a busy signal
belong to Command Inhibit (DATA) (for example. R1b, R5b type). Changing from 1 to 0 generates a
Transfer Complete interrupt in the Interrupt Status register.
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4029

<!-- page 4030 -->

uSDHCx_PRES_STATE field descriptions (continued)
Field
Description
NOTE: The SD Host Driver can save registers for a suspend transaction after this bit has changed from 1
to 0.
1
Cannot issue command which uses the DATA line
0
Can issue command which uses the DATA line
0
CIHB
Command Inhibit (CMD)
If this status bit is 0, it indicates that the CMD line is not in use and the uSDHC can issue a SD / MMC
Command using the CMD line.
This bit is set also immediately after the Transfer Type register is written. This bit is cleared when the
command response is received. Even if the Command Inhibit (DATA) is set to 1, Commands using only
the CMD line can be issued if this bit is 0. Changing from 1 to 0 generates a Command Complete interrupt
in the Interrupt Status register. If the uSDHC cannot issue the command because of a command conflict
error (Refer to Command CRC Error) or because of a Command Not Issued By Auto CMD12 Error, this bit
will remain 1 and the Command Complete is not set. The Status of issuing an Auto CMD12 does not show
on this bit.
1
Cannot issue command
0
Can issue command using only CMD line
58.8.11
Protocol Control (uSDHCx_PROT_CTRL)
There are three cases to restart the transfer after stop at the block gap. Which case is
appropriate depends on whether the uSDHC issues a Suspend command or the SD card
accepts the Suspend command.
1. If the Host Driver does not issue a Suspend command, the Continue Request shall be
used to restart the transfer.
2. If the Host Driver issues a Suspend command and the SD card accepts it, a Resume
command shall be used to restart the transfer.
3. If the Host Driver issues a Suspend command and the SD card does not accept it, the
Continue Request shall be used to restart the transfer.
Any time Stop At Block Gap Request stops the data transfer, the Host Driver shall wait
for a Transfer Complete (in the Interrupt Status register), before attempting to restart the
transfer. When restarting the data transfer by Continue Request, the Host Driver shall
clear the Stop At Block Gap Request before or simultaneously.
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4030
NXP Semiconductors

<!-- page 4031 -->

Address: Base address + 28h offset
Bit
31
30
29
28
27
26
25
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
NON_EXACT_
BLK_RD
BURST_LEN_EN
WECRM
WECINS
WECINT
-
RD_DONE_NO_
8CLK
IABG
RWCTL
CREQ
SABGREQ
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
0
DMASEL
CDSS
CDTL
EMODE
D3CD
DTW[1:0]
LCTL
W
Reset
0
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
uSDHCx_PROT_CTRL field descriptions
Field
Description
31
-
Reserved. Always write as 0
30
NON_EXACT_
BLK_RD
Current block read is non-exact block read. It is only used for SDIO.
1
The block read is non-exact block read. Host driver needs to issue abort command to terminate this
multi-block read.
0
The block read is exact block read. Host driver doesn't need to issue abort command to terminate this
multi-block read.
29–27
BURST_LEN_EN
BURST length enable for INCR, INCR4 / INCR8 / INCR16, INCR4-WRAP / INCR8-WRAP / INCR16-
WRAP
This is used to enable / disable the burst length for the external AHB2AXI bridge. It is useful especially for
INCR transfer because without burst length indicator, the AHB2AXI bridge does not know the burst length
in advance. Without burst length indicator, AHB INCR transfers can only be converted to SINGLEs on the
AXI side.
xx1
Burst length is enabled for INCR
x1x
Burst length is enabled for INCR4 / INCR8 / INCR16
1xx
Burst length is enabled for INCR4-WRAP / INCR8-WRAP / INCR16-WRAP
26
WECRM
Wakeup Event Enable On SD Card Removal
This bit enables a wakeup event, via a Card Removal, in the Interrupt Status register. FN_WUS (Wake Up
Support) in CIS does not effect this bit. When this bit is set, the Card Removal Status and the uSDHC
interrupt can be asserted without CLK toggling. When the wakeup feature is not enabled, the CLK must be
active in order to assert the Card Removal Status and the uSDHC interrupt.
1
Enable
0
Disable
25
WECINS
Wakeup Event Enable On SD Card Insertion
This bit enables a wakeup event, via a Card Insertion, in the Interrupt Status register. FN_WUS (Wake Up
Support) in CIS does not effect this bit. When this bit is set, the Card Insertion Status and the uSDHC
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4031

<!-- page 4032 -->

uSDHCx_PROT_CTRL field descriptions (continued)
Field
Description
interrupt can be asserted without CLK toggling. When the wakeup feature is not enabled, the CLK must be
active in order to assert the Card Insertion Status and the uSDHC interrupt.
1
Enable
0
Disable
24
WECINT
Wakeup Event Enable On Card Interrupt
This bit enables a wakeup event, via a Card Interrupt, in the Interrupt Status register. This bit can be set to
1 if FN_WUS (Wake Up Support) in CIS is set to 1. When this bit is set, the Card Interrupt Status and the
uSDHC interrupt can be asserted without CLK toggling. When the wakeup feature is not enabled, the CLK
must be active in order to assert the Card Interrupt Status and the uSDHC interrupt.
1
Enable
0
Disable
23–21
-
Reserved. Always write as 3'b100
20
RD_DONE_NO_
8CLK
Read done no 8 clock:
According to the SD/MMC spec, for read data transaction, 8 clocks are needed after the end bit of the
last data block. So, by default(RD_DONE_NO_8CLK=0), 8 clocks will be active after the end bit of the
last read data transaction.
However, this 8 clocks should not be active if user wants to use stop at block gap(include the auto stop
at block gap in boot mode) feature for read and the RWCTL bit(bit18) is not enabled. In this case,
software should set RD_DONE_NO_8CLK to avoid this 8 clocks. Otherwise, the device may send extra
data to uSDHC while uSDHC ignores these data.
In a summary, this bit should be set only if the use case needs to use stop at block gap feature while the
device can't support the read wait feature.
19
IABG
Interrupt At Block Gap
This bit is valid only in 4-bit mode, of the SDIO card, and selects a sample point in the interrupt cycle.
Setting to 1 enables interrupt detection at the block gap for a multiple block transfer. Setting to 0 disables
interrupt detection during a multiple block transfer. If the SDIO card cannot signal an interrupt during a
multiple block transfer, this bit should be set to 0 to avoid an inadvertent interrupt. When the Host Driver
detects an SDIO card insertion, it shall set this bit according to the CCCR of the card.
1
Enabled
0
Disabled
18
RWCTL
Read Wait Control
The read wait function is optional for SDIO cards. If the card supports read wait, set this bit to enable use
of the read wait protocol to stop read data using the DATA2 line. Otherwise the uSDHC has to stop the SD
Clock to hold read data, which restricts commands generation. When the Host Driver detects an SDIO
card insertion, it shall set this bit according to the CCCR of the card. If the card does not support read
wait, this bit shall never be set to 1, otherwise DATA line conflicts may occur. If this bit is set to 0, stop at
block gap during read operation is also supported, but the uSDHC will stop the SD Clock to pause reading
operation.
1
Enable Read Wait Control, and assert Read Wait without stopping SD Clock at block gap when
SABGREQ bit is set
0
Disable Read Wait Control, and stop SD Clock at block gap when SABGREQ bit is set
17
CREQ
Continue Request
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4032
NXP Semiconductors

<!-- page 4033 -->

uSDHCx_PROT_CTRL field descriptions (continued)
Field
Description
This bit is used to restart a transaction which was stopped using the Stop At Block Gap Request. When a
Suspend operation is not accepted by the card, it is also by setting this bit to restart the paused transfer.
To cancel stop at the block gap, set Stop At Block Gap Request to 0 and set this bit to 1 to restart the
transfer.
The uSDHC automatically clears this bit, therefore it is not necessary for the Host Driver to set this bit to 0.
If both Stop At Block Gap Request and this bit are 1, the continue request is ignored.
1
Restart
0
No effect
16
SABGREQ
Stop At Block Gap Request
This bit is used to stop executing a transaction at the next block gap for both DMA and non-DMA
transfers. Until the Transfer Complete is set to 1, indicating a transfer completion, the Host Driver shall
leave this bit set to 1. Clearing both the Stop At Block Gap Request and Continue Request does not cause
the transaction to restart. Read Wait is used to stop the read transaction at the block gap. The uSDHC will
honor the Stop At Block Gap Request for write transfers, but for read transfers it requires that the SDIO
card support Read Wait. Therefore, the Host Driver shall not set this bit during read transfers unless the
SDIO card supports Read Wait and has set the Read Wait Control to 1, otherwise the uSDHC will stop the
SD bus clock to pause the read operation during block gap. In the case of write transfers in which the Host
Driver writes data to the Data Port register, the Host Driver shall set this bit after all block data is written. If
this bit is set to 1, the Host Driver shall not write data to the Data Port register after a block is sent. Once
this bit is set, the Host Driver shall not clear this bit before the Transfer Complete bit in Interrupt Status
Register is set, otherwise the uSDHCs behavior is undefined.
This bit effects Read Transfer Active, Write Transfer Active, DATA Line Active and Command Inhibit
(DATA) in the Present State register.
1
Stop
0
Transfer
15–10
Reserved
This read-only field is reserved and always has the value 0.
9–8
DMASEL
DMA Select
This field is valid while DMA (SDMA or ADMA) is enabled and selects the DMA operation.
00
No DMA or Simple DMA is selected
01
ADMA1 is selected
10
ADMA2 is selected
11
reserved
7
CDSS
Card Detect Signal Selection
This bit selects the source for the card detection.
1
Card Detection Test Level is selected (for test purpose).
0
Card Detection Level is selected (for normal purpose).
6
CDTL
Card Detect Test Level
This is bit is enabled while the Card Detection Signal Selection is set to 1 and it indicates card insertion.
1
Card Detect Test Level is 1, card inserted
0
Card Detect Test Level is 0, no card inserted
5–4
EMODE
Endian Mode
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4033

<!-- page 4034 -->

uSDHCx_PROT_CTRL field descriptions (continued)
Field
Description
The uSDHC supports all three endian modes in data transfer. Refer to Data Buffer for more details.
00
Big Endian Mode
01
Half Word Big Endian Mode
10
Little Endian Mode
11
Reserved
3
D3CD
DATA3 as Card Detection Pin
If this bit is set, DATA3 should be pulled down to act as a card detection pin. Be cautious when using this
feature, because DATA3 is also a chip-select for the SPI mode. A pull-down on this pin and CMD0 may
set the card into the SPI mode, which the uSDHC does not support.
1
DATA3 as Card Detection Pin
0
DATA3 does not monitor Card Insertion
2–1
DTW[1:0]
Data Transfer Width
This bit selects the data width of the SD bus for a data transfer. The Host Driver shall set it to match the
data width of the card. Possible Data transfer Width is 1-bit, 4-bits or 8-bits.
10
8-bit mode
01
4-bit mode
00
1-bit mode
11
Reserved
0
LCTL
LED Control
This bit, fully controlled by the Host Driver, is used to caution the user not to remove the card while the
card is being accessed. If the software is going to issue multiple SD commands, this bit can be set during
all these transactions. It is not necessary to change for each transaction. When the software issues
multiple SD commands, setting the bit once before the first command is sufficient: it is not necessary to
reset the bit between commands.
1
LED on
0
LED off
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4034
NXP Semiconductors

<!-- page 4035 -->

58.8.12
System Control (uSDHCx_SYS_CTRL)
Address: Base address + 2Ch offset
Bit
31
30
29
28
27
26
25
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
RSTT
INITA
RSTD RSTC RSTA
IPP_
RST_
N
-
0
DTOCV
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
SDCLKFS
DVS[3:0]
-
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
1
1
1
1
uSDHCx_SYS_CTRL field descriptions
Field
Description
31–29
Reserved
This read-only field is reserved and always has the value 0.
28
RSTT
Reset Tuning
When set this bit to 1, it will reset tuning circuit. After tuning circuits are reset, bit value is 0. Clearing
execute_tuning bit in AUTOCMD12_ERR_STATUS will also set this bit to 1 to reset tuning circuit
27
INITA
Initialization Active
When this bit is set, 80 SD-Clocks are sent to the card. After the 80 clocks are sent, this bit is self cleared.
This bit is very useful during the card power-up period when 74 SD-Clocks are needed and the clock auto
gating feature is enabled. Writing 1 to this bit when this bit is already 1 has no effect. Writing 0 to this bit at
any time has no effect. When either of the CIHB and CDIHB bits in the Present State Register are set,
writing 1 to this bit is ignored (i.e. when command line or data lines are active, write to this bit is not
allowed). On the otherhand, when this bit is set, i.e., during intialization active period, it is allowed to issue
command, and the command bit stream will appear on the CMD pad after all 80 clock cycles are done. So
when this command ends, the driver can make sure the 80 clock cycles are sent out. This is very useful
when the driver needs send 80 cycles to the card and does not want to wait till this bit is self cleared.
26
RSTD
Software Reset For DATA Line
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4035

<!-- page 4036 -->

uSDHCx_SYS_CTRL field descriptions (continued)
Field
Description
Only part of the data circuit is reset. DMA circuit is also reset. After this bit is set, SW waits for self-clear.
The following registers and bits are cleared by this bit:
• Data Port register
• Buffer is cleared and initialized.
• Present State register
• Buffer Read Enable
• Buffer Write Enable
• Read Transfer Active
• Write Transfer Active
• DATA Line Active
• Command Inhibit (DATA) Protocol Control register
• Continue Request
• Stop At Block Gap Request Interrupt Status register
• Buffer Read Ready
• Buffer Write Ready
• DMA Interrupt
• Block Gap Event
• Transfer Complete
NOTE: When reset, SW must make sure there is no incomplete data transferring. If there is data transfer
going on, SW need wait TC or DC uSDHC_INT_STATUS register is set.
1
Reset
0
No Reset
25
RSTC
Software Reset For CMD Line
Only part of the command circuit is reset. After this bit is set, SW waits for self-clear.
The following registers and bits are cleared by this bit:
• Present State register Command Inhibit (CMD)
• Interrupt Status register Command Complete
1
Reset
0
No Reset
24
RSTA
Software Reset For ALL
This reset effects the entire Host Controller except for the card detection circuit. Register bits of type ROC,
RW, RW1C, RWAC are cleared. During its initialization, the Host Driver shall set this bit to 1 to reset the
uSDHC. The uSDHC shall reset this bit to 0 when the capabilities registers are valid and the Host Driver
can read them. Additional use of Software Reset For All does not affect the value of the Capabilities
registers. After this bit is set, it is recommended that the Host Driver reset the external card and re-
initialize it. After this bit is set, SW should wait for self-clear.
In tuning process, after every CMD19 is finished, this bit will be set to retest the uSDHC.
NOTE: When reset, SW must make sure there is no incomplete data transferring. If there is data transfer
going on, SW need wait TC or DC uSDHC_INT_STATUS register is set.
1
Reset
0
No Reset
23
IPP_RST_N
This register's value will be output to CARD from pad directly for hardware reset of the card if the card
supports this feature.
22
-
Reserved
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4036
NXP Semiconductors

<!-- page 4037 -->

uSDHCx_SYS_CTRL field descriptions (continued)
Field
Description
21–20
Reserved
This read-only field is reserved and always has the value 0.
19–16
DTOCV
Data Timeout Counter Value
This value determines the interval by which DAT line timeouts are detected. Refer to the Data Timeout
Error bit in the Interrupt Status register for information on factors that dictate time-out generation. Time-out
clock frequency will be generated by dividing the base clock SDCLK value by this value.
The Host Driver can clear the Data Timeout Error Status Enable (in the Interrupt Status Enable register) to
prevent inadvertent time-out events.
1111b
SDCLK x 2 29
1110b
SDCLK x 2 28
...
0001b
SDCLK x 2 15
0000b
SDCLK x 2 14
15–8
SDCLKFS
SDCLK Frequency Select
This register is used to select the frequency of the SDCLK pin.This register field selects the divide value of
the second divisor stage.
In Single Data Rate mode(DDR_EN bit of MIXERCTRL is '0')
Only the following settings are allowed:
80h) Base clock divided by 256
40h) Base clock divided by 128
20h) Base clock divided by 64
10h) Base clock divided by 32
08h) Base clock divided by 16
04h) Base clock divided by 8
02h) Base clock divided by 4
01h) Base clock divided by 2
00h) Base clock divided by 1
While in Dual Data Rate mode(DDR_EN bit of MIXERCTRL is '1')
Only the following settings are allowed:
80h) Base clock divided by 512
40h) Base clock divided by 256
20h) Base clock divided by 128
10h) Base clock divided by 64
08h) Base clock divided by 32
04h) Base clock divided by 16
02h) Base clock divided by 8
01h) Base clock divided by 4
00h) Base clock divided by 2
When S/W changes the DDR_EN bit, SDCLKFS may need to be changed also!
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4037

<!-- page 4038 -->

uSDHCx_SYS_CTRL field descriptions (continued)
Field
Description
In Single Data Rate mode, setting 00h bypasses the frequency prescaler of the SD Clock.
Multiple bits must not be set, or the behavior of this prescaler is undefined. The two default divider values
can be calculated by the frequency of ipg_perclk and the following Divisor bits.
The frequency of SDCLK is set by the following formula:
Clock Frequency = (Base Clock) / (prescaler x divisor)
For example, in Single Data Rate mode, if the Base Clock Frequency is 96 MHz, and the target frequency
is 25 MHz, then choosing the prescaler value of 01h and divisor value of 1h will yield 24 MHz, which is the
nearest frequency less than or equal to the target. Similarly, to approach a clock value of 400 kHz, the
prescaler value of 08h and divisor value of eh yields the exact clock value of 400 kHz.
The reset value of this bit field is 80h, so if the input Base Clock (ipg_perclk) is about 96 MHz, the default
SD Clock after reset is 375 kHz.
According to the SD Physical Specification Version 1.1 and the SDIO Card Specification Version 1.2, the
maximum SD Clock frequency is 50 MHz and shall never exceed this limit.
Before changing clock divisor value(SDCLKFS or DVS), Host Driver should make sure the SDSTB bit is
high.
If setting SDCLKFS and DVS can generate same clock frequency,(For example, in SDR mode,
SDCLKFS = 01h is same as DVS = 01h.) SDCLKFS is highly recommended.
7–4
DVS[3:0]
Divisor
This register is used to select the frequency of the SDCLK pin. This register field selects the divide value
of the first divisor stage.
Before changing clock divisor value(SDCLKFS or DVS), Host Driver should make sure the SDSTB bit is
high.
The setting are as following:
0000
Divide-by-1
0001
Divide-by-2
.......
1110
Divide-by-15
1111
Divide-by-16
-
Reserved. Always write as 1.
58.8.13
Interrupt Status (uSDHCx_INT_STATUS)
An interrupt is generated when the Normal Interrupt Signal Enable is enabled and at least
one of the status bits is set to 1. For all bits, writing 1 to a bit clears it; writing to 0 keeps
the bit unchanged. More than one status can be cleared with a single register write. For
Card Interrupt, before writing 1 to clear, it is required that the card stops asserting the
interrupt, meaning that when the Card Driver services the interrupt condition, otherwise
the CINT bit will be asserted again.
The table below shows the relationship between the Command Timeout Error and the
Command Complete.
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4038
NXP Semiconductors

<!-- page 4039 -->

Table 58-8. uSDHC Status for Command Timeout Error/Command Complete Bit
Combinations
Command Complete
Command Timeout Error
Meaning of the Status
0
0
X
X
1
Response not received within 64 SDCLK cycles
1
0
Response received
The table below shows the relationship between the Transfer Complete and the Data
Timeout Error.
Table 58-9. uSDHC Status for Data Timeout Error/Transfer Complete Bit Combinations
Transfer Complete
Data Timeout Error
Meaning of the Status
0
0
X
0
1
Timeout occurred during transfer
1
X
Data Transfer Complete
The table below shows the relationship between the Command CRC Error and Command
Timeout Error.
Table 58-10. uSDHC Status for Command CRC Error/Command Timeout Error Bit
Combinations
Command Complete
Command Timeout Error
Meaning of the Status
0
0
No error
0
1
Response Timeout Error
1
0
Response CRC Error
1
1
CMD line conflict
Address: Base address + 30h offset
Bit
31
30
29
28
27
26
25
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
DMAE
0
TNE
0
AC12E
0
DEBE
DCE
DTOE
CIE
CEBE
CCE
CTOE
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
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4039

<!-- page 4040 -->

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
TP
0
RTE
0
CINT
CRM
CINS
BRR
BWR
DINT
BGE
TC
CC
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
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_INT_STATUS field descriptions
Field
Description
31–29
Reserved
This read-only field is reserved and always has the value 0.
28
DMAE
DMA Error
Occurs when an Internal DMA transfer has failed. This bit is set to 1, when some error occurs in the data
transfer. This error can be caused by either Simple DMA or ADMA, depending on which DMA is in use.
The value in DMA System Address register is the next fetch address where the error occurs. Since any
error corrupts the whole data block, the Host Driver shall re-start the transfer from the corrupted block
boundary. The address of the block boundary can be calculated either from the current DS_ADDR value
or from the remaining number of blocks and the block size.
1
Error
0
No Error
27
Reserved
This read-only field is reserved and always has the value 0.
26
TNE
Tuning Error: (only for SD3.0 SDR104 mode)
This bit is set when an unrecoverable error is detected in a tuning circuit. By detecting Tuning Error, Host
Driver needs to abort a command executing and perform tuning.
25
Reserved
This read-only field is reserved and always has the value 0.
24
AC12E
Auto CMD12 Error
Occurs when detecting that one of the bits in the Auto CMD12 Error Status register has changed from 0 to
1. This bit is set to 1, not only when the errors in Auto CMD12 occur, but also when the Auto CMD12 is not
executed due to the previous command error.
1
Error
0
No Error
23
Reserved
This read-only field is reserved and always has the value 0.
22
DEBE
Data End Bit Error
Occurs either when detecting 0 at the end bit position of read data, which uses the DATA line, or at the
end bit position of the CRC.
This bit will be not asserted in tuning process.
1
Error
0
No Error
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4040
NXP Semiconductors

<!-- page 4041 -->

uSDHCx_INT_STATUS field descriptions (continued)
Field
Description
21
DCE
Data CRC Error
Occurs when detecting a CRC error when transferring read data, which uses the DATA line, or when
detecting the Write CRC status having a value other than 010.
This bit will be not asserted in tuning process.
1
Error
0
No Error
20
DTOE
Data Timeout Error
Occurs when detecting one of following time-out conditions.
• Busy time-out for R1b, R5b type
• Busy time-out after Write CRC status
• Read Data time-out.
This bit will be not asserted in tuning process.
1
Time out
0
No Error
19
CIE
Command Index Error
Occurs if a Command Index error occurs in the command response.
This bit will be not asserted in tuning process.
1
Error
0
No Error
18
CEBE
Command End Bit Error
Occurs when detecting that the end bit of a command response is 0.
This bit will be not asserted in tuning process.
1
End Bit Error Generated
0
No Error
17
CCE
Command CRC Error
Command CRC Error is generated in two cases.
• If a response is returned and the Command Timeout Error is set to 0 (indicating no time-out), this bit
is set when detecting a CRC error in the command response.
• The uSDHC detects a CMD line conflict by monitoring the CMD line when a command is issued. If
the uSDHC drives the CMD line to 1, but detects 0 on the CMD line at the next SDCLK edge, then
the uSDHC shall abort the command (Stop driving CMD line) and set this bit to 1. The Command
Timeout Error shall also be set to 1 to distinguish CMD line conflict.
This bit will be not asserted in tuning process.
1
CRC Error Generated.
0
No Error
16
CTOE
Command Timeout Error
Occurs only if no response is returned within 64 SDCLK cycles from the end bit of the command. If the
uSDHC detects a CMD line conflict, in which case a Command CRC Error shall also be set (as shown in
Interrupt Status (uSDHC_INT_STATUS) ), this bit shall be set without waiting for 64 SDCLK cycles. This is
because the command will be aborted by the uSDHC.
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4041

<!-- page 4042 -->

uSDHCx_INT_STATUS field descriptions (continued)
Field
Description
This bit will be not asserted in tuning process.
1
Time out
0
No Error
15
Reserved
This read-only field is reserved and always has the value 0.
14
TP
Tuning Pass:(only for SD3.0 SDR104 mode)
Current CMD19 transfer is done successfully. That is, current sampling point is correct.
13
Reserved
This read-only field is reserved and always has the value 0.
12
RTE
Re-Tuning Event: (only for SD3.0 SDR104 mode)
This status is set if Re-Tuning Request in the Present State register changes from 0 to 1. Host Controller
requests Host Driver to perform re-tuning for next data transfer. Current data transfer (not large block
count) can be completed without re-tuning.
1
Re-Tuning should be performed
0
Re-Tuning is not required
11–9
Reserved
This read-only field is reserved and always has the value 0.
8
CINT
Card Interrupt
This status bit is set when an interrupt signal is detected from the external card. In 1-bit mode, the uSDHC
will detect the Card Interrupt without the SD Clock to support wakeup. In 4-bit mode, the card interrupt
signal is sampled during the interrupt cycle, so the interrupt from card can only be sampled during interrupt
cycle, introducing some delay between the interrupt signal from the SDIO card and the interrupt to the
Host System. Writing this bit to 1 can clear this bit, but as the interrupt source from the SDIO card does
not clear, this bit is set again. In order to clear this bit, it is required to reset the interrupt source from the
external card followed by a writing 1 to this bit.
When this status has been set, and the Host Driver needs to service this interrupt, the Card Interrupt
Signal Enable in the Interrupt Signal Enable register should be 0 to stop driving the interrupt signal to the
Host System. After completion of the card interrupt service (It should reset the interrupt sources in the
SDIO card and the interrupt signal may not be asserted), write 1 to clear this bit, set the Card Interrupt
Signal Enable to 1, and start sampling the interrupt signal again.
1
Generate Card Interrupt
0
No Card Interrupt
7
CRM
Card Removal
This status bit is set if the Card Inserted bit in the Present State register changes from 1 to 0. When the
Host Driver writes this bit to 1 to clear this status, the status of the Card Inserted in the Present State
register should be confirmed. Because the card state may possibly be changed when the Host Driver
clears this bit and the interrupt event may not be generated. When this bit is cleared, it will be set again if
no card is inserted. In order to leave it cleared, clear the Card Removal Status Enable bit in Interrupt
Status Enable register.
1
Card removed
0
Card state unstable or inserted
6
CINS
Card Insertion
This status bit is set if the Card Inserted bit in the Present State register changes from 0 to 1. When the
Host Driver writes this bit to 1 to clear this status, the status of the Card Inserted in the Present State
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4042
NXP Semiconductors

<!-- page 4043 -->

uSDHCx_INT_STATUS field descriptions (continued)
Field
Description
register should be confirmed. Because the card state may possibly be changed when the Host Driver
clears this bit and the interrupt event may not be generated. When this bit is cleared, it will be set again if a
card is inserted. In order to leave it cleared, clear the Card Inserted Status Enable bit in Interrupt Status
Enable register.
1
Card inserted
0
Card state unstable or removed
5
BRR
Buffer Read Ready
This status bit is set if the Buffer Read Enable bit, in the Present State register, changes from 0 to 1. Refer
to the Buffer Read Enable bit in the Present State register for additional information.
This bit indicates that cmd19 is finished in tuning process.
1
Ready to read buffer
0
Not ready to read buffer
4
BWR
Buffer Write Ready
This status bit is set if the Buffer Write Enable bit, in the Present State register, changes from 0 to 1. Refer
to the Buffer Write Enable bit in the Present State register for additional information.
1
Ready to write buffer:
0
Not ready to write buffer
3
DINT
DMA Interrupt
Occurs only when the internal DMA finishes the data transfer successfully. Whenever errors occur during
data transfer, this bit will not be set. Instead, the DMAE bit will be set. Either Simple DMA or ADMA
finishes data transferring, this bit will be set.
1
DMA Interrupt is generated
0
No DMA Interrupt
2
BGE
Block Gap Event
If the Stop At Block Gap Request bit in the Protocol Control register is set, this bit is set when a read or
write transaction is stopped at a block gap. If Stop At Block Gap Request is not set to 1, this bit is not set
to 1.
In the case of a Read Transaction: This bit is set at the falling edge of the DATA Line Active Status (When
the transaction is stopped at SD Bus timing). The Read Wait must be supported in order to use this
function.
In the case of Write Transaction: This bit is set at the falling edge of Write Transfer Active Status (After
getting CRC status at SD Bus timing).
1
Transaction stopped at block gap
0
No block gap event
1
TC
Transfer Complete
This bit is set when a read or write transfer is completed.
In the case of a Read Transaction: This bit is set at the falling edge of the Read Transfer Active Status.
There are two cases in which this interrupt is generated. The first is when a data transfer is completed as
specified by the data length (after the last data has been read to the Host System). The second is when
data has stopped at the block gap and completed the data transfer by setting the Stop At Block Gap
Request bit in the Protocol Control register (after valid data has been read to the Host System).
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4043

<!-- page 4044 -->

uSDHCx_INT_STATUS field descriptions (continued)
Field
Description
In the case of a Write Transaction: This bit is set at the falling edge of the DATA Line Active Status. There
are two cases in which this interrupt is generated. The first is when the last data is written to the SD card
as specified by the data length and the busy signal is released. The second is when data transfers are
stopped at the block gap, by setting the Stop At Block Gap Request bit in the Protocol Control register,
and the data transfers are completed. (after valid data is written to the SD card and the busy signal
released).
In the case of a command with busy, this bit is set when busy is deasserted.
This bit will be not asserted in tuning process.
1
Transfer complete
0
Transfer not complete
0
CC
Command Complete
This bit is set when you receive the end bit of the command response (except Auto CMD12). Refer to the
Command Inhibit (CMD) in the Present State register.
This bit will be not asserted in tuning process.
1
Command complete
0
Command not complete
58.8.14
Interrupt Status Enable (uSDHCx_INT_STATUS_EN)
Setting the bits in this register to 1 enables the corresponding Interrupt Status to be set by
the specified event. If any bit is cleared, the corresponding Interrupt Status bit is also
cleared (i.e. when the bit in this register is cleared, the corresponding bit in Interrupt
Status Register is always 0).
• Depending on IABG bit setting, uSDHC may be programmed to sample the card
interrupt signal during the interrupt period and hold its value in the flip-flop. There
will be some delays on the Card Interrupt, asserted from the card, to the time the
Host System is informed.
• To detect a CMD line conflict, the Host Driver must set both Command Timeout
Error Status Enable and Command CRC Error Status Enable to 1.
Address: Base address + 34h offset
Bit
31
30
29
28
27
26
25
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
DMAESEN
0
TNESEN
0
AC12ESEN
0
DEBESEN
DCESEN
DTOESEN
CIESEN
CEBESEN
CCESEN
CTOESEN
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4044
NXP Semiconductors

<!-- page 4045 -->

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
TPSEN
0
RTESEN
0
CINTSEN
CRMSEN
CINSSEN
BRRSEN
BWRSEN
DINTSEN
BGESEN
TCSEN
CCSEN
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_INT_STATUS_EN field descriptions
Field
Description
31–29
Reserved
This read-only field is reserved and always has the value 0.
28
DMAESEN
DMA Error Status Enable
1
Enabled
0
Masked
27
Reserved
This read-only field is reserved and always has the value 0.
26
TNESEN
Tuning Error Status Enable
1
Enabled
0
Masked
25
Reserved
This read-only field is reserved and always has the value 0.
24
AC12ESEN
Auto CMD12 Error Status Enable
1
Enabled
0
Masked
23
Reserved
This read-only field is reserved and always has the value 0.
22
DEBESEN
Data End Bit Error Status Enable
1
Enabled
0
Masked
21
DCESEN
Data CRC Error Status Enable
1
Enabled
0
Masked
20
DTOESEN
Data Timeout Error Status Enable
1
Enabled
0
Masked
19
CIESEN
Command Index Error Status Enable
1
Enabled
0
Masked
18
CEBESEN
Command End Bit Error Status Enable
1
Enabled
0
Masked
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4045

<!-- page 4046 -->

uSDHCx_INT_STATUS_EN field descriptions (continued)
Field
Description
17
CCESEN
Command CRC Error Status Enable
1
Enabled
0
Masked
16
CTOESEN
Command Timeout Error Status Enable
1
Enabled
0
Masked
15
Reserved
This read-only field is reserved and always has the value 0.
14
TPSEN
Tuning Pass Status Enable
1
Enabled
0
Masked
13
Reserved
This read-only field is reserved and always has the value 0.
12
RTESEN
Re-Tuning Event Status Enable
1
Enabled
0
Masked
11–9
Reserved
This read-only field is reserved and always has the value 0.
8
CINTSEN
Card Interrupt Status Enable
If this bit is set to 0, the uSDHC will clear the interrupt request to the system. The Card Interrupt detection
is stopped when this bit is cleared and restarted when this bit is set to 1. The Host Driver should clear the
Card Interrupt Status Enable before servicing the Card Interrupt and should set this bit again after all
interrupt requests from the card are cleared to prevent inadvertent interrupts.
1
Enabled
0
Masked
7
CRMSEN
Card Removal Status Enable
1
Enabled
0
Masked
6
CINSSEN
Card Insertion Status Enable
1
Enabled
0
Masked
5
BRRSEN
Buffer Read Ready Status Enable
1
Enabled
0
Masked
4
BWRSEN
Buffer Write Ready Status Enable
1
Enabled
0
Masked
3
DINTSEN
DMA Interrupt Status Enable
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4046
NXP Semiconductors

<!-- page 4047 -->

uSDHCx_INT_STATUS_EN field descriptions (continued)
Field
Description
1
Enabled
0
Masked
2
BGESEN
Block Gap Event Status Enable
1
Enabled
0
Masked
1
TCSEN
Transfer Complete Status Enable
1
Enabled
0
Masked
0
CCSEN
Command Complete Status Enable
1
Enabled
0
Masked
58.8.15
Interrupt Signal Enable (uSDHCx_INT_SIGNAL_EN)
This register is used to select which interrupt status is indicated to the Host System as the
interrupt. These status bits all share the same interrupt line. Setting any of these bits to 1
enables interrupt generation. The corresponding Status register bit will generate an
interrupt when the corresponding interrupt signal enable bit is set.
Address: Base address + 38h offset
Bit
31
30
29
28
27
26
25
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
DMAEIEN
0
TNEIEN
0
AC12EIEN
0
DEBEIEN
DCEIEN
DTOEIEN
CIEIEN
CEBEIEN
CCEIEN
CTOEIEN
W
Reset
0
0
0
0
0
0
0
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
TPIEN
0
RTEIEN
0
CINTIEN
CRMIEN
CINSIEN
BRRIEN
BWRIEN
DINTIEN
BGEIEN
TCIEN
CCIEN
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_INT_SIGNAL_EN field descriptions
Field
Description
31–29
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4047

<!-- page 4048 -->

uSDHCx_INT_SIGNAL_EN field descriptions (continued)
Field
Description
28
DMAEIEN
DMA Error Interrupt Enable
1
Enable
0
Masked
27
Reserved
This read-only field is reserved and always has the value 0.
26
TNEIEN
Tuning Error Interrupt Enable
1
Enabled
0
Masked
25
Reserved
This read-only field is reserved and always has the value 0.
24
AC12EIEN
Auto CMD12 Error Interrupt Enable
1
Enabled
0
Masked
23
Reserved
This read-only field is reserved and always has the value 0.
22
DEBEIEN
Data End Bit Error Interrupt Enable
1
Enabled
0
Masked
21
DCEIEN
Data CRC Error Interrupt Enable
1
Enabled
0
Masked
20
DTOEIEN
Data Timeout Error Interrupt Enable
1
Enabled
0
Masked
19
CIEIEN
Command Index Error Interrupt Enable
1
Enabled
0
Masked
18
CEBEIEN
Command End Bit Error Interrupt Enable
1
Enabled
0
Masked
17
CCEIEN
Command CRC Error Interrupt Enable
1
Enabled
0
Masked
16
CTOEIEN
Command Timeout Error Interrupt Enable
1
Enabled
0
Masked
15
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4048
NXP Semiconductors

<!-- page 4049 -->

uSDHCx_INT_SIGNAL_EN field descriptions (continued)
Field
Description
14
TPIEN
Tuning Pass Interrupt Enable
1
Enabled
0
Masked
13
Reserved
This read-only field is reserved and always has the value 0.
12
RTEIEN
Re-Tuning Event Interrupt Enable
1
Enabled
0
Masked
11–9
Reserved
This read-only field is reserved and always has the value 0.
8
CINTIEN
Card Interrupt Interrupt Enable
1
Enabled
0
Masked
7
CRMIEN
Card Removal Interrupt Enable
1
Enabled
0
Masked
6
CINSIEN
Card Insertion Interrupt Enable
1
Enabled
0
Masked
5
BRRIEN
Buffer Read Ready Interrupt Enable
1
Enabled
0
Masked
4
BWRIEN
Buffer Write Ready Interrupt Enable
1
Enabled
0
Masked
3
DINTIEN
DMA Interrupt Enable
1
Enabled
0
Masked
2
BGEIEN
Block Gap Event Interrupt Enable
1
Enabled
0
Masked
1
TCIEN
Transfer Complete Interrupt Enable
1
Enabled
0
Masked
0
CCIEN
Command Complete Interrupt Enable
1
Enabled
0
Masked
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4049

<!-- page 4050 -->

58.8.16
Auto CMD12 Error Status
(uSDHCx_AUTOCMD12_ERR_STATUS)
When the Auto CMD12 Error Status bit in the Status register is set, the Host Driver shall
check this register to identify what kind of error the Auto CMD12 / CMD 23 indicated.
Auto CMD23 errors are indicated in bit 04-01.This register is valid only when the Auto
CMD12 Error status bit is set.
The table bwlow shows the relationship between the Auto CMGD12 CRC Error and the
Auto CMD12 Command Timeout Error.
Table 58-11. Relationship Between Command CRC Error and Command Timeout Error for
Auto CMD12
Auto CMD12 CRC Error
Auto CMD12 Timeout Error
Type of Error
0
0
No Error
0
1
Response Timeout Error
1
0
Response CRC Error
1
1
CMD line conflict
Changes in Auto CMD12 Error Status register can be classified in three scenarios:
1. When the uSDHC is going to issue an Auto CMD12.
• Set bit 0 to 1 if the Auto CMD12 can't be issued due to an error in the previous
command
• Set bit 0 to 0 if the Auto CMD12 is issued
2. At the end bit of an Auto CMD12 response.
• Check errors correspond to bits 1-4.
• Set bits 1-4 corresponding to detected errors.
• Clear bits 1-4 corresponding to detected errors
3. Before reading the Auto CMD12 Error Status bit 7.
• Set bit 7 to 1 if there is a command that can't be issued
• Clear bit 7 if there is no command to issue
The timing for generating the Auto CMD12 Error and writing to the Command register
are asynchronous. After that, bit 7 shall be sampled when the driver is not writing to the
Command register. So it is suggested to read this register only when the AC12E bit in
Interrupt Status register is set. An Auto CMD12 Error Interrupt is generated when one of
the error bits (0-4) is set to 1. The Command Not Issued By Auto CMD12 Error does not
generate an interrupt.
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4050
NXP Semiconductors

<!-- page 4051 -->

Address: Base address + 3Ch offset
Bit
31
30
29
28
27
26
25
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
SMP_CLK_SEL
EXECUTE_TUNING
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
CNIBAC12E
0
AC12IE
AC12CE
AC12EBE
AC12TOE
AC12NE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_AUTOCMD12_ERR_STATUS field descriptions
Field
Description
31–24
Reserved
This read-only field is reserved and always has the value 0.
23
SMP_CLK_SEL
Sample Clock Select
When std_tuning_en bit is set, this bit is used to select sampling clock to receive CMD and DATA.
Otherwise, this bit is reserved. This bit is set by ty tuning procedure and valid after the completion of
tuning(When Execute Tuning is cleared). Setting 1 means that tuning is completed successfully and
setting 0 means that tuning is failed. Writing 1 to this bit is meaningless and ignored. A tuning circuit is
reset by writing to 0. This bit can be cleared with setting Execute Tuning. Once the tuning circuit is reset, it
will take time to complete tuning sequence. Therefore, Host Driver should keep this bit to 1 to perform re-
tuning sequence to complete re-tuning sequence in a short time. Change of this bit is not allowed while the
Host controller us receiving response or a read data block.
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4051

<!-- page 4052 -->

uSDHCx_AUTOCMD12_ERR_STATUS field descriptions (continued)
Field
Description
1
Tuned clock is used to sample data
0
Fixed clock is used to sample data
22
EXECUTE_
TUNING
Execute Tuning
When std_tuning_en bit is set, this bit is used to start tuning procedure. Otherwise, this bit is reserved.
This bit is set to start tuning procedure and automatically cleared when runing procedure is completed.
The result of tuning is indicated to sam_clk_sel bit. Tuning procedure is aborted by writing 0.
21–8
Reserved
This read-only field is reserved and always has the value 0.
7
CNIBAC12E
Command Not Issued By Auto CMD12 Error
Setting this bit to 1 means CMD_wo_DAT is not executed due to an Auto CMD12 Error (D04-D01) in this
register.
1
Not Issued
0
No error
6–5
Reserved
This read-only field is reserved and always has the value 0.
4
AC12IE
Auto CMD12 / 23 Index Error
Occurs if the Command Index error occurs in response to a command.
1
Error, the CMD index in response is not CMD12/23
0
No error
3
AC12CE
Auto CMD12 / 23 CRC Error
Occurs when detecting a CRC error in the command response.
1
CRC Error Met in Auto CMD12/23 Response
0
No CRC error
2
AC12EBE
Auto CMD12 / 23 End Bit Error
Occurs when detecting that the end bit of command response is 0 which should be 1.
1
End Bit Error Generated
0
No error
1
AC12TOE
Auto CMD12 / 23 Timeout Error
Occurs if no response is returned within 64 SDCLK cycles from the end bit of the command. If this bit is
set to1, the other error status bits (2-4) have no meaning.
1
Time out
0
No error
0
AC12NE
Auto CMD12 Not Executed
If memory multiple block data transfer is not started, due to a command error, this bit is not set because it
is not necessary to issue an Auto CMD12. Setting this bit to 1 means the uSDHC cannot issue the Auto
CMD12 to stop a memory multiple block data transfer due to some error. If this bit is set to 1, other error
status bits (1-4) have no meaning.
1
Not executed
0
Executed
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4052
NXP Semiconductors

<!-- page 4053 -->

58.8.17
Host Controller Capabilities
(uSDHCx_HOST_CTRL_CAP)
This register provides the Host Driver with information specific to the uSDHC
implementation. The value in this register is the power-on-reset value, and does not
change with a software reset.
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
R
0
VS18
VS30
VS33
SRS
DMAS
HSS
ADMAS
0
MBL[2:0]
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
1
1
1
1
0
0
1
1
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4053

<!-- page 4054 -->

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
RETUNING_
MODE
USE_TUNING_SDR50
-
TIME_COUNT_RETUNING
-
DDR50_SUPPORT
SDR104_SUPPORT
SDR50_SUPPORT
W
Reset
1
0
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
1
1
1
uSDHCx_HOST_CTRL_CAP field descriptions
Field
Description
31–27
Reserved
This read-only field is reserved and always has the value 0.
26
VS18
Voltage Support 1.8 V
This bit shall depend on the Host System ability.
1
1.8V supported
0
1.8V not supported
25
VS30
Voltage Support 3.0 V
This bit shall depend on the Host System ability.
1
3.0V supported
0
3.0V not supported
24
VS33
Voltage Support 3.3V
This bit shall depend on the Host System ability.
1
3.3V supported
0
3.3V not supported
23
SRS
Suspend / Resume Support
This bit indicates whether the uSDHC supports Suspend / Resume functionality. If this bit is 0, the
Suspend and Resume mechanism, as well as the Read Wait, are not supported, and the Host Driver shall
not issue either Suspend or Resume commands.
1
Supported
0
Not supported
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4054
NXP Semiconductors

<!-- page 4055 -->

uSDHCx_HOST_CTRL_CAP field descriptions (continued)
Field
Description
22
DMAS
DMA Support
This bit indicates whether the uSDHC is capable of using the internal DMA to transfer data between
system memory and the data buffer directly.
1
DMA Supported
0
DMA not supported
21
HSS
High Speed Support
This bit indicates whether the uSDHC supports High Speed mode and the Host System can supply a SD
Clock frequency from 25 MHz to 50 MHz.
1
High Speed Supported
0
High Speed Not Supported
20
ADMAS
ADMA Support
This bit indicates whether the uSDHC supports the ADMA feature.
1
Advanced DMA Supported
0
Advanced DMA Not supported
19
Reserved
This read-only field is reserved and always has the value 0.
18–16
MBL[2:0]
Max Block Length
This value indicates the maximum block size that the Host Driver can read and write to the buffer in the
uSDHC. The buffer shall transfer block size without wait cycles.
000
512 bytes
001
1024 bytes
010
2048 bytes
011
4096 bytes
15–14
RETUNING_
MODE
Retuning Mode
This bit selects retuning method.
00
Mode 1
01
Mode 2
10
Mode 3
11
Reserved
13
USE_TUNING_
SDR50
Use Tuning for SDR50
This bit is set to 1. Host controller requires tuning to operate SDR50
1
SDR50 requires tuning
0
SDR does not require tuning
12
-
Reserved
11–8
TIME_COUNT_
RETUNING
Time Counter for Retuning
This bit indicates an initial value of the Retuning Timer for Re-Tuning Mode1 and 3.Setting to 0 disables
Retuning Timer.
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4055

<!-- page 4056 -->

uSDHCx_HOST_CTRL_CAP field descriptions (continued)
Field
Description
7–3
-
2
DDR50_
SUPPORT
DDR50 support
This bit indicates support of DDR50 mode.
1
SDR104_
SUPPORT
SDR104 support
This bit indicates support of SDR104 mode.
0
SDR50_
SUPPORT
SDR50 support
This bit indicates support of SDR50 mode.
58.8.18
Watermark Level (uSDHCx_WTMK_LVL)
Both write and read watermark levels (FIFO threshold) are configurable. There value can
range from 1 to 128 words. Both write and read burst lengths are also Configurable.
There value can range from 1 to 31 words.
Address: Base address + 44h offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
WR_BRST_
LEN[4:0]
WR_WML[7:0]
0
RD_BRST_
LEN[4:0]
RD_WML[7:0]
W
Reset 0
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
1
0
0
0
0
uSDHCx_WTMK_LVL field descriptions
Field
Description
31–29
Reserved
This read-only field is reserved and always has the value 0.
28–24
WR_BRST_
LEN[4:0]
Write Burst Length 1
The number of words the uSDHC writes in a single burst. The write burst length must be less than or
equal to the write watermark level, and all bursts within a watermark level transfer will be in back-to-back
mode. On reset, this field will be 8. Writing 0 to this field will result in '01000' (i.e. it is not able to clear this
field).
23–16
WR_WML[7:0]
Write Watermark Level
The number of words used as the watermark level (FIFO threshold) in a DMA write operation. Also the
number of words as a sequence of write bursts in back-to-back mode. The maximum legal value for the
write watermark level is 128.
15–13
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4056
NXP Semiconductors

<!-- page 4057 -->

uSDHCx_WTMK_LVL field descriptions (continued)
Field
Description
12–8
RD_BRST_
LEN[4:0]
Read Burst Length 2
The number of words the uSDHC reads in a single burst. The read burst length must be less than or equal
to the read watermark level, and all bursts within a watermark level transfer will be in back-to-back mode.
On reset, this field will be 8. Writing 0 to this field will result in '01000' (i.e. it is not able to clear this field).
RD_WML[7:0]
Read Watermark Level
The number of words used as the watermark level (FIFO threshold) in a DMA read operation. Also the
number of words as a sequence of read bursts in back-to-back mode. The maximum legal value for the
read water mark level is 128.
1. Due to system restriction, the actual burst length may not exceed 16.
2. Due to system restriction, the actual burst length may not exceed 16.
58.8.19
Mixer Control (uSDHCx_MIX_CTRL)
This register is used to DMA and data transfer. To prevent data loss, The software should
check if data transfer is active before writing this register. These bits are DPSEL,
MBSEL, DTDSEL, AC12EN, BCEN, and DMAEN.
Table 58-12. Transfer Type Register Setting for Various Transfer Types
Multi/Single Block Select
Block Count Enable
Block Count
Function
0
Don't Care
Don't Care
Single Transfer
1
0
Don't Care
Infinite Transfer
1
1
Positive Number
Multiple Transfer
1
1
Zero
No Data Transfer
Address: Base address + 48h offset
Bit
31
30
29
28
27
26
25
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
-
-
Reserved
FBCLK_SEL
AUTO_TUNE_
EN
SMP_CLK_SEL
EXE_TUNE
0
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
AC23EN
NIBBLE_POS
MSBSEL
DTDSEL
DDR_EN
AC12EN
BCEN
DMAEN
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4057

<!-- page 4058 -->

uSDHCx_MIX_CTRL field descriptions
Field
Description
31
-
Reserved. Always write as 1
30
-
Reserved. Always write as 0.
29
-
Reserved. Always write as 0.
28–26
-
This field is reserved.
Reserved
25
FBCLK_SEL
Feedback Clock Source Selection (Only used for SD3.0, SDR104 mode)
1
Feedback clock comes from the ipp_card_clk_out
0
Feedback clock comes from the loopback CLK
24
AUTO_TUNE_
EN
Auto Tuning Enable (Only used for SD3.0, SDR104 mode)
1
Enable auto tuning
0
Disable auto tuning
23
SMP_CLK_SEL
When STD_TUNING_EN is 0, this bit is used to select Tuned clock or Fixed clock to sample data / cmd
(Only used for SD3.0, SDR104 mode)
1
Tuned clock is used to sample data / cmd
0
Fixed clock is used to sample data / cmd
22
EXE_TUNE
Execute Tuning: (Only used for SD3.0, SDR104 mode)
When STD_TUNING_EN is 0, this bit is set to 1 to indicate the Host Driver is starting tuning procedure.
Tuning procedure is aborted by writing 0.
1
Execute Tuning
0
Not Tuned or Tuning Completed
21–8
Reserved
This read-only field is reserved and always has the value 0.
7
AC23EN
Auto CMD23 Enable
When this bit is set to 1, the Host Controller issues a CMD23 automatically before issuing a command
specified in the Command Register.
6
NIBBLE_POS
In DDR 4-bit mode nibble position indictation. 0- the sequence is 'odd high nibble -> even high nibble ->
odd low nibble -> even low nibble'; 1- the sequence is 'odd high nibble -> odd low nibble -> even high
nibble -> even low nibble'.
5
MSBSEL
Multi / Single Block Select
This bit enables multiple block DATA line data transfers. For any other commands, this bit can be set to 0.
If this bit is 0, it is not necessary to set the Block Count register. (Refer to Command Transfer Type
(uSDHC_CMD_XFR_TYP) ).
1
Multiple Blocks
0
Single Block
4
DTDSEL
Data Transfer Direction Select
This bit defines the direction of DATA line data transfers. The bit is set to 1 by the Host Driver to transfer
data from the SD card to the uSDHC and is set to 0 for all other commands.
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4058
NXP Semiconductors

<!-- page 4059 -->

uSDHCx_MIX_CTRL field descriptions (continued)
Field
Description
1
Read (Card to Host)
0
Write (Host to Card)
3
DDR_EN
Dual Data Rate mode selection
2
AC12EN
Auto CMD12 Enable
Multiple block transfers for memory require a CMD12 to stop the transaction. When this bit is set to 1, the
uSDHC will issue a CMD12 automatically when the last block transfer has completed. The Host Driver
shall not set this bit to issue commands that do not require CMD12 to stop a multiple block data transfer.
In particular, secure commands defined in File Security Specification (see reference list) do not require
CMD12. In single block transfer, the uSDHC will ignore this bit no matter it is set or not.
1
Enable
0
Disable
1
BCEN
Block Count Enable
This bit is used to enable the Block Count register, which is only relevant for multiple block transfers.
When this bit is 0, the internal counter for block is disabled, which is useful in executing an infinite transfer.
1
Enable
0
Disable
0
DMAEN
DMA Enable
This bit enables DMA functionality. If this bit is set to 1, a DMA operation shall begin when the Host Driver
sets the DPSEL bit of this register. Whether the Simple DMA or the Advanced DMA is active depends on
the DMA Select field of the Protocol Control register.
1
Enable
0
Disable
58.8.20
Force Event (uSDHCx_FORCE_EVENT)
The Force Event Register is not a physically implemented register. Rather, it is an
address at which the Interrupt Status Register can be written if the corresponding bit of
the Interrupt Status Enable Register is set. This register is a write only register and
writing 0 to it has no effect. Writing 1 to this register actually sets the corresponding bit
of Interrupt Status Register. A read from this register always results in 0's. In order to
change the corresponding status bits in the Interrupt Status Register, make sure to set
IPGEN bit in System Control Register so that IPG_CLK is always active.
Forcing a card interrupt will generate a short pulse on the DATA1 line, and the driver
may treat this interrupt as a normal interrupt. The interrupt service routine may skip
polling the card interrupt factor as the interrupt is self cleared.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4059

<!-- page 4060 -->

Address: Base address + 50h offset
Bit
31
30
29
28
27
26
25
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
0
0
0
0
0
0
0
0
0
0
W
FEVTCINT
FEVTDMAE
FEVTTNE
FEVTAC12E
FEVTDEBE
FEVTDCE
FEVTDTOE
FEVTCIE
FEVTCEBE
FEVTCCE
FEVTCTOE
Reset
0
0
0
0
0
0
0
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
0
0
0
0
0
0
W
FEVTCNIBAC12E
FEVTAC12IE
FEVTAC12EBE
FEVTAC12CE
FEVTAC12TOE
FEVTAC12NE
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_FORCE_EVENT field descriptions
Field
Description
31
FEVTCINT
Force Event Card Interrupt
Writing 1 to this bit generates a short low-level pulse on the internal DATA1 line, as if a self clearing
interrupt was received from the external card. If enabled, the CINT bit will be set and the interrupt service
routine may treat this interrupt as a normal interrupt from the external card.
30–29
Reserved
This read-only field is reserved and always has the value 0.
28
FEVTDMAE
Force Event DMA Error
Forces the DMAE bit of Interrupt Status Register to be set.
27
Reserved
This read-only field is reserved and always has the value 0.
26
FEVTTNE
Force Tuning Error
Forces the TNE bit of Interrupt Status Register to be set.
25
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4060
NXP Semiconductors

<!-- page 4061 -->

uSDHCx_FORCE_EVENT field descriptions (continued)
Field
Description
24
FEVTAC12E
Force Event Auto Command 12 Error
Forces the AC12E bit of Interrupt Status Register to be set.
23
Reserved
This read-only field is reserved and always has the value 0.
22
FEVTDEBE
Force Event Data End Bit Error
Forces the DEBE bit of Interrupt Status Register to be set.
21
FEVTDCE
Force Event Data CRC Error
Forces the DCE bit of Interrupt Status Register to be set.
20
FEVTDTOE
Force Event Data Time Out Error
Force the DTOE bit of Interrupt Status Register to be set.
19
FEVTCIE
Force Event Command Index Error
Forces the CCE bit of Interrupt Status Register to be set.
18
FEVTCEBE
Force Event Command End Bit Error
Forces the CEBE bit of Interrupt Status Register to be set.
17
FEVTCCE
Force Event Command CRC Error
Forces the CCE bit of Interrupt Status Register to be set.
16
FEVTCTOE
Force Event Command Time Out Error
Forces the CTOE bit of Interrupt Status Register to be set.
15–8
Reserved
This read-only field is reserved and always has the value 0.
7
FEVTCNIBAC12E
Force Event Command Not Executed By Auto Command 12 Error
Forces the CNIBAC12E bit in the Auto Command12 Error Status Register to be set.
6–5
Reserved
This read-only field is reserved and always has the value 0.
4
FEVTAC12IE
Force Event Auto Command 12 Index Error
Forces the AC12IE bit in the Auto Command12 Error Status Register to be set.
3
FEVTAC12EBE
Force Event Auto Command 12 End Bit Error
Forces the AC12EBE bit in the Auto Command12 Error Status Register to be set.
2
FEVTAC12CE
Force Event Auto Command 12 CRC Error
Forces the AC12CE bit in the Auto Command12 Error Status Register to be set.
1
FEVTAC12TOE
Force Event Auto Command 12 Time Out Error
Forces the AC12TOE bit in the Auto Command12 Error Status Register to be set.
0
FEVTAC12NE
Force Event Auto Command 12 Not Executed
Forces the AC12NE bit in the Auto Command12 Error Status Register to be set.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4061

<!-- page 4062 -->

58.8.21
ADMA Error Status Register
(uSDHCx_ADMA_ERR_STATUS)
When an ADMA Error Interrupt has occurred, the ADMA Error States field in this
register holds the ADMA state and the ADMA System Address register holds the address
around the error descriptor.
For recovering from this error, the Host Driver requires the ADMA state to identify the
error descriptor address as follows:
• ST_STOP: Previous location set in the ADMA System Address register is the error
descriptor address.
• ST_FDS: Current location set in the ADMA System Address register is the error
descriptor address.
• ST_CADR: This state is never set because it only increments the descriptor pointer
and doesn't generate an ADMA error.
• ST_TFR: Previous location set in the ADMA System Address register is the error
descriptor address.
In case of a write operation, the Host Driver should use the ACMD22 to get the number
of the written block, rather than using this information, since unwritten data may exist in
the Host Controller.
The Host Controller generates the ADMA Error Interrupt when it detects invalid
descriptor data (Valid=0) in the ST_FDS state. The Host Driver can distinguish this error
by reading the Valid bit of the error descriptor.
Table 58-13. ADMA Error State Coding
D01-D00
ADMA Error State (when error has
occurred)
Contents of ADMA System Address
Register
00
ST_STOP (Stop DMA)
Holds the address of the next executable
Descriptor command
01
ST_FDS (Fetch Descriptor)
Holds the valid Descriptor address
10
ST_CADR (Change Address)
No ADMA Error is generated
11
ST_TFR (Transfer Data)
Holds the address of the next executable
Descriptor command
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4062
NXP Semiconductors

<!-- page 4063 -->

Address: Base address + 54h offset
Bit
31
30
29
28
27
26
25
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
ADMADCE
ADMALME
ADMAES
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_ADMA_ERR_STATUS field descriptions
Field
Description
31–4
Reserved
This read-only field is reserved and always has the value 0.
3
ADMADCE
ADMA Descritor Error
This error occurs when invalid descriptor fetched by ADMA.
1
Error
0
No Error
2
ADMALME
ADMA Length Mismatch Error
This error occurs in the following 2 cases:
• While the Block Count Enable is being set, the total data length specified by the Descriptor table is
different from that specified by the Block Count and Block Length.
• Total data length cannot be divided by the block length.
1
Error
0
No Error
ADMAES
ADMA Error State (when ADMA Error is occurred)
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4063

<!-- page 4064 -->

uSDHCx_ADMA_ERR_STATUS field descriptions (continued)
Field
Description
This field indicates the state of the ADMA when an error has occurred during an ADMA data transfer.
Refer to ADMA Error Status Register (uSDHC_ADMA_ERR_STATUS) for more details.
58.8.22
ADMA System Address (uSDHCx_ADMA_SYS_ADDR)
This register contains the physical system memory address used for ADMA transfers.
Address: Base address + 58h offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
ADS_ADDR[31:0]
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
uSDHCx_ADMA_SYS_ADDR field descriptions
Field
Description
31–2
ADS_
ADDR[31:0]
ADMA System Address
This register holds the word address of the executing command in the Descriptor table. At the start of
ADMA, the Host Driver shall set the start address of the Descriptor table. The ADMA engine increments
this register address whenever fetching a Descriptor command. When the ADMA is stopped at the Block
Gap, this register indicates the address of the next executable Descriptor command. When the ADMA
Error Interrupt is generated, this register shall hold the valid Descriptor address depending on the ADMA
state. The lower 2 bits of this register is tied to '0' so the ADMA address is always word aligned.
Since this register supports dynamic address reflecting, when TC bit is set, it automatically alters the value
of internal address counter, so SW cannot change this register when TC bit is set. Such restriction is also
listed in Software Restrictions .
Reserved
This read-only field is reserved and always has the value 0.
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4064
NXP Semiconductors

<!-- page 4065 -->

58.8.23
DLL (Delay Line) Control (uSDHCx_DLL_CTRL)
This register contains control bits for DLL.
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
R
DLL_CTRL_REF_
UPDATE_INT[3:0]
DLL_CTRL_SLV_UPDATE_INT[7:0]
0
DLL_CTRL_SLV_
DLY_TARGET1
W
Reset
0
0
0
0
0
0
0
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
DLL_CTRL_SLV_OVERRIDE_VAL[6:0]
DLL_CTRL_SLV_
OVERRIDE
DLL_CTRL_GATE_
UPDATE
DLL_CTRL_SLV_DLY_
TARGET0
DLL_CTRL_SLV_
FORCE_UPD
DLL_CTRL_RESET
DLL_CTRL_ENABLE
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
uSDHCx_DLL_CTRL field descriptions
Field
Description
31–28
DLL_CTRL_
REF_UPDATE_
INT[3:0]
DLL control loop update interval. The interval cycle is (2 + REF_UPDATE_INT) * REF_CLOCK. By default,
the DLL control loop shall update every two REF_CLOCK cycles. It should be noted that increasing the
reference delay-line update interval reduces the ability of the DLL to adjust to fast changes in conditions
that may effect the delay (such as voltage and temperature)
27–20
DLL_CTRL_
SLV_UPDATE_
INT[7:0]
Slave delay line update interval. If default 0 is used, it means 256 cycles of REF_CLOCK. A value of 0x0f
results in 15 cycles and so on. Note that software can always cause an update of the slave-delay line
using the SLV_FORCE_UPDATE register. Note that the slave delay line will also update automatically
when the reference DLL transitions to a locked state (from an un-locked state).
19
Reserved
This read-only field is reserved and always has the value 0.
18–16
DLL_CTRL_
SLV_DLY_
TARGET1
Refer to DLL_CTRL_SLV_DLY_TARGET0 below.
15–9
DLL_CTRL_
SLV_
OVERRIDE_
VAL[6:0]
When SLV_OVERRIDE = 1 This field is used to select 1 of 128 physical taps manually. A value of 0
selects tap 1, and a value of 0x7f selects tap 128.
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4065

<!-- page 4066 -->

uSDHCx_DLL_CTRL field descriptions (continued)
Field
Description
8
DLL_CTRL_
SLV_OVERRIDE
Set this bit to 1 to Enable manual override for slave delay chain using SLV_OVERRIDE_VAL; to set 0 to
disable manual override. This feature does not require the DLL to be enabled using the ENABLE bit. In
fact to reduce power, if SLV_OVERRIDE is used, it is recommended to disable the DLL with ENABLE = 0
7
DLL_CTRL_
GATE_UPDATE
Set this bit to 1 to prevent the DLL from updating (since when clock_in exists, glitches may appear during
DLL updates). This bit may be used by software if such a condition occurs. Clear the bit to 0 to allow the
DLL to update automatically.
6–3
DLL_CTRL_
SLV_DLY_
TARGET0
The delay target for the uSDHC loopback read clock can be programmed in 1/16th increments of an
ref_clock half-period. The delay is ((DLL_CTRL_SLV_DLY_TARGET1 +1)* REF_CLOCK / 2) / 16 So the
input read-clock can be delayed relative input data from (REF_CLOCK / 2) / 16 to REF_CLOCK * 4.
2
DLL_CTRL_
SLV_FORCE_
UPD
Setting this bit to 1, forces the slave delay line to update to the DLL calibrated value immediately. The
slave delay line shall update automatically based on the SLV_UPDATE_INT interval or when a DLL lock
condition is sensed. Subsequent forcing of the slave-line update can only occur if SLV_FORCE_UP is set
back to 0 and then asserted again (edge triggered). Be sure to use it when uSDHC is idle. This function
may not work when uSDHC is working on data / cmd / response.
1
DLL_CTRL_
RESET
Setting this bit to 1 force a reset on DLL. This will cause the DLL to lose lock and re-calibrate to detect an
REF_CLOCK half period phase shift. This signal is used by the DLL as edge-sensitive, so in order to
create a subsequent reset, RESET must be taken low and then asserted again.
0
DLL_CTRL_
ENABLE
Set this bit to 1 to enable the DLL and delay chain; otherwise; set to 0 to bypasses DLL. Note that using
the slave delay line override feature with SLV_OVERRIDE and SLV_OVERRIDE VAL, the DLL does not
need to be enabled.
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4066
NXP Semiconductors

<!-- page 4067 -->

58.8.24
DLL Status (uSDHCx_DLL_STATUS)
This register contains the DLL status information. All bits are read only and will read the
same as the power-reset value.
Address: Base address + 64h offset
Bit
31
30
29
28
27
26
25
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
DLL_STS_REF_SEL[6:0]
DLL_STS_SLV_SEL[6:0]
DLL_STS_REF_LOCK
DLL_STS_SLV_LOCK
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4067

<!-- page 4068 -->

uSDHCx_DLL_STATUS field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15–9
DLL_STS_REF_
SEL[6:0]
Reference delay line select taps. This is encoded by 7 bits for 127 taps.
8–2
DLL_STS_SLV_
SEL[6:0]
Slave delay line select status. This is the instant value generated from reference chain. Since the
reference chain can only be updated when REF_CLOCK is detected, this value should be the right value
to be updated when the reference is locked.
1
DLL_STS_REF_
LOCK
Reference DLL lock status. This signifies that the DLL has detected and locked to a half-phase ref_clock
shift, allowing the slave delay-line to perform programmed clock delays
0
DLL_STS_SLV_
LOCK
Slave delay-line lock status. This signifies that a valid calibration has been set to the slave-delay line and
that the slave-delay line is implementing the programmed delay value
58.8.25
CLK Tuning Control and Status
(uSDHCx_CLK_TUNE_CTRL_STATUS)
This register contains the Clock Tuning Control status information. All bits are read only
and will read the same as the power-reset value. This register is added to support SD3.0
UHS-I SDR104 mode.
Address: Base address + 68h offset
Bit
31
30
29
28
27
26
25
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
PRE_
ERR
TAP_SEL_PRE[6:0]
TAP_SEL_OUT[3:0]
TAP_SEL_POST[3:0]
W
Reset
0
0
0
0
0
0
0
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
NXT_
ERR
DLY_CELL_SET_PRE[6:0]
DLY_CELL_SET_OUT[6:0]
DLY_CELL_SET_
POST[6:0]
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_CLK_TUNE_CTRL_STATUS field descriptions
Field
Description
31
PRE_ERR
PRE error which means the number of delay cells added on the feedback clock is too small. It is valid only
when SMP_CLK_SEL of Mix control register (bit23 of 0x48) is enabled.
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4068
NXP Semiconductors

<!-- page 4069 -->

uSDHCx_CLK_TUNE_CTRL_STATUS field descriptions (continued)
Field
Description
30–24
TAP_SEL_
PRE[6:0]
Reflects the number of delay cells added on the feedback clock between the feedback clock and
CLK_PRE.
When AUTO_TUNE_EN (bit24 of 0x48) is disabled, TAP_SEL_PRE is always equal to
DLY_CELL_SET_PRE.
When AUTO_TUNE_EN (bit24 of 0x48) is enabled, TAP_SEL_PRE will be updated automatically
according to the status of the auto tuning circuit to adjust the sample clock phase.
23–20
TAP_SEL_
OUT[3:0]
Reflect the number of delay cells added on the feedback clock between CLK_PRE and CLK_OUT.
19–16
TAP_SEL_
POST[3:0]
Reflect the number of delay cells added on the feedback clock between CLK_OUT and CLK_POST.
15
NXT_ERR
NXT error which means the number of delay cells added on the feedback clock is too large. It's valid only
when SMP_CLK_SEL of Mix control register (bit23 of 0x48) is enabled.
14–8
DLY_CELL_
SET_PRE[6:0]
Set the number of delay cells on the feedback clock between the feedback clock and CLK_PRE.
7–4
DLY_CELL_
SET_OUT[6:0]
Set the number of delay cells on the feedback clock between CLK_PRE and CLK_OUT.
DLY_CELL_
SET_POST[6:0]
Set the number of delay cells on the feedback clock between CLK_OUT and CLK_POST.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4069

<!-- page 4070 -->

58.8.26
Vendor Specific Register (uSDHCx_VEND_SPEC)
This register contains the vendor specific control / status register.
Address: Base address + C0h offset
Bit
31
30
29
28
27
26
25
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
CMD_BYTE_EN
-
-
-
-
INT_ST_VAL[7:0]
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
CRC_CHK_DIS
CARD_CLK_SOFT_EN
IPG_PERCLK_SOFT_EN
HCLK_SOFT_EN
IPG_CLK_SOFT_EN
-
-
FRC_SDCLK_ON
CLKONJ_IN_ABORT
WP_
POL
CD_
POL
DAT3_CD_POL
AC12_WR_CHKBUSY_EN
CONFLICT_CHK_EN
VSELECT
EXT_DMA_EN
W
Reset
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
1
0
0
1
uSDHCx_VEND_SPEC field descriptions
Field
Description
31
CMD_BYTE_EN
Byte access
0
Disable
1
Enable
30
-
Reserved. Always write as 0.
Table continues on the next page...
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4070
NXP Semiconductors

<!-- page 4071 -->

uSDHCx_VEND_SPEC field descriptions (continued)
Field
Description
29
-
Reserved. Always write as 1.
28
-
Reserved. Always write as 0.
27–24
-
Reserved. Always write as 4'b0000.
23–16
INT_ST_VAL[7:0]
Internal State Value
Internal state value, reflecting the corresponding state value selected by Debug Select field. This field is
read-only and write to this field does not have effect.
15
CRC_CHK_DIS
CRC Check Disable
0
Check CRC16 for every read data packet and check CRC bits for every write data packet
1
Ignore CRC16 check for every read data packet and ignore CRC bits check for every write data
packet
14
CARD_CLK_
SOFT_EN
Card Clock Software Enable
0
Gate off the sd_clk
1
Enable the sd_clk
13
IPG_PERCLK_
SOFT_EN
IPG_PERCLK Software Enable
0
Gate off the IPG_PERCLK
1
Enable the IPG_PERCLK
12
HCLK_SOFT_EN
AHB Clock Software Enable
NOTE: Hardware auto-enables the AHB clock when the internal DMA is enabled even if
HCLK_SOFT_EN is 0.
0
Gate off the AHB clock.
1
Enable the AHB clock.
11
IPG_CLK_
SOFT_EN
IPG_CLK Software Enable
0
Gate off the IPG_CLK
1
Enable the IPG_CLK
10
-
Reserved. Always write as 0.
9
-
Reserved. Always write as 0.
8
FRC_SDCLK_
ON
Force CLK output active
0
CLK active or inactive is fully controlled by the hardware.
1
Force CLK active.
7
CLKONJ_IN_
ABORT
Only for debug.
Force CLK output active when sending Abort command:
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4071

<!-- page 4072 -->

uSDHCx_VEND_SPEC field descriptions (continued)
Field
Description
0
The CLK output is active when sending abort command while data is transmitting even if the internal
FIFO is full (for read) or empty (for write).
1
The CLK output is inactive when sending abort command while data is transmitting if the internal FIFO
is full (for read) or empty (for write).
6
WP_POL
Only for debug.
Polarity of the WP pin:
0
WP pin is high active.
1
WP pin is low active.
5
CD_POL
Only for debug.
Polarity of the CD_B pin:
0
CD_B pin is low active.
1
CD_B pin is high active.
4
DAT3_CD_POL
Only for debug.
Polarity of DATA3 pin when it is used as card detection.
0
Card detected when DATA3 is high.
1
Card detected when DATA3 is low.
3
AC12_WR_
CHKBUSY_EN
Check busy enable after auto CMD12 for write data packet
0
Do not check busy after auto CMD12 for write data packet
1
Check busy after auto CMD12 for write data packet
2
CONFLICT_
CHK_EN
Conflict check enable.
It is not implemented in uSDHC IP.
0
Conflict check disable
1
Conflict check enable
1
VSELECT
Voltage Selection
Change the value of output signal VSELECT, to control the voltage on pads for external card. There must
be a control circuit out of uSDHC to change the voltage on pads.
1
Change the voltage to low voltage range, around 1.8 V
0
Change the voltage to high voltage range, around 3.0 V
0
EXT_DMA_EN
External DMA Request Enable
Enable the request to external DMA. When the internal DMA (either Simple DMA or Advanced DMA) is not
in use, and this bit is set, uSDHC will send out DMA request when the internal buffer is ready. This bit is
particularly useful when transferring data by Arm platform polling mode, and it is not allowed to send out
the external DMA request. By default, this bit is set.
0
In any scenario, uSDHC does not send out external DMA request.
1
When internal DMA is not active, the external DMA request will be sent out.
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4072
NXP Semiconductors

<!-- page 4073 -->

58.8.27
MMC Boot Register (uSDHCx_MMC_BOOT)
This register contains the MMC Fast Boot control register.
Address: Base address + C4h offset
Bit
31
30
29
28
27
26
25
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
BOOT_BLK_CNT[15:0]
W
Reset
0
0
0
0
0
0
0
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
DISABLE_TIME_
OUT
AUTO_SABG_
EN
BOOT_EN
BOOT_MODE
BOOT_ACK
DTOCV_ACK[3:0]
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
uSDHCx_MMC_BOOT field descriptions
Field
Description
31–16
BOOT_BLK_
CNT[15:0]
The value defines the Stop At Block Gap value of automatic mode. When received card block cnt is equal
to (BLK_CNT - BOOT_BLK_CNT) and AUTO_SABG_EN is 1, then Stop At Block Gap.
Here, BLK_CNT is defined in the Block Atrributes Register, bit31 - 16 of 0x04.
15–9
Reserved
This read-only field is reserved and always has the value 0.
8
DISABLE_TIME_
OUT
Disable Time Out
NOTE: When this bit is set, there is no timeout check no matter whether BOOT_EN is set or not.
0
Enable time out
1
Disable time out
7
AUTO_SABG_
EN
During boot, enable auto stop at block gap function. This function will be triggered, and host will stop at
block gap when received card block cnt is equal to (BLK_CNT - BOOT_BLK_CNT).
6
BOOT_EN
Boot mode enable
0
Fast boot disable
1
Fast boot enable
5
BOOT_MODE
Boot mode select
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4073

<!-- page 4074 -->

uSDHCx_MMC_BOOT field descriptions (continued)
Field
Description
0
Normal boot
1
Alternative boot
4
BOOT_ACK
Boot ACK mode select
0
No ack
1
Ack
DTOCV_
ACK[3:0]
Boot ACK time out counter value.
0000
SDCLK x 2^13
0001
SDCLK x 2^14
0010
SDCLK x 2^15
0011
SDCLK x 2^16
0100
SDCLK x 2^17
0101
SDCLK x 2^18
0110
SDCLK x 2^19
0111
SDCLK x 2^20
1110
SDCLK x 2^27
1111
SDCLK x 2^28
58.8.28
Vendor Specific 2 Register (uSDHCx_VEND_SPEC2)
This register contains the vendor specific control 2 register.
Address: Base address + C8h offset
Bit
31
30
29
28
27
26
25
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
ACMD23_ARGU2_
EN
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
Reserved
0
0
CARD_INT_AUTO_
CLR_DIS
TUNING_CMD_EN
TUNING_1bit_EN
TUNING_8bit_EN
CARD_INT_D3_
TEST
SDR104_NSD_DIS
SDR104_OE_DIS
SDR104_TIMING_
DIS
W
Reset
0
0
0
0
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
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4074
NXP Semiconductors

<!-- page 4075 -->

uSDHCx_VEND_SPEC2 field descriptions
Field
Description
31–24
-
This field is reserved.
23
ACMD23_
ARGU2_EN
Default1
1
Argument2 register enable for ACMD23 sharing with SDMA system address register. Default is
enable.
0
Disable
22–12
-
This field is reserved.
11–10
-
This field is reserved.
Reserved
9
Reserved
This read-only field is reserved and always has the value 0.
8
Reserved
This read-only field is reserved and always has the value 0.
7
CARD_INT_
AUTO_CLR_DIS
Disable the feature to clear the Card interrupt status bit when Card Interrupt status enable bit is cleared.
Only for debug.
0
Card interrupt status bit (CINT) can be cleared when Card Interrupt status enable bit is 0.
1
Card interrupt status bit (CINT) can only be cleared by writting a 1 to CINT bit.
6
TUNING_CMD_
EN
Enable the auto tuning circuit to check the CMD line.
0
Auto tuning circuit does not check the CMD line.
1
Auto tuning circuit checks the CMD line.
5
TUNING_1bit_EN
Enable the auto tuning circuit to check the DATA0 only. It is used with the TUNING_8bit_EN together.
4
TUNING_8bit_EN Enable the auto tuning circuit to check the DATA[7:0]. It is used with the TUNING_1bit_EN together.
NOTE: The format of these two bits are [TUNNING_8bit_EN:TUNNING_1bit_EN].
00
Tuning circuit only checks the DATA[3:0].
01
Tuning circuit only checks the DATA0.
10
Tuning circuit checks the whole DATA[7:0].
11
Invalid.
3
CARD_INT_D3_
TEST
Card Interrupt Detection Test
This bit only uses for debugging.
0
Check the card interrupt only when DATA3 is high.
1
Check the card interrupt by ignoring the status of DATA3.
2
SDR104_NSD_
DIS
Interrupt window after abort command is sent.
This bit only uses for debugging.
0
Enable the interrupt window 9 cycles later after the end of the I/O abort command (or CMD12) is sent.
1
Enable the interrupt window 5 cycles later after the end of the I/O abort command (or CMD12) is sent.
1
SDR104_OE_
DIS
CMD_OE / DATA_OE logic generation test.
This bit only uses for debugging.
Table continues on the next page...
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4075

<!-- page 4076 -->

uSDHCx_VEND_SPEC2 field descriptions (continued)
Field
Description
0
Drive the CMD_OE / DATA_OE for one more clock cycle after the end bit.
1
Stop to drive the CMD_OE / DATA_OE at once after driving the end bit.
0
SDR104_
TIMING_DIS
Timeout counter test.
This bit only uses for debugging.
0
The timeout counter for Ncr changes to 80, Ncrc changes to 21.
1
The timeout counter for Ncr changes to 72, Ncrc changes to 15.
58.8.29
Tuning Control Register (uSDHCx_TUNING_CTRL)
The register contains configuration of tuning circuit.
Address: Base address + CCh offset
Bit
31
30
29
28
27
26
25
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
STD_TUNING_EN
-
TUNING_WINDOW
-
TUNING_STEP
W
Reset
0
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
TUNING_COUNTER
TUNING_START_TAP
W
Reset
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
0
0
0
uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4076
NXP Semiconductors

<!-- page 4077 -->

uSDHCx_TUNING_CTRL field descriptions
Field
Description
31–25
-
Reserved
24
STD_TUNING_
EN
Standard tuning circuit and procedure enable:
This bit is used to enable standard tuning circuit and procedure.
23
-
Reserved
22–20
TUNING_
WINDOW
Select data window value for auto tuning
19
-
Reserved
18–16
TUNING_STEP
The increasing delay cell steps in tuning procedure.
15–8
TUNING_
COUNTER
The MAX repeat CMD19 times in tuning procedure.
TUNING_
START_TAP
The start dealy cell point when send first CMD19 in tuning procedure.
Chapter 58 Ultra Secured Digital Host Controller (uSDHC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4077

<!-- page 4078 -->

uSDHC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4078
NXP Semiconductors

