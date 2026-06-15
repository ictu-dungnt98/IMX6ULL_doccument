# Chapter 15: AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)

> Nguồn: `IMX6ULLRM.pdf` — trang 465–504

<!-- page 465 -->

Chapter 15
AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
15.1
Overview
The AHB-to-APBH bridge provides the chip with an inexpensive peripheral attachment
bus running on the AHB's HCLK. (The H in APBH denotes that the APBH is
synchronous to HCLK.)
As shown in the figure below, the AHB-to-APBH bridge includes the AHB-to-APB PIO
bridge for a memory-mapped I/O to the APB devices, as well as a central DMA facility
for devices on this bus and a vectored interrupt controller for the Arm core. Each one of
the APB peripherals, including the vectored interrupt controller, is documented in their
respective chapters.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
465

<!-- page 466 -->

AHB Slave
APBH Master
AHB Master
AHB
AHB-to-APBH DMA
APBH
AHB-to-APBH Bridge
GPMI1
GPMIn
.
.
.
.
.
Figure 15-1. AHB-to-APBH Bridge DMA Block Diagram
The DMA controller uses the APBH bus to transfer read and write data to and from each
peripheral. There is no separate DMA bus for these devices. Contention between the
DMA's use of the APBH bus and the AHB-to-APB bridge functions' use of the APBH is
mediated by an internal arbitration logic. For contention between these two units, the
DMA is favored and the AHB slave will report "not ready" through its HREADY output
until the bridge transfer can complete. The arbiter tracks repeated lockouts and inverts the
priority, guaranteeing the Arm platform every fourth transfer on the APB.
15.2
Clocks
The table found here describes the clock sources for APBH. Please see Clock Controller
Module (CCM) for clock setting, configuration and gating information.
Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
466
NXP Semiconductors

<!-- page 467 -->

Table 15-1. APBH Clocks
Clock name
Clock Root
Description
hclk
bch_clk_root
Module clock
15.3
APBH DMA
The DMA supports four channels of DMA services, as shown in the following table. The
shared DMA resource allows each independent channel to follow a simple chained
command list. Command chains are built up using the general structure, as shown in
Figure 15-2.
Table 15-2. APBH DMA channel assignments
APBH DMA Channel #
Usage
0
GPMI0
1
GPMI1
2
GPMI2
3
GPMI3
A single command structure or channel command word specifies a number of operations
to be performed by the DMA in support of a given device. Thus, the Arm platform can
set up large units of work, chaining together many DMA channel command words, pass
them off to the DMA, and have no further concern for the device until the DMA
completion interrupt occurs. The goal is to have enough intelligence in the DMA and the
devices to keep the interrupt frequency from any device below 1 KHz (arrival intervals
longer than 1 ms).
A single command structure can issue 32-bit PIO write operations to key registers in the
associated device using the same APB bus and controls that it uses to write DMA data
bytes to the device. For example, this allows a chain of operations to be issued to the
GPMI controller to send NAND command bytes, address bytes, and data transfers where
the command and the address structure is completely under software control, but the
administration of that transfer is handled autonomously by the DMA. Each DMA
structure can have 0–15 PIO words appended to it. The CMDPIOWORDS field, if non-
zero, instructs the DMA engine to copy these words to the APB, beginning at the first
register address offset for the peripheral and incrementing the register offset each cycle.
The DMA master generates only normal read/write transfers to the APBH. It does not
generate set, clear, or toggle (SCT) transfers.
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
467

<!-- page 468 -->

After any requested PIO words have been transferred to the peripheral, the DMA
examines the two-bit command field in the channel command structure. Table 15-3
shows the four commands implemented by the DMA.
NEXTCMDADDR
COMMAND
BUFFER ADDRESS
PIOWORD
NANDWAIT4READY
word 0
word 1
word 2
word 3-n
XFER_COUNT
CHAIN
IRQONCMPLT
NANDLOCK
SEMAPHORE
WAIT4ENDCMD
HALTONTERMINATE
CMDPIOWORDS
Figure 15-2. AHB-to-APBH Bridge DMA channel command structure
Table 15-3. APBH DMA commands
DMA Command
Usage
00
NO_DMA_XFER. Perform any requested PIO word transfers, but terminate the command before any DMA
transfer.
01
DMA_WRITE. Perform any requested PIO word transfers, then perform a DMA transfer from the
peripheral for the specified number of bytes.
10
DMA_READ. Perform any requested PIO word transfers and then perform a DMA transfer to the
peripheral for the specified number of bytes.
11
DMA_SENSE. Perform any requested PIO word transfers, then perform a conditional branch to the next
chained device. Follow the NEXTCMD_ADDR pointer if the peripheral sense is false. Follow the
BUFFER_ADDRESS as a chain pointer if the peripheral sense line is true. This command becomes a no-
operation for any channel other than a GPMI channel.
DMA_WRITE operations copy data bytes to the system memory (on-chip RAM or
SDRAM) from the associated peripheral.
DMA_READ operations copy data bytes to the APB peripheral from the system memory.
The DMA engine contains a shared byte aligner that aligns bytes from system memory to
or from the peripherals. Peripherals always assume little-endian-aligned data arrives or
departs on their 32-bit APB. The DMA_READ transfer uses the BUFFER_ADDRESS
word in the command structure to point to the DMA data buffer to be read by the
DMA_READ command.
APBH DMA
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
468
NXP Semiconductors

<!-- page 469 -->

The NO_DMA_XFER command is used to write PIO words to a device without
performing any DMA data byte transfers. This command is useful in such applications as
activating the NAND devices CHECKSTATUS operation. The check status command
reads a status byte from the NAND device, performs an XOR and MASK against an
expected value supplied as part of the PIO transfer. Once the read check completes (see
NAND Read Status Polling Example), the NO_DMA_XFER command completes. The
result in the peripheral is that its sense line is driven by the results of the comparison. The
sense flip-flop is only updated by CHECKSTATUS for the device that is executed. At
some future point, the chain contains a DMA command structure with the fourth and final
command value, that is, the DMA_SENSE command.
As each DMA command completes, it triggers the DMA to load the next DMA command
structure in the chain. The normal flow list of DMA commands is found by following the
NEXTCMD_ADDR pointer in the DMA command structure. The DMA_SENSE
command uses the DMA buffer pointer word of the command structure to point to an
alternate DMA command structure chain or list. The DMA_SENSE command examines
the sense line of the associated peripheral. If the sense line is false, then the DMA follows
the standard list found whose next command is found from the pointer in the
NEXTCMD_ADDR word of the command structure. If the sense line is true, then the
DMA follows the alternate list whose next command is found from the pointer in the
DMA Buffer Pointer word of the DMA_SENSE command structure (see Figure 15-2).
The sense command ignores the CHAIN bit, so that both pointers must be valid when the
DMA comes to a sense command.
If the wait-for-end-command bit (WAIT4ENDCMD) is set in a command structure, the
DMA channel waits for the device to signal completion of a command by toggling the
endcmd signal before proceeding to load and execute the next command structure. Then,
if DECREMENT_SEMAPHORE is set, the semaphore is decremented after the end
command is seen.
A detailed bit-field view of the DMA command structure is shown in the following table,
which shows a field that specifies the number of bytes to be transferred by this DMA
command. The transfer-count mechanism is duplicated in the associated peripheral, either
as an implied or as a specified count in the peripheral.
Table 15-4. DMA channel command word in system memory
31
30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
NEXT_COMMAND_ADDRESS
Table continues on the next page...
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
469

<!-- page 470 -->

Table 15-4. DMA channel command word in system memory (continued)
Number DMA Bytes to Transfer
Number PIO
Words to
Write
HALTONTERMINATE
WAIT4ENDCMD
DECREMENT SEMAPHORE
NANDwAIT4READY
NANDLOCK
IRQ_COMPLETE
CHAIN
COMMAND
DMA Buffer or Alternate CCW
Zero or More PIO Words to Write to the Associated Peripheral Starting at its Base Address on the APBH Bus
Figure 15-2 also shows the CHAIN bit in bit 2 of the second word of the command
structure. This bit is set to 1, if the NEXT_COMMAND_ADDRESS contains a pointer to
another DMA command structure. If a null pointer (0) is loaded into the
NEXT_COMMAND_ADDRESS, it is not detected by the DMA hardware. Only the
CHAIN bit indicates whether a valid list exists beyond the current structure.
If the IRQ_COMPLETE bit is set in the command structure, then the last act of the DMA
before loading the next command is to set the interrupt-status bit corresponding to the
current channel. The sticky interrupt request bit in the DMA CSR remains set until
cleared by the software. It can be used to interrupt the Arm platform.
The NAND_LOCK bit is monitored by the DMA channel arbiter. Once a NAND channel
(from channel 0 to channel 3) succeeds in the arbiter with its NAND_LOCK bit set, then
the arbiter ignores the other NAND channels until a command is completed in which the
NAND_LOCK is not set. Notice that the semantic here is that the NAND_LOCK state is
to limit scheduling of a non-locked DMA. A DMA channel can go from unlocked to
locked in the arbiter at the beginning of a command when the NAND_LOCK bit is set.
When the last DMA command of an atomic sequence is completed, the lock should be
removed. To accomplish this, the last command does not have the NAND_LOCK bit. It
is still locked in the atomic state within the arbiter when the command starts, so that it is
the only NAND command that can be executed. At the end, it drops from the atomic state
within the arbiter.
The NAND_WAIT4READY bit also has a special use for GPMI channels (from channel
0 to channel 3), i.e., the NAND device channels. The GPMI peripheral supplies a sample
of the ready line from the NAND device. This ready value is used to hold off of a
command with this bit set until the ready line is asserted to 1. Once the arbiter sees a
command with a wait-for-ready set, it holds off that channel until ready is asserted.
APBH DMA
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
470
NXP Semiconductors

<!-- page 471 -->

Receiving an IRQ for HALTONTERMINATE (HOT) is a feature in the APBH DMA
descriptor that allows GPMI to signal to the DMA engine that an error has occurred. If a
command is stalled due to an error, a HOT signal is sent from the peripheral to the DMA
engine and causes an IRQ after terminating the DMA descriptor being executed.
Therefore, it is recommended that software use this signal as follows:
• Always set HALTONTERMINATE to 1 in a DMA descriptor. That way, if a
peripheral signals HOT, the transfer will end, leaving the peripheral block and the
DMA engine synchronized (but at the end of a command).
• When an IRQ from an APBH channel is received, and the IRQ is determined to be
due to an error (as opposed to an IRQONCOMPLETE interrupt) the software should:
• Reset the channel.
• Determine the error from error reporting in the peripheral block, then manage the
error in the peripheral that is attached to that channel in whatever appropriate
way exists for that device (software recovery, device reset, block reset, etc).
Each channel has an eight-bit counting semaphore that controls whether it is in the idle
state. When the semaphore is non-zero, the channel is ready to run, process commands
and perform DMA transfers. Whenever a command finishes its DMA transfer, it checks
the DECREMENT_SEMAPHORE bit. If set, it decrements the counting semaphore. If
the semaphore goes to 0 as a result, then the channel enters the idle state and remains
there until the semaphore is incremented by the software. When the semaphore goes to
non-zero and the channel is in its idle state, then it uses the value in the
APBH_CHn_NXTCMDAR register (next command address register) to fetch a pointer to
the next command to process.
NOTE
This is a double indirect case. This method allows the software
to append to a running command list under the protection of the
counting semaphore.
To start processing the first time, software creates the command list to be processed. It
writes the address of the first command into the APBH_CHn_NXTCMDAR register, and
then writes 1 to the counting semaphore in APBH_CHn_SEMA. The DMA channel loads
APBH_CHn_CURCMDAR register and then enters the normal state machine processing
for the next command. When the software writes a value to the counting semaphore, it is
added to the semaphore count by hardware, protecting the case where both hardware and
software are trying to change the semaphore on the same clock edge.
Software can examine the value of APBH_CHn_CURCMDAR at any time to determine
the location of the command structure currently being processed.
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
471

<!-- page 472 -->

15.4
NAND Read Status Polling Example
The following figure shows a more complicated scenario.
This subset of a NAND device workload shows that the first two command structures are
used during the data-write phase of an NAND device write operation (CLE and ALE
transfers omitted for clarity).
• After writing the data, one must wait until the NAND device status register indicates
that the write charge has been transferred. This is built into the workload using a
check status command in the NAND in a loop created from the next two DMA
command structures.
• The NO_DMA_TRANSFER command is shown here performing the read check,
followed by a DMA_SENSE command to branch the DMA command structure list,
based on the status of a bit in the external NAND device.
NAND Read Status Polling Example
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
472
NXP Semiconductors

<!-- page 473 -->

512
BUFFER ADDRESS
NEXTCMD_ADDR
16
BUFFER ADDRESS
NEXTCMD_ADDR
0
BUFFER ADDRESS
512-Byte
Data
Block
16-Byte
Spare
Area
1
0
1
10
0
No PIO, chaining
DMA read
1
0
0
10
0
1
0
1
00
0
No PIO,IRQ,
no chaining,
DMA read
0
0
0
10
1
NEXTCMD_ADDR
0
BUFFER ADDRESS
No PIO, chaining, no DMA,
conditional branch based
on sense line
1
0
0
11
0
NEXTCMD_ADDR
512
BUFFER ADDRESS
NAND0=write mode
NEXTCMD_ADDR=0
16
BUFFER ADDRESS
Data
Block
Spare
Area
1
0
1
10
0
1 PIO, chaining, DMA read
NEXTCMD_ADDR
NAND0=write mode
1 PIO, chaining, no DMA, Check
NAND status & set sense line
NAND0= check status
1 PIO, chaining, DMA read
512-Byte
16-Byte
Figure 15-3. AHB-to-APBH Bridge DMA NAND Read Status Polling with DMA Sense
Command
The example in the above figure shows the workload continuing immediately to the next
NAND page transfer. However, one could perform a second sense operation to see if an
error has occurred after the write. One could then point the sense command alternate
branch at a NO_DMA_XFER command with the interrupt bit set. If the CHAIN bit is not
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
473

<!-- page 474 -->

set on this failure branch, then the Arm platform is interrupted immediately, and the
channel process is also immediately terminated in the presence of a workload-detected
NAND error bit.
Note that each word of the three-word DMA command structure corresponds to a PIO
register of the DMA that is accessible on the APBH bus. Normally, the DMA copies the
next command structure onto these registers for processing at the start of each command
by following the value of the pointer previously loaded into the NEXTCMD_ADDR
register.
To start DMA processing for the first command, initialize the PIO registers of the desired
channel, as follows:
• First, load the next command address register with a pointer to the first command to
be loaded.
• Then, write 1 to the counting semaphore register. This causes the DMA to schedule
the targeted channel for the DMA command structure load, just as if it had finished
its previous command.
15.5
APBH Memory Map/Register Definition
APBH Hardware Register Format Summary
APBH memory map
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
180_4000
AHB to APBH Bridge Control and Status Register 0
(APBH_CTRL0)
32
R/W
E000_0000h
15.5.1/480
180_4004
AHB to APBH Bridge Control and Status Register 0
(APBH_CTRL0_SET)
32
R/W
E000_0000h
15.5.1/480
180_4008
AHB to APBH Bridge Control and Status Register 0
(APBH_CTRL0_CLR)
32
R/W
E000_0000h
15.5.1/480
180_400C
AHB to APBH Bridge Control and Status Register 0
(APBH_CTRL0_TOG)
32
R/W
E000_0000h
15.5.1/480
180_4010
AHB to APBH Bridge Control and Status Register 1
(APBH_CTRL1)
32
R/W
0000_0000h
15.5.2/481
180_4014
AHB to APBH Bridge Control and Status Register 1
(APBH_CTRL1_SET)
32
R/W
0000_0000h
15.5.2/481
180_4018
AHB to APBH Bridge Control and Status Register 1
(APBH_CTRL1_CLR)
32
R/W
0000_0000h
15.5.2/481
Table continues on the next page...
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
474
NXP Semiconductors

<!-- page 475 -->

APBH memory map (continued)
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
180_401C
AHB to APBH Bridge Control and Status Register 1
(APBH_CTRL1_TOG)
32
R/W
0000_0000h
15.5.2/481
180_4020
AHB to APBH Bridge Control and Status Register 2
(APBH_CTRL2)
32
R/W
0000_0000h
15.5.3/485
180_4024
AHB to APBH Bridge Control and Status Register 2
(APBH_CTRL2_SET)
32
R/W
0000_0000h
15.5.3/485
180_4028
AHB to APBH Bridge Control and Status Register 2
(APBH_CTRL2_CLR)
32
R/W
0000_0000h
15.5.3/485
180_402C
AHB to APBH Bridge Control and Status Register 2
(APBH_CTRL2_TOG)
32
R/W
0000_0000h
15.5.3/485
180_4030
AHB to APBH Bridge Channel Register
(APBH_CHANNEL_CTRL)
32
R/W
0000_0000h
15.5.4/490
180_4034
AHB to APBH Bridge Channel Register
(APBH_CHANNEL_CTRL_SET)
32
R/W
0000_0000h
15.5.4/490
180_4038
AHB to APBH Bridge Channel Register
(APBH_CHANNEL_CTRL_CLR)
32
R/W
0000_0000h
15.5.4/490
180_403C
AHB to APBH Bridge Channel Register
(APBH_CHANNEL_CTRL_TOG)
32
R/W
0000_0000h
15.5.4/490
180_4040
AHB to APBH DMA Device Assignment Register
(APBH_DEVSEL)
32
R/W
0000_0000h
15.5.5/491
180_4050
AHB to APBH DMA burst size (APBH_DMA_BURST_SIZE)
32
R/W
0055_5555h
15.5.6/492
180_4060
AHB to APBH DMA Debug Register (APBH_DEBUG)
32
R/W
0000_0000h
15.5.7/493
180_4100
APBH DMA Channel n Current Command Address Register
(APBH_CH0_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_4110
APBH DMA Channel n Next Command Address Register
(APBH_CH0_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_4120
APBH DMA Channel n Command Register
(APBH_CH0_CMD)
32
R/W
0000_0000h
15.5.10/495
180_4130
APBH DMA Channel n Buffer Address Register
(APBH_CH0_BAR)
32
R/W
0000_0000h
15.5.11/497
180_4140
APBH DMA Channel n Semaphore Register
(APBH_CH0_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_4150
AHB to APBH DMA Channel n Debug Information
(APBH_CH0_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_4160
AHB to APBH DMA Channel n Debug Information
(APBH_CH0_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_4170
APBH DMA Channel n Current Command Address Register
(APBH_CH1_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_4180
APBH DMA Channel n Next Command Address Register
(APBH_CH1_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_4190
APBH DMA Channel n Command Register
(APBH_CH1_CMD)
32
R/W
0000_0000h
15.5.10/495
180_41A0
APBH DMA Channel n Buffer Address Register
(APBH_CH1_BAR)
32
R/W
0000_0000h
15.5.11/497
Table continues on the next page...
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
475

<!-- page 476 -->

APBH memory map (continued)
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
180_41B0
APBH DMA Channel n Semaphore Register
(APBH_CH1_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_41C0
AHB to APBH DMA Channel n Debug Information
(APBH_CH1_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_41D0
AHB to APBH DMA Channel n Debug Information
(APBH_CH1_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_41E0
APBH DMA Channel n Current Command Address Register
(APBH_CH2_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_41F0
APBH DMA Channel n Next Command Address Register
(APBH_CH2_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_4200
APBH DMA Channel n Command Register
(APBH_CH2_CMD)
32
R/W
0000_0000h
15.5.10/495
180_4210
APBH DMA Channel n Buffer Address Register
(APBH_CH2_BAR)
32
R/W
0000_0000h
15.5.11/497
180_4220
APBH DMA Channel n Semaphore Register
(APBH_CH2_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_4230
AHB to APBH DMA Channel n Debug Information
(APBH_CH2_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_4240
AHB to APBH DMA Channel n Debug Information
(APBH_CH2_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_4250
APBH DMA Channel n Current Command Address Register
(APBH_CH3_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_4260
APBH DMA Channel n Next Command Address Register
(APBH_CH3_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_4270
APBH DMA Channel n Command Register
(APBH_CH3_CMD)
32
R/W
0000_0000h
15.5.10/495
180_4280
APBH DMA Channel n Buffer Address Register
(APBH_CH3_BAR)
32
R/W
0000_0000h
15.5.11/497
180_4290
APBH DMA Channel n Semaphore Register
(APBH_CH3_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_42A0
AHB to APBH DMA Channel n Debug Information
(APBH_CH3_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_42B0
AHB to APBH DMA Channel n Debug Information
(APBH_CH3_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_42C0
APBH DMA Channel n Current Command Address Register
(APBH_CH4_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_42D0
APBH DMA Channel n Next Command Address Register
(APBH_CH4_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_42E0
APBH DMA Channel n Command Register
(APBH_CH4_CMD)
32
R/W
0000_0000h
15.5.10/495
180_42F0
APBH DMA Channel n Buffer Address Register
(APBH_CH4_BAR)
32
R/W
0000_0000h
15.5.11/497
180_4300
APBH DMA Channel n Semaphore Register
(APBH_CH4_SEMA)
32
R/W
0000_0000h
15.5.12/498
Table continues on the next page...
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
476
NXP Semiconductors

<!-- page 477 -->

APBH memory map (continued)
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
180_4310
AHB to APBH DMA Channel n Debug Information
(APBH_CH4_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_4320
AHB to APBH DMA Channel n Debug Information
(APBH_CH4_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_4330
APBH DMA Channel n Current Command Address Register
(APBH_CH5_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_4340
APBH DMA Channel n Next Command Address Register
(APBH_CH5_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_4350
APBH DMA Channel n Command Register
(APBH_CH5_CMD)
32
R/W
0000_0000h
15.5.10/495
180_4360
APBH DMA Channel n Buffer Address Register
(APBH_CH5_BAR)
32
R/W
0000_0000h
15.5.11/497
180_4370
APBH DMA Channel n Semaphore Register
(APBH_CH5_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_4380
AHB to APBH DMA Channel n Debug Information
(APBH_CH5_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_4390
AHB to APBH DMA Channel n Debug Information
(APBH_CH5_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_43A0
APBH DMA Channel n Current Command Address Register
(APBH_CH6_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_43B0
APBH DMA Channel n Next Command Address Register
(APBH_CH6_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_43C0
APBH DMA Channel n Command Register
(APBH_CH6_CMD)
32
R/W
0000_0000h
15.5.10/495
180_43D0
APBH DMA Channel n Buffer Address Register
(APBH_CH6_BAR)
32
R/W
0000_0000h
15.5.11/497
180_43E0
APBH DMA Channel n Semaphore Register
(APBH_CH6_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_43F0
AHB to APBH DMA Channel n Debug Information
(APBH_CH6_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_4400
AHB to APBH DMA Channel n Debug Information
(APBH_CH6_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_4410
APBH DMA Channel n Current Command Address Register
(APBH_CH7_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_4420
APBH DMA Channel n Next Command Address Register
(APBH_CH7_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_4430
APBH DMA Channel n Command Register
(APBH_CH7_CMD)
32
R/W
0000_0000h
15.5.10/495
180_4440
APBH DMA Channel n Buffer Address Register
(APBH_CH7_BAR)
32
R/W
0000_0000h
15.5.11/497
180_4450
APBH DMA Channel n Semaphore Register
(APBH_CH7_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_4460
AHB to APBH DMA Channel n Debug Information
(APBH_CH7_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
Table continues on the next page...
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
477

<!-- page 478 -->

APBH memory map (continued)
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
180_4470
AHB to APBH DMA Channel n Debug Information
(APBH_CH7_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_4480
APBH DMA Channel n Current Command Address Register
(APBH_CH8_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_4490
APBH DMA Channel n Next Command Address Register
(APBH_CH8_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_44A0
APBH DMA Channel n Command Register
(APBH_CH8_CMD)
32
R/W
0000_0000h
15.5.10/495
180_44B0
APBH DMA Channel n Buffer Address Register
(APBH_CH8_BAR)
32
R/W
0000_0000h
15.5.11/497
180_44C0
APBH DMA Channel n Semaphore Register
(APBH_CH8_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_44D0
AHB to APBH DMA Channel n Debug Information
(APBH_CH8_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_44E0
AHB to APBH DMA Channel n Debug Information
(APBH_CH8_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_44F0
APBH DMA Channel n Current Command Address Register
(APBH_CH9_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_4500
APBH DMA Channel n Next Command Address Register
(APBH_CH9_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_4510
APBH DMA Channel n Command Register
(APBH_CH9_CMD)
32
R/W
0000_0000h
15.5.10/495
180_4520
APBH DMA Channel n Buffer Address Register
(APBH_CH9_BAR)
32
R/W
0000_0000h
15.5.11/497
180_4530
APBH DMA Channel n Semaphore Register
(APBH_CH9_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_4540
AHB to APBH DMA Channel n Debug Information
(APBH_CH9_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_4550
AHB to APBH DMA Channel n Debug Information
(APBH_CH9_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_4560
APBH DMA Channel n Current Command Address Register
(APBH_CH10_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_4570
APBH DMA Channel n Next Command Address Register
(APBH_CH10_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_4580
APBH DMA Channel n Command Register
(APBH_CH10_CMD)
32
R/W
0000_0000h
15.5.10/495
180_4590
APBH DMA Channel n Buffer Address Register
(APBH_CH10_BAR)
32
R/W
0000_0000h
15.5.11/497
180_45A0
APBH DMA Channel n Semaphore Register
(APBH_CH10_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_45B0
AHB to APBH DMA Channel n Debug Information
(APBH_CH10_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_45C0
AHB to APBH DMA Channel n Debug Information
(APBH_CH10_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
Table continues on the next page...
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
478
NXP Semiconductors

<!-- page 479 -->

APBH memory map (continued)
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
180_45D0
APBH DMA Channel n Current Command Address Register
(APBH_CH11_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_45E0
APBH DMA Channel n Next Command Address Register
(APBH_CH11_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_45F0
APBH DMA Channel n Command Register
(APBH_CH11_CMD)
32
R/W
0000_0000h
15.5.10/495
180_4600
APBH DMA Channel n Buffer Address Register
(APBH_CH11_BAR)
32
R/W
0000_0000h
15.5.11/497
180_4610
APBH DMA Channel n Semaphore Register
(APBH_CH11_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_4620
AHB to APBH DMA Channel n Debug Information
(APBH_CH11_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_4630
AHB to APBH DMA Channel n Debug Information
(APBH_CH11_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_4640
APBH DMA Channel n Current Command Address Register
(APBH_CH12_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_4650
APBH DMA Channel n Next Command Address Register
(APBH_CH12_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_4660
APBH DMA Channel n Command Register
(APBH_CH12_CMD)
32
R/W
0000_0000h
15.5.10/495
180_4670
APBH DMA Channel n Buffer Address Register
(APBH_CH12_BAR)
32
R/W
0000_0000h
15.5.11/497
180_4680
APBH DMA Channel n Semaphore Register
(APBH_CH12_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_4690
AHB to APBH DMA Channel n Debug Information
(APBH_CH12_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_46A0
AHB to APBH DMA Channel n Debug Information
(APBH_CH12_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_46B0
APBH DMA Channel n Current Command Address Register
(APBH_CH13_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_46C0
APBH DMA Channel n Next Command Address Register
(APBH_CH13_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_46D0
APBH DMA Channel n Command Register
(APBH_CH13_CMD)
32
R/W
0000_0000h
15.5.10/495
180_46E0
APBH DMA Channel n Buffer Address Register
(APBH_CH13_BAR)
32
R/W
0000_0000h
15.5.11/497
180_46F0
APBH DMA Channel n Semaphore Register
(APBH_CH13_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_4700
AHB to APBH DMA Channel n Debug Information
(APBH_CH13_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_4710
AHB to APBH DMA Channel n Debug Information
(APBH_CH13_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_4720
APBH DMA Channel n Current Command Address Register
(APBH_CH14_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
Table continues on the next page...
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
479

<!-- page 480 -->

APBH memory map (continued)
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
180_4730
APBH DMA Channel n Next Command Address Register
(APBH_CH14_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_4740
APBH DMA Channel n Command Register
(APBH_CH14_CMD)
32
R/W
0000_0000h
15.5.10/495
180_4750
APBH DMA Channel n Buffer Address Register
(APBH_CH14_BAR)
32
R/W
0000_0000h
15.5.11/497
180_4760
APBH DMA Channel n Semaphore Register
(APBH_CH14_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_4770
AHB to APBH DMA Channel n Debug Information
(APBH_CH14_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_4780
AHB to APBH DMA Channel n Debug Information
(APBH_CH14_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_4790
APBH DMA Channel n Current Command Address Register
(APBH_CH15_CURCMDAR)
32
R/W
0000_0000h
15.5.8/494
180_47A0
APBH DMA Channel n Next Command Address Register
(APBH_CH15_NXTCMDAR)
32
R/W
0000_0000h
15.5.9/495
180_47B0
APBH DMA Channel n Command Register
(APBH_CH15_CMD)
32
R/W
0000_0000h
15.5.10/495
180_47C0
APBH DMA Channel n Buffer Address Register
(APBH_CH15_BAR)
32
R/W
0000_0000h
15.5.11/497
180_47D0
APBH DMA Channel n Semaphore Register
(APBH_CH15_SEMA)
32
R/W
0000_0000h
15.5.12/498
180_47E0
AHB to APBH DMA Channel n Debug Information
(APBH_CH15_DEBUG1)
32
R/W
00A0_0000h
15.5.13/499
180_47F0
AHB to APBH DMA Channel n Debug Information
(APBH_CH15_DEBUG2)
32
R/W
0000_0000h
15.5.14/502
180_4800
APBH Bridge Version Register (APBH_VERSION)
32
R/W
0301_0000h
15.5.15/503
15.5.1
AHB to APBH Bridge Control and Status Register 0
(APBH_CTRL0n)
The APBH CTRL 0 provides overall control of the AHB to APBH bridge and DMA.
This register contains module softreset, clock gating, channel clock gating/freeze bits.
Address: 180_4000h base + 0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
AHB_BURST8_
EN
APB_BURST_EN
Reserved
W
Reset
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
0
0
0
0
0
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
480
NXP Semiconductors

<!-- page 481 -->

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
CLKGATE_CHANNEL
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
APBH_CTRL0n field descriptions
Field
Description
31
SFTRST
Set this bit to zero to enable normal APBH DMA operation. Set this bit to one (default) to disable clocking
with the APBH DMA and hold it in its reset (lowest power) state. This bit can be turned on and then off to
reset the APBH DMA block to its default state.
30
CLKGATE
This bit must be set to zero for normal operation. When set to one it gates off the clocks to the block.
29
AHB_BURST8_
EN
Set this bit to one (default) to enable AHB 8-beat burst. Set to zero to disable 8-beat burst on AHB
interface.
28
APB_BURST_EN
Set this bit to one to enable apb master do a continous transfers when a device request a burst dma. Set
to zero will treat a burst dma request as 4/8 individual requests.
27–16
RSVD0
This field is reserved.
Reserved, always set to zero.
CLKGATE_
CHANNEL
These bits must be set to zero for normal operation of each channel. When set to one they gate off the
individual clocks to the channels.
0x0001
NAND0 —
0x0002
NAND1 —
0x0004
NAND2 —
0x0008
NAND3 —
0x0010
NAND4 —
0x0020
NAND5 —
0x0040
NAND6 —
0x0080
NAND7 —
0x0100
SSP —
15.5.2
AHB to APBH Bridge Control and Status Register 1
(APBH_CTRL1n)
The APBH CTRL one provides overall control of the interrupts generated by the AHB to
APBH DMA. This register contains the per channel interrupt status bits and the per
channel interrupt enable bits. Each channel has a dedicated interrupt vector in the
vectored interrupt controller.
EXAMPLE
                     BF_WR(APBH_CTRL1, CH5_CMDCMPLT_IRQ, 0);  // use bitfield write macro
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
481

<!-- page 482 -->

                     BF_APBH_CTRL1.CH5_CMDCMPLT_IRQ = 0;      // or, assign to register 
struct's bitfield
         
Address: 180_4000h base + 10h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
CH15_
CMDCMPLT_IRQ_
EN
CH14_
CMDCMPLT_IRQ_
EN
CH13_
CMDCMPLT_IRQ_
EN
CH12_
CMDCMPLT_IRQ_
EN
CH11_
CMDCMPLT_IRQ_
EN
CH10_
CMDCMPLT_IRQ_
EN
CH9_CMDCMPLT_
IRQ_EN
CH8_CMDCMPLT_
IRQ_EN
CH7_CMDCMPLT_
IRQ_EN
CH6_CMDCMPLT_
IRQ_EN
CH5_CMDCMPLT_
IRQ_EN
CH4_CMDCMPLT_
IRQ_EN
CH3_CMDCMPLT_
IRQ_EN
CH2_CMDCMPLT_
IRQ_EN
CH1_CMDCMPLT_
IRQ_EN
CH0_CMDCMPLT_
IRQ_EN
W
Reset
0
0
0
0
0
0
0
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
CH15_
CMDCMPLT_IRQ
CH14_
CMDCMPLT_IRQ
CH13_
CMDCMPLT_IRQ
CH12_
CMDCMPLT_IRQ
CH11_
CMDCMPLT_IRQ
CH10_
CMDCMPLT_IRQ
CH9_CMDCMPLT_
IRQ
CH8_CMDCMPLT_
IRQ
CH7_CMDCMPLT_
IRQ
CH6_CMDCMPLT_
IRQ
CH5_CMDCMPLT_
IRQ
CH4_CMDCMPLT_
IRQ
CH3_CMDCMPLT_
IRQ
CH2_CMDCMPLT_
IRQ
CH1_CMDCMPLT_
IRQ
CH0_CMDCMPLT_
IRQ
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
APBH_CTRL1n field descriptions
Field
Description
31
CH15_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 15.
30
CH14_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 14.
29
CH13_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 13.
28
CH12_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 12.
27
CH11_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 11.
26
CH10_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 10.
Table continues on the next page...
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
482
NXP Semiconductors

<!-- page 483 -->

APBH_CTRL1n field descriptions (continued)
Field
Description
25
CH9_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 9.
24
CH8_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 8.
23
CH7_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 7.
22
CH6_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 6.
21
CH5_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 5.
20
CH4_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 4.
19
CH3_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 3.
18
CH2_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 2.
17
CH1_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 1.
16
CH0_
CMDCMPLT_
IRQ_EN
Setting this bit enables the generation of an interrupt request for APBH DMA channel 0.
15
CH15_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA Channel 15. This sticky bit is set by DMA hardware and reset
by software. It is ANDed with its corresponding enable bit to generate an interrupt.
14
CH14_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA Channel 14. This sticky bit is set by DMA hardware and reset
by software. It is ANDed with its corresponding enable bit to generate an interrupt.
Table continues on the next page...
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
483

<!-- page 484 -->

APBH_CTRL1n field descriptions (continued)
Field
Description
13
CH13_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA Channel 13. This sticky bit is set by DMA hardware and reset
by software. It is ANDed with its corresponding enable bit to generate an interrupt.
12
CH12_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA Channel 12. This sticky bit is set by DMA hardware and reset
by software. It is ANDed with its corresponding enable bit to generate an interrupt.
11
CH11_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA Channel 11. This sticky bit is set by DMA hardware and reset
by software. It is ANDed with its corresponding enable bit to generate an interrupt.
10
CH10_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA Channel 10. This sticky bit is set by DMA hardware and reset
by software. It is ANDed with its corresponding enable bit to generate an interrupt.
9
CH9_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA Channel 9. This sticky bit is set by DMA hardware and reset by
software. It is ANDed with its corresponding enable bit to generate an interrupt.
8
CH8_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA Channel 8. This sticky bit is set by DMA hardware and reset by
software. It is ANDed with its corresponding enable bit to generate an interrupt.
7
CH7_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA channel 7. This sticky bit is set by DMA hardware and reset by
software. It is ANDed with its corresponding enable bit to generate an interrupt.
6
CH6_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA channel 6. This sticky bit is set by DMA hardware and reset by
software. It is ANDed with its corresponding enable bit to generate an interrupt.
5
CH5_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA channel 5. This sticky bit is set by DMA hardware and reset by
software. It is ANDed with its corresponding enable bit to generate an interrupt.
4
CH4_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA channel 4. This sticky bit is set by DMA hardware and reset by
software. It is ANDed with its corresponding enable bit to generate an interrupt.
3
CH3_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA channel 3. This sticky bit is set by DMA hardware and reset by
software. It is ANDed with its corresponding enable bit to generate an interrupt.
2
CH2_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA channel 2. This sticky bit is set by DMA hardware and reset by
software. It is ANDed with its corresponding enable bit to generate an interrupt.
Table continues on the next page...
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
484
NXP Semiconductors

<!-- page 485 -->

APBH_CTRL1n field descriptions (continued)
Field
Description
1
CH1_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA channel 1. This sticky bit is set by DMA hardware and reset by
software. It is ANDed with its corresponding enable bit to generate an interrupt.
0
CH0_
CMDCMPLT_
IRQ
Interrupt request status bit for APBH DMA channel 0. This sticky bit is set by DMA hardware and reset by
software. It is ANDed with its corresponding enable bit to generate an interrupt.
15.5.3
AHB to APBH Bridge Control and Status Register 2
(APBH_CTRL2n)
The APBH CTRL 2 provides channel error interrupts generated by the AHB to APBH
DMA. This register contains the per channel interrupt status bits and the per channel
interrupt enable bits. Each channel has a dedicated interrupt vector in the vectored
interrupt controller.
EXAMPLE
                     BF_WR(APBH_CTRL1, CH5_CMDCMPLT_IRQ, 0);  // use bitfield write macro
                     BF_APBH_CTRL1.CH5_CMDCMPLT_IRQ = 0;      // or, assign to register 
struct's bitfield
                  
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
485

<!-- page 486 -->

Address: 180_4000h base + 20h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
CH15_ERROR_STATUS
CH14_ERROR_STATUS
CH13_ERROR_STATUS
CH12_ERROR_STATUS
CH11_ERROR_STATUS
CH10_ERROR_STATUS
CH9_ERROR_STATUS
CH8_ERROR_STATUS
CH7_ERROR_STATUS
CH6_ERROR_STATUS
CH5_ERROR_STATUS
CH4_ERROR_STATUS
CH3_ERROR_STATUS
CH2_ERROR_STATUS
CH1_ERROR_STATUS
CH0_ERROR_STATUS
W
Reset
0
0
0
0
0
0
0
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
CH15_ERROR_IRQ
CH14_ERROR_IRQ
CH13_ERROR_IRQ
CH12_ERROR_IRQ
CH11_ERROR_IRQ
CH10_ERROR_IRQ
CH9_ERROR_IRQ
CH8_ERROR_IRQ
CH7_ERROR_IRQ
CH6_ERROR_IRQ
CH5_ERROR_IRQ
CH4_ERROR_IRQ
CH3_ERROR_IRQ
CH2_ERROR_IRQ
CH1_ERROR_IRQ
CH0_ERROR_IRQ
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
APBH_CTRL2n field descriptions
Field
Description
31
CH15_ERROR_
STATUS
Error status bit for APBH DMA Channel 15. Valid when corresponding Error IRQ is set.
1 - AHB bus error
Table continues on the next page...
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
486
NXP Semiconductors

<!-- page 487 -->

APBH_CTRL2n field descriptions (continued)
Field
Description
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
30
CH14_ERROR_
STATUS
Error status bit for APBH DMA Channel 14. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
29
CH13_ERROR_
STATUS
Error status bit for APBH DMA Channel 13. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
28
CH12_ERROR_
STATUS
Error status bit for APBH DMA Channel 12. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
27
CH11_ERROR_
STATUS
Error status bit for APBH DMA Channel 11. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
26
CH10_ERROR_
STATUS
Error status bit for APBH DMA Channel 10. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
25
CH9_ERROR_
STATUS
Error status bit for APBH DMA Channel 9. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
24
CH8_ERROR_
STATUS
Error status bit for APBH DMA Channel 8. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
Table continues on the next page...
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
487

<!-- page 488 -->

APBH_CTRL2n field descriptions (continued)
Field
Description
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
23
CH7_ERROR_
STATUS
Error status bit for APBX DMA Channel 7. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
22
CH6_ERROR_
STATUS
Error status bit for APBX DMA Channel 6. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
21
CH5_ERROR_
STATUS
Error status bit for APBX DMA Channel 5. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
20
CH4_ERROR_
STATUS
Error status bit for APBX DMA Channel 4. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
19
CH3_ERROR_
STATUS
Error status bit for APBX DMA Channel 3. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
18
CH2_ERROR_
STATUS
Error status bit for APBX DMA Channel 2. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
17
CH1_ERROR_
STATUS
Error status bit for APBX DMA Channel 1. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
Table continues on the next page...
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
488
NXP Semiconductors

<!-- page 489 -->

APBH_CTRL2n field descriptions (continued)
Field
Description
16
CH0_ERROR_
STATUS
Error status bit for APBX DMA Channel 0. Valid when corresponding Error IRQ is set.
1 - AHB bus error
0 - channel early termination.
0x0
TERMINATION — An early termination from the device causes error IRQ.
0x1
BUS_ERROR — An AHB bus error causes error IRQ.
15
CH15_ERROR_
IRQ
Error interrupt status bit for APBH DMA Channel 15. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
14
CH14_ERROR_
IRQ
Error interrupt status bit for APBH DMA Channel 14. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
13
CH13_ERROR_
IRQ
Error interrupt status bit for APBH DMA Channel 13. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
12
CH12_ERROR_
IRQ
Error interrupt status bit for APBH DMA Channel 12. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
11
CH11_ERROR_
IRQ
Error interrupt status bit for APBH DMA Channel 11. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
10
CH10_ERROR_
IRQ
Error interrupt status bit for APBH DMA Channel 10. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
9
CH9_ERROR_
IRQ
Error interrupt status bit for APBH DMA Channel 9. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
8
CH8_ERROR_
IRQ
Error interrupt status bit for APBH DMA Channel 8. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
7
CH7_ERROR_
IRQ
Error interrupt status bit for APBX DMA Channel 7. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
6
CH6_ERROR_
IRQ
Error interrupt status bit for APBX DMA Channel 6. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
5
CH5_ERROR_
IRQ
Error interrupt status bit for APBX DMA Channel 5. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
4
CH4_ERROR_
IRQ
Error interrupt status bit for APBX DMA Channel 4. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
3
CH3_ERROR_
IRQ
Error interrupt status bit for APBX DMA Channel 3. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
2
CH2_ERROR_
IRQ
Error interrupt status bit for APBX DMA Channel 2. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
Table continues on the next page...
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
489

<!-- page 490 -->

APBH_CTRL2n field descriptions (continued)
Field
Description
1
CH1_ERROR_
IRQ
Error interrupt status bit for APBX DMA Channel 1. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
0
CH0_ERROR_
IRQ
Error interrupt status bit for APBX DMA Channel 0. This sticky bit is set by DMA hardware and reset by
software. It is ORed with the corresponding cmdcmplt irq to generate an irq to Arm.
15.5.4
AHB to APBH Bridge Channel Register
(APBH_CHANNEL_CTRLn)
The APBH CHANNEL CTRL provides reset/freeze control of each DMA channel. This
register contains individual channel reset/freeze bits.
Address: 180_4000h base + 30h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
RESET_CHANNEL
FREEZE_CHANNEL
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
APBH_CHANNEL_CTRLn field descriptions
Field
Description
31–16
RESET_
CHANNEL
Setting a bit in this field causes the DMA controller to take the corresponding channel through its reset
state. The bit is reset after the channel resources are cleared.
0x0001
NAND0 —
0x0002
NAND1 —
0x0004
NAND2 —
0x0008
NAND3 —
0x0010
NAND4 —
0x0020
NAND5 —
0x0040
NAND6 —
0x0080
NAND7 —
0x0100
SSP —
FREEZE_
CHANNEL
Setting a bit in this field will freeze the DMA channel associated with it. This field is a direct input to the
DMA channel arbiter. When frozen, the channel is deined access to the central DMA resources.
0x0001
NAND0 —
0x0002
NAND1 —
0x0004
NAND2 —
0x0008
NAND3 —
0x0010
NAND4 —
0x0020
NAND5 —
0x0040
NAND6 —
Table continues on the next page...
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
490
NXP Semiconductors

<!-- page 491 -->

APBH_CHANNEL_CTRLn field descriptions (continued)
Field
Description
0x0080
NAND7 —
0x0100
SSP —
15.5.5
AHB to APBH DMA Device Assignment Register
(APBH_DEVSEL)
This register allows reassignment of the APBH device connected to the DMA Channels.
In this chip, APBH DMA channel resource is enough for high speed peripherals, so this
register is of no use and reserved.
Address: 180_4000h base + 40h offset = 180_4040h
Bit
31
30
29
28
27
26
25
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
Reserved
Reserved
Reserved
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
Reserved
Reserved
Reserved
Reserved
Reserved
Reserved
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
APBH_DEVSEL field descriptions
Field
Description
31–30
CH15
This field is reserved.
Reserved.
29–28
CH14
This field is reserved.
Reserved.
27–26
CH13
This field is reserved.
Reserved.
25–24
CH12
This field is reserved.
Reserved.
23–22
CH11
This field is reserved.
Reserved.
21–20
CH10
This field is reserved.
Reserved.
19–18
CH9
This field is reserved.
Reserved.
17–16
CH8
This field is reserved.
Reserved.
15–14
CH7
This field is reserved.
Reserved.
13–12
CH6
This field is reserved.
Reserved.
Table continues on the next page...
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
491

<!-- page 492 -->

APBH_DEVSEL field descriptions (continued)
Field
Description
11–10
CH5
This field is reserved.
Reserved.
9–8
CH4
This field is reserved.
Reserved.
7–6
CH3
This field is reserved.
Reserved.
5–4
CH2
This field is reserved.
Reserved.
3–2
CH1
This field is reserved.
Reserved.
CH0
This field is reserved.
Reserved.
15.5.6
AHB to APBH DMA burst size (APBH_DMA_BURST_SIZE)
This register programs the apbh burst size of the APBH DMA devices when a DMA
burst request is issued.
This register provides a mechanism for assigning the device.
Address: 180_4000h base + 50h offset = 180_4050h
Bit
31
30
29
28
27
26
25
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
Reserved
Reserved
Reserved
Reserved
CH8
W
Reset
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
CH7
CH6
CH5
CH4
CH3
CH2
CH1
CH0
W
Reset
0
1
0
1
0
1
0
1
0
1
0
1
0
1
0
1
APBH_DMA_BURST_SIZE field descriptions
Field
Description
31–30
CH15
This field is reserved.
Reserved.
29–28
CH14
This field is reserved.
Reserved.
27–26
CH13
This field is reserved.
Reserved.
25–24
CH12
This field is reserved.
Reserved.
23–22
CH11
This field is reserved.
Reserved.
Table continues on the next page...
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
492
NXP Semiconductors

<!-- page 493 -->

APBH_DMA_BURST_SIZE field descriptions (continued)
Field
Description
21–20
CH10
This field is reserved.
Reserved.
19–18
CH9
This field is reserved.
Reserved.
17–16
CH8
DMA burst size for SSP.
0x0
BURST0 —
0x1
BURST4 —
0x2
BURST8 —
15–14
CH7
DMA burst size for GPMI channel 7. Do not change. GPMI only support burst size 4.
13–12
CH6
DMA burst size for GPMI channel 6. Do not change. GPMI only support burst size 4.
11–10
CH5
DMA burst size for GPMI channel 5. Do not change. GPMI only support burst size 4.
9–8
CH4
DMA burst size for GPMI channel 4. Do not change. GPMI only support burst size 4.
7–6
CH3
DMA burst size for GPMI channel 3. Do not change. GPMI only support burst size 4.
5–4
CH2
DMA burst size for GPMI channel 2. Do not change. GPMI only support burst size 4.
3–2
CH1
DMA burst size for GPMI channel 1. Do not change. GPMI only support burst size 4.
CH0
DMA burst size for GPMI channel 0. Do not change. GPMI only support burst size 4.
15.5.7
AHB to APBH DMA Debug Register (APBH_DEBUG)
This register is for debug purpose.
The debug register is for internal use only. Not recommend for customer useage.
Address: 180_4000h base + 60h offset = 180_4060h
Bit
31
30
29
28
27
26
25
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
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
493

<!-- page 494 -->

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
GPMI_ONE_
FIFO
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
APBH_DEBUG field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved, always set to zero.
0
GPMI_ONE_
FIFO
Set to 0ne and the 8 GPMI channels will share the DMA FIFO, and when set to zero, the 8 GPMI channels
will use its own DMA FIFO.
15.5.8
APBH DMA Channel n Current Command Address
Register (APBH_CHn_CURCMDAR)
The APBH DMA channel n current command address register points to the multiword
command that is currently being executed. Commands are threaded on the command
address.
APBH DMA Channel n is controlled by a variable sized command structure. This register
points to the command structure currently being executed.
EXAMPLE
pCurCmd = (apbh_chn_cmd_t *) APBH_CHn_CURCMDAR_RD(0);              // read the whole 
register, since there is only one field
pCurCmd = (apbh_chn_cmd_t *) BF_RDn(APBH_CHn_CURCMDAR, 0, CMD_ADDR);  // or, use multi-
register bitfield read macro
pCurCmd = (apbh_chn_cmd_t *) APBH_CHn_CURCMDAR(0).CMD_ADDR;        // or, assign from 
bitfield of indexed register's struct
         
Address: 180_4000h base + 100h offset + (112d × i), where i=0d to 15d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CMD_ADDR
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
APBH_CHn_CURCMDAR field descriptions
Field
Description
CMD_ADDR
Pointer to command structure currently being processed for channel n.
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
494
NXP Semiconductors

<!-- page 495 -->

15.5.9
APBH DMA Channel n Next Command Address Register
(APBH_CHn_NXTCMDAR)
The APBH DMA Channel n Next Command Address register contains the address of the
next multiword command to be executed. Commands are threaded on the command
address. Set CHAIN to 1 in the DMA command word to process command lists.
APBH DMA Channel n is controlled by a variable sized command structure. Software
loads this register with the address of the first command structure to process and
increments the Channel n semaphore to start processing. This register points to the next
command structure to be executed when the current command is completed.
EXAMPLE
APBH_CHn_NXTCMDAR_WR(0, (reg32_t) pCommandTwoStructure);         // write the entire 
register, since there is only one field
BF_WRn(APBH_CHn_NXTCMDAR, 0, (reg32_t) pCommandTwoStructure);       // or, use multi-
register bitfield write macro
APBH_CHn_NXTCMDAR(0).CMD_ADDR = (reg32_t) pCommandTwoStructure;  // or, assign to bitfield 
of indexed register's struct
         
Address: 180_4000h base + 110h offset + (112d × i), where i=0d to 15d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CMD_ADDR
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
APBH_CHn_NXTCMDAR field descriptions
Field
Description
CMD_ADDR
Pointer to next command structure for channel n.
15.5.10
APBH DMA Channel n Command Register
(APBH_CHn_CMD)
The APBH DMA Channel n command register specifies the DMA transaction to perform
for the current command chain item.
The command register controls the overall operation of each DMA command for this
channel. It includes the number of bytes to transfer to or from the device, the number of
APB PIO command words included with this command structure, whether to interrupt at
command completion, whether to chain an additional command to the end of this one and
whether this transfer is a read or write DMA transfer.
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
495

<!-- page 496 -->

EXAMPLE
apbh_chn_cmd_t  dma_cmd;
dma_cmd.XFER_COUNT = 512;                                // transfer 512 bytes
dma_cmd.COMMAND = BV_APBH_CHn_CMD_COMMAND__DMA_WRITE;  // transfer to system memory from 
peripheral device
dma_cmd.CHAIN = 1;                                     // chain an additional command 
structure on to the list
dma_cmd.IRQONCMPLT = 1;                                // generate an interrupt on 
completion of this command structure
         
Address: 180_4000h base + 120h offset + (112d × i), where i=0d to 15d
Bit
31
30
29
28
27
26
25
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
XFER_COUNT
W
Reset
0
0
0
0
0
0
0
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
CMDWORDS
Reserved
HALTONTERMINATE
WAIT4ENDCMD
SEMAPHORE
NANDWAIT4READY
NANDLOCK
IRQONCMPLT
CHAIN
COMMAND
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
496
NXP Semiconductors

<!-- page 497 -->

APBH_CHn_CMD field descriptions
Field
Description
31–16
XFER_COUNT
This field indicates the number of bytes to transfer to or from the appropriate PIO register in the
GPMI0 device. A value of 0 indicates a 64 KBytes transfer.
15–12
CMDWORDS
This field indicates the number of command words to send to the GPMI0, starting with the base PIO
address of the GPMI0 control register and incrementing from there. Zero means transfer NO
command words
11–9
-
This field is reserved.
Reserved, always set to zero.
8
HALTONTERMINATE
A value of one indicates that the channel will immeditately terminate the current descriptor and halt
the DMA channel if a terminate signal is set. A value of 0 will still cause an immediate terminate of
the channel if the terminate signal is set, but the channel will continue as if the count had been
exhausted, meaning it will honor IRQONCMPLT, CHAIN, SEMAPHORE, and WAIT4ENDCMD.
7
WAIT4ENDCMD
A value of one indicates that the channel will wait for the end of command signal to be sent from the
APBH device to the DMA before starting the next DMA command.
6
SEMAPHORE
A value of one indicates that the channel will decrement its semaphore at the completion of the
current command structure. If the semaphore decrements to zero, then this channel stalls until
software increments it again.
5
NANDWAIT4READY
A value of one indicates that the NAND DMA channel will will wait until the NAND device reports
"ready" before executing the command. It is ignored for non-NAND DMA channels.
4
NANDLOCK
A value of one indicates that the NAND DMA channel will remain "locked" in the arbiter at the
expense of other NAND DMA channels. It is ignored for non-NAND DMA channels.
3
IRQONCMPLT
A value of one indicates that the channel will cause the interrupt status bit to be set upon
completion of the current command, i.e. after the DMA transfer is complete.
2
CHAIN
A value of one indicates that another command is chained onto the end of the current command
structure. At the completion of the current command, this channel will follow the pointer in
APBH_CHn_CMDAR to find the next command.
COMMAND
This bitfield indicates the type of current command:
0x0
NO_DMA_XFER — Perform any requested PIO word transfers but terminate command
before any DMA transfer.
0x1
DMA_WRITE — Perform any requested PIO word transfers and then perform a DMA transfer
from the peripheral for the specified number of bytes.
0x2
DMA_READ — Perform any requested PIO word transfers and then perform a DMA transfer
to the peripheral for the specified number of bytes.
0x3
DMA_SENSE — Perform any requested PIO word transfers and then perform a conditional
branch to the next chained device. Follow the NEXCMD_ADDR pointer if the perpheral sense
is true. Follow the BUFFER_ADDRESS as a chain pointer if the peripheral sense line is false.
15.5.11
APBH DMA Channel n Buffer Address Register
(APBH_CHn_BAR)
The APBH DMA Channel n buffer address register contains a pointer to the data buffer
for the transfer. For immediate forms, the data is taken from this register. This is a byte
address which means transfers can start on any byte boundary.
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
497

<!-- page 498 -->

This register holds a pointer to the data buffer in system memory. After the command
values have been read into the DMA controller and the device controlled by this channel,
then the DMA transfer will begin, to or from the buffer pointed to by this register.
EXAMPLE
apbh_chn_bar_t  dma_data;
dma_data.ADDRESS = (reg32_t) pDataBuffer;
         
Address: 180_4000h base + 130h offset + (112d × i), where i=0d to 15d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
ADDRESS
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
APBH_CHn_BAR field descriptions
Field
Description
ADDRESS
Address of system memory buffer to be read or written over the AHB bus.
15.5.12
APBH DMA Channel n Semaphore Register
(APBH_CHn_SEMA)
The APBH DMA Channel n semaphore register is used to synchronize the Arm platform
instruction stream and the DMA chain processing state.
Each DMA channel has an 8 bit counting semaphore that is used to synchronize between
the program stream and and the DMA chain processing. DMA processing continues until
the DMA attempts to decrement a semaphore that has already reached a value of zero.
When the attempt is made, the DMA channel is stalled until software increments the
semaphore count.
EXAMPLE
BF_WR(APBH_CHn_SEMA, 0, INCREMENT_SEMA, 2);     // increment semaphore by two
current_sema = BF_RD(APBH_CHn_SEMA, 0, PHORE);  // get instantaneous value
         
Address: 180_4000h base + 140h offset + (112d × i), where i=0d to 15d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
PHORE
Reserved
INCREMENT_SEMA
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
498
NXP Semiconductors

<!-- page 499 -->

APBH_CHn_SEMA field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved, always set to zero.
23–16
PHORE
This read-only field shows the current (instantaneous) value of the semaphore counter.
15–8
-
This field is reserved.
Reserved, always set to zero.
INCREMENT_
SEMA
The value written to this field is added to the semaphore count in an atomic way such that simultaneous
software adds and DMA hardware substracts happening on the same clock are protected. This bit field
reads back a value of 0x00. Writing a value of 0x02 increments the semaphore count by two, unless the
DMA channel decrements the count on the same clock, then the count is incremented by a net one.
15.5.13
AHB to APBH DMA Channel n Debug Information
(APBH_CHn_DEBUG1)
This register gives debug visibility into the APBH DMA Channel n state machine and
controls.
This register allows debug visibility of the APBH DMA Channel n.
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
499

<!-- page 500 -->

Address: 180_4000h base + 150h offset + (112d × i), where i=0d to 15d
Bit
31
30
29
28
27
26
25
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
REQ
BURST
KICK
END
Reserved
READY
Reserved
NEXTCMDADDRVALID
RD_FIFO_EMPTY
RD_FIFO_FULL
WR_FIFO_EMPTY
WR_FIFO_FULL
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
1
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
STATEMACHINE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
500
NXP Semiconductors

<!-- page 501 -->

APBH_CHn_DEBUG1 field descriptions
Field
Description
31
REQ
This bit reflects the current state of the DMA Request Signal from the APB device
30
BURST
This bit reflects the current state of the DMA Burst Signal from the APB device
29
KICK
This bit reflects the current state of the DMA Kick Signal sent to the APB Device
28
END
This bit reflects the current state of the DMA End Command Signal sent from the APB Device
27
SENSE
This field is reserved.
This bit is reserved for this DMA Channel and always reads 0.
26
READY
This bit is reserved for this DMA Channel and always reads 0.
25
LOCK
This field is reserved.
This bit is reserved for this Channel and always reads 0.
24
NEXTCMDADDRVALID
This bit reflects the internal bit which indicates whether the channel's next command address is
valid.
23
RD_FIFO_EMPTY
This bit reflects the current state of the DMA Channel's Read FIFO Empty signal.
22
RD_FIFO_FULL
This bit reflects the current state of the DMA Channel's Read FIFO Full signal.
21
WR_FIFO_EMPTY
This bit reflects the current state of the DMA Channel's Write FIFO Empty signal.
20
WR_FIFO_FULL
This bit reflects the current state of the DMA Channel's Write FIFO Full signal.
19–5
RSVD1
This field is reserved.
Reserved
STATEMACHINE
PIO Display of the DMA Channel n state machine state.
0x00 IDLE — This is the idle state of the DMA state machine.
0x01 REQ_CMD1 — State in which the DMA is waiting to receive the first word of a command.
0x02 REQ_CMD3 — State in which the DMA is waiting to receive the third word of a command.
0x03 REQ_CMD2 — State in which the DMA is waiting to receive the second word of a
command.
0x04 XFER_DECODE — The state machine processes the descriptor command field in this
state and branches accordingly.
0x05 REQ_WAIT — The state machine waits in this state for the PIO APB cycles to complete.
0x06 REQ_CMD4 — State in which the DMA is waiting to receive the fourth word of a
command, or waiting to receive the PIO words when PIO count is greater than 1.
0x07 PIO_REQ — This state determines whether another PIO cycle needs to occur before
starting DMA transfers.
0x08 READ_FLUSH — During a read transfers, the state machine enters this state waiting for
the last bytes to be pushed out on the APB.
0x09 READ_WAIT — When an AHB read request occurs, the state machine waits in this state
for the AHB transfer to complete.
0x0C WRITE — During DMA Write transfers, the state machine waits in this state until the AHB
master arbiter accepts the request from this channel.
0x0D READ_REQ — During DMA Read transfers, the state machine waits in this state until the
AHB master arbiter accepts the request from this channel.
Table continues on the next page...
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
501

<!-- page 502 -->

APBH_CHn_DEBUG1 field descriptions (continued)
Field
Description
0x0E CHECK_CHAIN — Upon completion of the DMA transfers, this state checks the value of
the Chain bit and branches accordingly.
0x0F XFER_COMPLETE — The state machine goes to this state after the DMA transfers are
complete, and determines what step to take next.
0x14 TERMINATE — When a terminate signal is set, the state machine enters this state until
the current AHB transfer is completed.
0x15 WAIT_END — When the Wait for Command End bit is set, the state machine enters this
state until the DMA device indicates that the command is complete.
0x1C WRITE_WAIT — During DMA Write transfers, the state machine waits in this state until
the AHB master completes the write to the AHB memory space.
0x1D HALT_AFTER_TERM — If HALTONTERMINATE is set and a terminate signal is set, the
state machine enters this state and effectively halts. A channel reset is required to exit this
state
0x1E CHECK_WAIT — If the Chain bit is a 0, the state machine enters this state and effectively
halts.
0x1F WAIT_READY — When the NAND Wait for Ready bit is set, the state machine enters this
state until the GPMI device indicates that the external device is ready.
15.5.14
AHB to APBH DMA Channel n Debug Information
(APBH_CHn_DEBUG2)
This register gives debug visibility for the APB and AHB byte counts for DMA Channel
n.
This register allows debug visibility of the APBH DMA Channel n.
Address: 180_4000h base + 160h offset + (112d × i), where i=0d to 15d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
APB_BYTES
AHB_BYTES
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
APBH_CHn_DEBUG2 field descriptions
Field
Description
31–16
APB_BYTES
This value reflects the current number of APB bytes remaining to be transfered in the current transfer.
AHB_BYTES
This value reflects the current number of AHB bytes remaining to be transfered in the current transfer.
APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
502
NXP Semiconductors

<!-- page 503 -->

15.5.15
APBH Bridge Version Register (APBH_VERSION)
This register always returns a known read value for debug purposes it indicates the
version of the block.
This register indicates the RTL version in use.
EXAMPLE
if (APBH_VERSION.B.MAJOR != 3)
   Error();
         
Address: 180_4000h base + 800h offset = 180_4800h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
APBH_VERSION field descriptions
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
Chapter 15 AHB-to-APBH Bridge with DMA (APBH-Bridge-DMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
503

<!-- page 504 -->

APBH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
504
NXP Semiconductors

