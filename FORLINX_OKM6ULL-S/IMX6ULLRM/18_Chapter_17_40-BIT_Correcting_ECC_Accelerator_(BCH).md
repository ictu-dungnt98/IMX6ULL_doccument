# Chapter 17: 40-BIT             Correcting ECC Accelerator (BCH)

> Nguồn: `IMX6ULLRM.pdf` — trang 563–624

<!-- page 563 -->

Chapter 17
40-BIT Correcting ECC Accelerator (BCH)
17.1
Overview
The hardware ECC accelerator provides a forward error-correction function for
improving the reliability of various storage media that may be attached to the device.
For example, NAND flash devices use a spare area to store ecc codes to correct some
hard bit errors in data stored within the device, allowing higher device yields and,
therefore, lower NAND device costs.
The Bose, Ray-Chaudhuri, Hocquenghem (BCH) Encoder and Decoder module is
capable of correcting from 2 to 40 single bit errors within a block of data no larger than
about 1900 bytes (512 bytes or 1024 bytes are typical) in applications such as protecting
data and resources stored on modern NAND flash devices. The correction level in the
BCH block is programmable to provide flexibility for varying applications and
configurations of flash page size. The design can be programmed to encode protection of
2 to 40 bit errors when writing flash and to correct the corresponding number of errors on
decode. The correction level when decoding MUST be programmed to the same
correction level as was used during the encode phase.
BCH-codes are a type of block-code, which implies that all error-correction is performed
over a block of N-symbols. The BCH operation will be performed over GF(213 = 8192)
or GF(214 = 16384), which is the Galois Field consisting of 8191 or 16383 one-bit
symbols. BCH-encoding (or encode for any block-code) can be performed by two
algorithms: systematic encoding or multiplicative encoding. Systematic encoding is the
process of reading all the symbols which constitute a block, dividing continuously these
symbols by the generator polynomial for the GF(8192) or GF(16384) and appending the
resulting t parity symbols to the block to create a BCH codeword (where t is the number
of correctable bits).
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
563

<!-- page 564 -->

The BCH encode process creates t*13 (or t*14)-bit parity symbols for each data block
when the data is written to the flash device. The parity symbols are written to the flash
device after the corresponding data block, and together these are collectively called the
codeword. The codeword can be used during the decode process to correct errors that
occur in either the data or parity blocks.
The BCH decoder processes code words in a 4-step fashion:
1. Syndrome Calculation (SC): This is the process of reading in all of the symbols of
the codeword and continuously dividing by the generator polynomial for the field.
2*t syndromes must be calculated for each codeword and inspection of the
syndromes determines if there are errors: a non-zero set of syndromes indicates one
or more errors. This process is implemented parallel hardware to minimize
processing time since it must be done every time the decode is performed.
2. Key Equation Solver (KES): The syndromes represent 2t-linear equations with 2t-
unknown variables. The process of solving these equations and selecting from the
numerous solutions constitutes the KES module. When the KES block completes its
operations, it generates an error locator polynomial (sigma) that is used in the
proceeding block to determine the locations and values of the errors.
3. Chien Search (CS): This block takes input from the KES block and uses the Chien
Algorithm for finding the locations of the errors based on the error locator
polynomial. The method basically involves substituting all 8191 symbols from the
GF(8192) or 16383 symbols from the GF(16383) into the locator polynomial. All
evaluations that produce a zero solution indicate locations of the various errors. Since
each located error corresponds to a single bit, the bit in the original data may be
corrected by simply flipping the polarity of the incorrect location.
4. Correction: this block has to convert the symbol index and mask information to
memory byte indexes and masks.
The BCH block, shown in the figure, was designed to operate in a pipelined fashion to
maximize throughput. Aside from the initial latency to fill the pipeline stages, the BCH
throughput is about 7/4 cycles/byte. Thus, the bottleneck in performing NAND reads and
error corrections is the BCH rate. Current GPMI read rates are approximately 1/2 cycles/
byte maximally for the current generation of NAND flash. Fortunately, BCH has a
different master clock from GPMI, this gives some flexibility to match the throughput
rate. The CPU is not directly involved in generating parity symbols, checking for errors,
or correcting them.
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
564
NXP Semiconductors

<!-- page 565 -->

BCH
Programmable
Registers
GPMI
NAND
CONTROLLER
APBH Bridge/DMA
AXI
APBH
BCH Engine
GPMI
Programmable
Registers
Write Data
Key
Equation
Solver
corrections
AXI
master
&
transfer
FSM
GPMI clock domain
Read Data
Transfer Controls
Write Data
Parity
Generation
Chien
Search
Read Data
Syndrome
Calculation
syndromes
error-locator polynomial
synpar
Figure 17-1. Hardware BCH Accelerator
17.2
Operation
Before performing any NAND flash read or write operations, software should first
program the BCH's flash layout registers (see Flash Page Layout) to specify how data is
to be formatted on the flash device. The BCH hardware allows full programmability over
the flash page layout to enable users flexibility in balancing ECC correction levels and
ever-changing flash page sizes.
To initiate a NAND Flash write, software will program a GPMI DMA operation. The
DMA need only program the GPMI control registers (and handle the requisite flash
addressing handshakes) since the BCH will handle all data operations using its AXI bus
interface. The BCH will then send the data to the GPMI controller to be written to flash
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
565

<!-- page 566 -->

as it computes the parity symbols. At the end of each data block the BCH will insert the
parity symbols into the data stream so that the GPMI sees only a continuous stream of
data to be written.
NAND Flash read operations operate in a similar manner. As the GPMI controller reads
the device, all data is sent to the BCH hardware for error detection/correction. The BCH
controller writes all incoming read data to system memory and in parallel computes the
syndromes used to detect bit errors. If errors are detected within a block, the BCH
hardware activates the error correction logic to determine where bit errors have occurred
and ultimately correct them in the data buffer in system memory. After an entire flash
page has been read and corrected, the BCH will signal an interrupt to the CPU.
The figure below indicates how data read from the GPMI is operated on within the BCH
hardware. As the BCH receives data from the GPMI (top row), it is written to memory by
the BCH's Bus Interface Unit (BIU) (second row). For blocks requiring correction, the
KES logic will be activated after the entire block has been received. Once the error
locator polynomial has been computed, the corrections are determined by the Chien
Search and fed back to the BIU, which performs a read, modify, write operation on the
buffer in memory to correct the data.
Read
Block 0
Read
Block 1
Read
Block 2
Read
Block 3
Read
Block 4
Read
Block 5
Read
Block 6
Read
Block 7
Write
Block 0
Write
Block 1
Write
Block 2  /
Correct 
Block 0
Write
Block 3 /
Correct
Block 1
Write
Block 4 /
Correct
Block 2
Write
Block 5 /
Correct 
Block 3
Write
Block 6 /
Correct 
Block 4
Write
Block 7 /
Correct 
Block 5
BIU
KES
Block 0
KES
Block 1
KES
Block 2
KES
Block 3
KES
Block 4
KES
Block 5
KES
Block 6
KES
Block 7
KES
CS
Block 0
CS
Block 1
CS
Block 2
CS
Block 3
CS
Block 4
CS
Block 5
CS
Block 6
CS
Block 7
Chien Search
Correct 
Block 6
Correct 
Block 7
ECC Done
Interrupt
GPMI/
Syndrome
Figure 17-2. Block Pipeline while Reading Flash
17.2.1
BCH Limitations and Assumptions
• The BCH is programmable to support 2 to 40 bit error correction. ECC0 is supported
as a pass-through, non-correcting mode.
• Data block sizes must be a multiple of 4 bytes and be aligned in system memory.
• The BCH supports a programmable number of metadata/auxiliary data bytes, from 0
to 255.
Operation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
566
NXP Semiconductors

<!-- page 567 -->

• Metadata will be written at the beginning of the flash page to facilitate fast access for
filesystem operations.
• Metadata may be treated as an independent block for ECC purposes or combined
with the first data block to conserve bits in the flash.
• The BCH does not support a partial page write (this can be accomplished by
programming the BCH layout registers such that the BCH only sees a portion of the
page).
• Flash read operations can read the entire page or the first block on the page.
• The BCH also supports a memory-to-memory mode of operation that does not
require the use of DMA or the GPMI.
17.2.2
Flash Page Layout
The BCH supports a fully programmable flash page layout. The BCH maintains four
independent layout registers that can describe four completely different NAND devices
or layouts.
When the BCH initiates an operation, it selects one of the layouts by using the chip select
as an index into the BCH_LAYOUTSELECT register that determines which layout
should be used for the operation.
Three possible (generic) flash layout schemes are supported, as indicated in the figure
below. (In each case, the metadata size may also be programmed to 0 bytes). Metadata
may either be combined with the first block of data or the size of the first data block can
be programmed to 0 to allow the metadata to be protected by its own ECC parity bits.
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
567

<!-- page 568 -->

meta
10B
d0
512B
d1
512B
d2
512B
dn-1
512B
dn
512B
Block 0
Size=10B
ECC=4
Block 1
Size=512B
ECC=14
Block 2
Size=512B
ECC=14
Separate ECC over Metadata
meta
10B
d0
512B
d1
512B
d2
512B
dn-1
512B
dn
512B
Block 0
Size=522B
ECC=16
Block 1
Size=512B
ECC=16
Combined Metadata & Block 0, unbalanced ECC coverage
Block 2
Size=512B
ECC=16
meta
32B
d0
484B
d1
516B
d2
516B
dn-1
516B
dn
516B
Block 0
Size=516B
ECC=14
Block 1
Size=516B
ECC=14
Combined Metadata & Block 0, balanced ECC coverage
Block 2
Size=516B
ECC=14
parity
parity
parity
parity
parity
parity
parity
parity
parity
parity
parity
parity
parity
parity
parity
parity
Figure 17-3. FLASH Page Layout Options
Each layout is determined by a pair of registers that define the following parameters:
• DATA0_SIZE: Indicates the number of data bytes in the first block on the page (this
should not include parity or metadata bytes). This should be set to 0 when the
metadata is to be covered separately with its own ECC. This must be a multiple of 4
bytes.
• ECC0: Indicates the ECC level to be used for the first block on the flash
(data0+metadata).
• META_SIZE: Indicates the number of bytes (from 0-255) that are stored as
metadata.
• NBLOCKS: Indicates the number of subsequent DATAN blocks on the flash, or the
number of blocks following the DATA0 block.
• DATAN_SIZE: Indicates the number of data bytes in all subsequent data blocks.
This MUST be a multiple of 4 bytes.
• ECCN: Indicates the ECC level to be used for the subsequent data blocks.
Operation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
568
NXP Semiconductors

<!-- page 569 -->

• GF0 or GFN: Indicates the Galois field the meta / data blocks are using
• PAGE_SIZE: Indicates the total number of bytes available per page on the physical
flash device. This includes the spare area and is typically 4096+128, 4096+218, or
2048+64 bytes.
17.2.3
Determining the ECC layout for a device
Since the BCH is programmable, a system can trade off ECC levels for flash size and
layout configurations.
The following examples indicate how to determine a valid layout based on the required
storage space and flash size. For all cases, the size of the parity will be 13 (or 14 for
GF(214))*ECC level bits-- so for ECC8, 13 (or 14) bytes are required (per block).
17.2.3.1
4K+218 flash, 10 bytes metadata, 512 byte data blocks,
separate metadata, Assuming GF(213)
In this case, we have 8 data blocks each consisting of 512 bytes. Since the flash has 218
spare bytes (1744 bits), first estimate an ECC level for the data blocks by first subtracting
the number of metadata bytes from the spare bytes (218 – 10 = 208 bytes = 1664 bits)
then dividing the number of bits by 8 (number of blocks) and then by 13 (bits per ECC
level).
(218 - 10) x 8 = 1664/13(8) = 16
Therefore all the data blocks could be covered by ECC16 if the metadata had no parity.
This isn't acceptable, so assume ECC14 for all the data blocks. Now calculate the number
of free bits for the metadata parity as
1664 - (14) x 13 x 8 = 208
Therefore, 208 bits remain for metadata parity. Dividing by 13 (bits/ECC) gives 16, so
the metadata can be covered with ECC16. The settings for this device would then be
Table 17-1. Settings for 4K+218 FLASH
Setting
Value
PAGE_SIZE
4096+218=4314=0x10DA
META_SIZE
10=0x0A
DATA0_SIZE
0
ECC0
16=0x10
Table continues on the next page...
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
569

<!-- page 570 -->

Table 17-1. Settings for 4K+218 FLASH (continued)
Setting
Value
GF0
GF(213)
DATAN_SIZE
512=0x200 (in register interface, assigned as 0x80)
ECCN
14=0x0E
GFN
GF(213)
NBLOCKS
8
17.2.3.2
4K+128 flash, 10 bytes metadata, 1024 byte data blocks,
separate metadata, assuming GF(213) for data and GF(214)
for metadata
This flash will have 118 bytes available for ECC (after subtracting the metadata size),
therefore, 994 bits.
Dividing by 4*14 (number of blocks * ECC level) we get 17.75, therefore we can support
ECC16 on the data blocks. The number of free spare bits becomes 944 - 16 * 4 * 14 =
944 - 896 = 48, divided by 13 = 3.69, therefore the metadata can be also covered by
ECC2.
Table 17-2. Settings for 4K+128 FLASH
Setting
Value
PAGE_SIZE
4096+128=4224=0x1080
META_SIZE
10=0x0A
DATA0_SIZE
0
ECC0
2
GF0
GF(213)
DATAN_SIZE
1024=0x400 (in register interface, assigned as 0x100)
ECCN
16
GFN
GF(214)
NBLOCKS
4
In this case, there will be additional unused spare bits, with the BCH will pad out with
zeros.
17.2.4
Data Buffers in System Memory
While the data on the flash is interleaved with parity symbols, the BCH assumes that the
data buffers in memory are contiguous.
Operation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
570
NXP Semiconductors

<!-- page 571 -->

Metadata read from the flash will be stored to the location pointed to by the
GPMI_AUXILIARY register and data will be written to the address specified in the
GPMI_PAYLOAD register as is shown in the following figure where the block length is
512 bytes for example. Since the number of blocks on a flash page is programmable, the
BCH also writes individual block correction status to the auxiliary pointer at the word-
aligned address following the end of the metadata. Optionally, the computed syndromes
may also be written to the auxiliary area if the DEBUGSYNDROME bit is set in the
control register.
As blocks complete processing, the bus master will accumulate the status for each block
and write it to the auxiliary data buffer following the metadata. The metadata area will be
padded with 0's until the next word boundary and the status for blocks 0-3 will be written
to the next word. The status for subsequent blocks will then be written to the buffer. The
status for the first block (metadata block) is also stored in the STATUS_BLK0 register in
the BCH_STATUS register. The completion codes for the blocks are indicated in the
Table 17-3. Note that the definition of the bytes and their ordering in the auxiliary and
payload storage areas are user defined. When this data is read back from the flash and put
into memory, it will resemble the original buffer that was written out to the flash.
512 byte Payload A
Minimum System Memory Footprint:
HW_GPMI_PAYLOAD
512 byte Payload B
512 byte Payload C
512 byte Payload D
META_SIZE bytes of auxiliary storage
(programmable – block is padded w/ 0's to word
boundary)
HW_GPMI_AUXILIARY
(Optional n bytes syndromes for Payload A)
Status for each block.
Computed syndrome area consists of 2*t 13 (or 14)-
bit symbols written as 16-bit half word.
(Optional n bytes syndrome for Payload B)
(Optional n bytes syndrome for Payload C)
(Optional n bytes syndrome for Payload D)
Figure 17-4. BCH Data Buffers in Memory
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
571

<!-- page 572 -->

Table 17-3. Status Block Completion Codes
Code
Description
0xFF
Block is erased
0xFE
Block is uncorrectable
0x00
No errors found
0x01-0x28
Number of errors corrected
The following figure shows the layout of the bytes within the status field.
Status bytes are allocated based on the NBLOCKS programmed into the 
flash format register.  The number of status bytes are computed by NBLOCK+1.
The status area will be padded with zeros to the next word boundary. 
3
2
1
0
0
0
Block 3
Status
Block 2
Status
Block 1
Status
block 0
Status
Block 7
Status
Block 6
Status
Block 5
Status
Block 4
Status
Metadata
0
0
0
Block 8
Status
Syndrome data written for debug purposes
follows the end of the status block.
Figure 17-5. Memory-to-Memory Operations
17.3
Memory to Memory (Loopback) Operation
The BCH supports a memory-to-memory mode of operation where both the encoded and
decoded buffers reside in system memory.
This can be useful for applications where data must be protected by ECC, but the storage
device does not reside on the GPMI bus.
The BCH operation in memory to memory mode is much simpler than in GPMI mode
since DMAs are not required to manage the operation. Instead, software simply writes the
BCH_DATAPTR and BCH_METAPTR with the addresses of the data and metadata
(auxiliary) buffers and the BCH_ENCODEPTR with the address of the buffer for
encoded data. To initiate the operation, software simply sets the M2M_ENCODE and
Memory to Memory (Loopback) Operation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
572
NXP Semiconductors

<!-- page 573 -->

M2M_ENABLE bits in the control register. The BCH can be programmed to either issue
an interrupt at the end of the operation or software may poll the status bits for
completion.
Memory to memory decode operations work in a similar manner. The encoded data
address is written to the BCH_ENCODEPTR and the data and meta pointers are written
to buffers that correspond to the desired decoded data addresses. To initiate a decode,
software must set the M2M_ENCODE bit to 0 while writing the M2M_ENABLE bit.
Note that the addresses written to the BCH_DATAPTR, BCH_METAPTR and
BCH_ENCODEPTR registers should always be aligned on a 4 byte boundary. In other
words, the 2 lower bits of the address should always be written with zeros.
17.4
Programming the BCH/GPMI Interfaces
Programming the BCH for NAND operations consists largely of disabling the soft reset
and clock bits (SFTRST and CLKGATE) from the BCH_CTRL register and then
programming the flash layout registers to correspond to the format of the attached NAND
device(s).
The BCH_LAYOUTSELECT register should also be programmed to map the chip select
of each attached device into one of the four layout registers.
The bulk of the programming is actually applied to the GPMI through PIO operations
embedded in DMA command structures. The DMA will perform all the requisite
handshaking with the GPMI interface to negotiate the address portion of the transfer, then
the BCH will handle all the movement of data from memory to the GPMI (writes) or the
GPMI to memory (reads). The BCH will direct all data blocks to the buffer pointed to by
the PAYLOAD_BUFFER and the metadata will be written to the
AUXILIARY_BUFFER. Both of these registers are located in the GPMI PIO data space
and are communicated to the BCH hardware at the beginning of the transfer. Thus, the
normal multi-NAND DMA based device interleaving is preserved, that is, four NANDs
on four separate chip selects can be scheduled for read or write operations using the
BCH. Whichever channel finishes its ready wait first and enters the DMA arbiter with its
lock bit set owns the GPMI command interface and through it owns the BCH resources
for the duration of its processing.
17.4.1
BCH Encoding for NAND Writes
The BCH encoder flowchart in Figure 17-6 shows the detailed steps involved in
programming and using the BCH encoder. This flowchart shows how to use the BCH
block with the GPMI.
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
573

<!-- page 574 -->

To use the BCH encoder with the GPMI's DMA, create a DMA command chain
containing ten descriptor structures, as shown in Figure 17-8 and detailed in the DMA
structure code example that follows it in DMA Structure Code Example. The ten
descriptors perform the following tasks:
1. Disable the BCH block (in case it was enabled) and issue NAND write setup
command byte (under CLE) and address bytes (under ALE).
2. Configure and enable the BCH and GPMI blocks to perform the NAND write.
3. Disable the BCH block and issue NAND write execute command byte (under CLE).
4. Wait for the NAND device to finish writing the data by watching the ready signal.
5. Check for NAND timeout through PSENSE.
6. Issue NAND status command byte (under CLE).
7. Read the status and compare against expected.
8. If status is incorrect or incomplete, branch to error handling descriptor chain.
9. Otherwise, write is complete and emit GPMI interrupt.
Programming the BCH/GPMI Interfaces
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
574
NXP Semiconductors

<!-- page 575 -->

STOP
BCH ENCODE &
WRITE NAND
Run the prescribe initialization sequence.
Point the GPMI DMA channel 4 (or 0/1/2/3/5/6/7) at
the prescribed static DMA sequence.
Start the DMA.
Return and wait for DMA channel 4 (or 0/1/2/3/5/6/7)
command complete interrupt.
APBH DMA CH4 Command
Complete ISR
HW_APBH_CTRL1_CH0_CMDCMPLT_IRQ = 0
STOP
Must use SCT clear
Start GPMI DMA chain for next write or read transfer.
Figure 17-6. BCH Encode Flowchart
CMD
<=
xfer_count
cmdwords
wait4endcmd
semaphore
nandwait4ready
nandlock
irqoncmplt
chain command
HW_GPMI_CTRL0
command_mode
word_length
lock_cs
CS
address
address_increment
HW_GPMI_COMPARE
HW_GPMI_ECCCTRL
Descriptor Legend
NEXT CMD ADDR
BUFFER ADDR
xfer_count
mask
reference
ecc_cmd
enable_ecc
buffer_mask
HW_GPMI_ECCCOUNT
HW_GPMI_PAYLOAD
HW_GPMI_AUXILIARY
<=
<=
<=
Figure 17-7. BCH DMA Descriptor Legend
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
575

<!-- page 576 -->

CMD
<=
1 + 5
3
1
0
0
1 0 1
DMA_READ
HW_GPMI_CTRL0   <=
write
8_bit
enabled 2
NAND_CLE
1
HW_GPMI_COMPARE <=
HW_GPMI_ECCCTRL <=
CMD                <=
0
4
1
0
0
1 0 1 NO_DMA_XFER
HW_GPMI_CTRL0   <=
write
8_bit
enabled 2 NAND_DATA
0
HW_GPMI_COMPARE <=
HW_GPMI_ECCCTRL <=
HW_GPMI_ECCCOUNT<=
CMD                <=
1
3
1
0
0
1 0 1
DMA_READ
HW_GPMI_CTRL0   <=
write
8_bit
enabled 2
NAND_CLE
0
HW_GPMI_COMPARE <=
HW_GPMI_ECCCTRL <=
CMD                <=
0
1
1
0
1
0 0 1 NO_DMA_XFER
HW_GPMI_CTRL0   <=
wait_for_ready
8_bit disabled
2 NAND_DATA
0
CMD
<=
0
0
0
0
0
0 0 1
DMA_SENSE
CMD                <=
1
3
1
0
0
1 0 1
DMA_READ
HW_GPMI_CTRL0   <=
write
8_bit
enabled 2
NAND_CLE
0
HW_GPMI_COMPARE <=
HW_GPMI_ECCCTRL <=
CMD                <=
0
2
1
0
0
1 0 1 NO_DMA_XFER
HW_GPMI_CTRL0   <=
read_and_compare
8_bit disabled
2 NAND_DATA
0
HW_GPMI_COMPARE <=
CMD                <=
0
0
0
0
0
0 0 1
DMA_SENSE
CMD                <=
0
0
0
0
0
0 1 0 NO_DMA_XFER
BUFFER ADDR
1
NEXT CMD ADDR
BUFFER ADDR
Descriptor 6: Disable BCH engine (if enabled by another thread) and issue NAND status command (CLE).
NEXT CMD ADDR
BUFFER ADDR
Descriptor 5: PSENSE compare for time-out.
Descriptor 3: Disable BCH engine and issue NAND write execute command (CLE).
NEXT CMD ADDR
1
null
null
----
disable
----
BUFFER ADDR
BUFFER ADDR
Descriptor 9: Emit GPMI DMA interrupt.
NEXT CMD ADDR
Descriptor 8: PSENSE compare for status comparison check.
BUFFER ADDR
NEXT CMD ADDR
<mask_value>
<reference_value>
Descriptor 7: Read the NAND status and compare against expected value.
1
null
null
----
disable
----
NEXT CMD ADDR
enable
0x1FF
0
Descriptor 4: Wait for NAND ready.
NEXT CMD ADDR
BUFFER ADDR
Descriptor 2: Enable the BCH engine and write the data payload.
NEXT CMD ADDR
1 + 5
null
null
disable
NEXT CMD ADDR
BUFFER ADDR
Descriptor 1: Disable BCH engine and issue NAND write set-up command and address (CLE/ALE).
4096+218 (flash page size)
BUFFER ADDR
0
null
null
encode_8_bit
1 Byte NAND CMD
5 Byte ADDR
DMA Error 
Descriptor Chain
1 Byte NAND CMD
1 Byte NAND CMD
HW_GPMI_PAYLOAD
HW_GPMI_AUXILIARY
8*512 Byte Data
Payload Buffer
Auxiliary Payload 
Buffer
NOTE: No DMA
data transferred to
GPMI when using
BCH
Figure 17-8. BCH Encode DMA Descriptor Chain
Programming the BCH/GPMI Interfaces
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
576
NXP Semiconductors

<!-- page 577 -->

17.4.1.1
DMA Structure Code Example
The following code sample illustrates the coding for one write transaction involving 4096
bytes of data payload (eight 512-byte blocks) and 10 bytes of auxiliary payload (also
referred to as metadata) to a 4K NAND page sitting on GPMI CS2.
            
//----------------------------------------------------------------------------
// generic DMA/GPMI/ECC descriptor struct, order sensitive!
//----------------------------------------------------------------------------
typedef struct {
  // DMA related fields
  unsigned int dma_nxtcmdar;
  unsigned int dma_cmd;
  unsigned int dma_bar;
  // GPMI related fields
  unsigned int gpmi_ctrl0;
  unsigned int gpmi_compare;
  unsigned int gpmi_eccctrl;
  unsigned int gpmi_ecccount;
  unsigned int gpmi_data_ptr;
  unsigned int gpmi_aux_ptr;
} GENERIC_DESCRIPTOR;
//----------------------------------------------------------------------------
// allocate 10 descriptors for doing a NAND ECC Write
//----------------------------------------------------------------------------
GENERIC_DESCRIPTOR write[10];
//----------------------------------------------------------------------------
// DMA descriptor pointer to handle error conditions from psense checks
//----------------------------------------------------------------------------
unsigned int * dma_error_handler;
//----------------------------------------------------------------------------
// 8 byte NAND command and address buffer
// any alignment is ok, it is read by the GPMI DMA
//   byte 0 is write setup command
//   bytes 1-5 is the NAND address
//   byte 6 is write execute command
//   byte 7 is status command
//----------------------------------------------------------------------------
unsigned char nand_cmd_addr_buffer[8];
//----------------------------------------------------------------------------
// 4096 byte payload buffer used for reads or writes
// needs to be word aligned
//----------------------------------------------------------------------------
unsigned int write_payload_buffer[(4096/4)];
//----------------------------------------------------------------------------
// 65 byte meta-data to be written to NAND
// needs to be word aligned
//----------------------------------------------------------------------------
unsigned int write_aux_buffer[65];
//----------------------------------------------------------------------------
// Descriptor 1: issue NAND write setup command (CLE/ALE)
//----------------------------------------------------------------------------
write[0].dma_nxtcmdar = &write[1];                          // point to the next descriptor
write[0].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (1 + 5)|   // 1 byte command, 5 byte address
                   BF_APBH_CHn_CMD_CMDWORDS      (3)    |   // send 3 words to the GPMI
                 BF_APBH_CHn_CMD_WAIT4ENDCMD   (1)    |   // wait for command to finish 
before
                                                            //    continuing
                   BF_APBH_CHn_CMD_SEMAPHORE     (0)    |
                   BF_APBH_CHn_CMD_NANDWAIT4READY(0)    |
                   BF_APBH_CHn_CMD_NANDLOCK      (1)    |   // prevent other DMA channels 
from
                                                            //    taking over
                   BF_APBH_CHn_CMD_IRQONCMPLT    (0)    |
                   BF_APBH_CHn_CMD_CHAIN         (1)    |   // follow chain to next command
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
577

<!-- page 578 -->

                 BV_FLD(APBH_CHn_CMD, COMMAND, DMA_READ); // read data from DMA, write to 
NAND
write[0].dma_bar = &nand_cmd_addr_buffer;           // byte 0 write setup, bytes 1 - 5 NAND 
address
// 3 words sent to the GPMI
write[0].gpmi_ctrl0 = BV_FLD(GPMI_CTRL0, COMMAND_MODE, WRITE)    | // write to the NAND
                      BV_FLD(GPMI_CTRL0, WORD_LENGTH,  8_BIT)    |
                      BV_FLD(GPMI_CTRL0, LOCK_CS,      ENABLED)  |
                   BF_GPMI_CTRL0_CS              (2)      | // must correspond to NAND CS 
used
                      BV_FLD(GPMI_CTRL0, ADDRESS,      NAND_CLE) |
                      BF_GPMI_CTRL0_ADDRESS_INCREMENT  (1)       | // send command and 
address
                   BF_GPMI_CTRL0_XFER_COUNT       (1 + 5);    // 1 byte command, 5 byte 
address
write[0].gpmi_compare = NULL;                           // field not used but necessary to 
set eccctrl
write[0].gpmi_eccctrl = BV_FLD(GPMI_ECCCTRL, ENABLE_ECC, DISABLE); // disable the ECC block
//----------------------------------------------------------------------------
// Descriptor 2: write the data payload (DATA)
//----------------------------------------------------------------------------
write[1].dma_nxtcmdar = &write[2];                       // point to the next descriptor
write[1].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT      (0)|  // NOTE: No DMA data transfer
                   BF_APBH_CHn_CMD_CMDWORDS        (4)|  // send 4 words to the GPMI
                   BF_APBH_CHn_CMD_WAIT4ENDCMD     (1)|  // Wait to end
                   BF_APBH_CHn_CMD_SEMAPHORE       (0)|
                   BF_APBH_CHn_CMD_NANDWAIT4READY  (0)|
                   BF_APBH_CHn_CMD_NANDLOCK        (1)|  // maintain resource lock
                   BF_APBH_CHn_CMD_IRQONCMPLT      (0)|
                   BF_APBH_CHn_CMD_CHAIN           (1)|  // follow chain to next command
                   BV_FLD(APBH_CHn_CMD, COMMAND, DMA_NO_XFER);  // No data transferred
write[1].dma_bar = &write_payload_buffer;                       // pointer for the 4K byte 
data area
// 4 words sent to the GPMI
write[1].gpmi_ctrl0 = BV_FLD(GPMI_CTRL0, COMMAND_MODE, WRITE)    | // write to the NAND
                      BV_FLD(GPMI_CTRL0, WORD_LENGTH,  8_BIT)    |
                      BV_FLD(GPMI_CTRL0, LOCK_CS,      ENABLED)  |
                   BF_GPMI_CTRL0_CS                 (2)       | // must correspond to NAND 
CS used
                      BV_FLD(GPMI_CTRL0, ADDRESS,      NAND_DATA)|
                      BF_GPMI_CTRL0_ADDRESS_INCREMENT  (0)       |
                      BF_GPMI_CTRL0_XFER_COUNT         (0);        // NOTE: this field 
contains
                                                                     //  the total amount
                              // DMA transferred to GPMI via DMA (0)!
write[1].gpmi_compare = NULL;                               // field not used but necessary 
to 
set eccctrl
write[1].gpmi_eccctrl = BV_FLD(GPMI_ECCCTRL, ECC_CMD,    ENCODE_8_BIT) | // specify t = 8 
mode
                        BV_FLD(GPMI_ECCCTRL, ENABLE_ECC, ENABLE)       | // enable ECC module
                     BF_GPMI_ECCCTRL_BUFFER_MASK   (0x1FF);           // write all 8 data 
blocks
                                                                         //   and 1 aux block
write[1].gpmi_ecccount = BF_GPMI_ECCCOUNT_COUNT(4096+218);      // specify number of bytes
                                                                //   written to NAND
write[1].gpmi_data_pointer = &write_payload_pointer;            // data buffer address
write[1].gpmi_aux_pointer  = &write_aux_pointer;                // metadata pointer
//----------------------------------------------------------------------------
// Descriptor 3: issue NAND write execute command (CLE)
//----------------------------------------------------------------------------
write[2].dma_nxtcmdar = &write[3];                         // point to the next descriptor
write[2].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (1) |     // 1 byte command
                   BF_APBH_CHn_CMD_CMDWORDS      (3) |     // send 3 words to the GPMI
                  BF_APBH_CHn_CMD_WAIT4ENDCMD   (1) |     // wait for command to finish 
before
                                                           //    continuing
                   BF_APBH_CHn_CMD_SEMAPHORE     (0) |
                   BF_APBH_CHn_CMD_NANDWAIT4READY(0) |
                   BF_APBH_CHn_CMD_NANDLOCK      (1) |     // maintain resource lock
Programming the BCH/GPMI Interfaces
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
578
NXP Semiconductors

<!-- page 579 -->

                   BF_APBH_CHn_CMD_IRQONCMPLT    (0) |
                   BF_APBH_CHn_CMD_CHAIN         (1) |     // follow chain to next command
                BV_FLD(APBH_CHn_CMD, COMMAND, DMA_READ);   // read data from DMA, write to 
NAND
write[2].dma_bar = &nand_cmd_addr_buffer[6];             // point to byte 6, write execute 
command
// 3 words sent to the GPMI
write[2].gpmi_ctrl0 = BV_FLD(GPMI_CTRL0, COMMAND_MODE, WRITE)    | // write to the NAND
                      BV_FLD(GPMI_CTRL0, WORD_LENGTH,  8_BIT)    |
                      BV_FLD(GPMI_CTRL0, LOCK_CS,      ENABLED)  |
                   BF_GPMI_CTRL0_CS               (2)      | // must correspond to NAND CS 
used
                      BV_FLD(GPMI_CTRL0, ADDRESS,      NAND_CLE) |
                      BF_GPMI_CTRL0_ADDRESS_INCREMENT  (0)       |
                      BF_GPMI_CTRL0_XFER_COUNT         (1);        // 1 byte command
write[2].gpmi_compare = NULL;                         // field not used but necessary to set 
eccctrl
write[2].gpmi_eccctrl = BV_FLD(GPMI_ECCCTRL, ENABLE_ECC, DISABLE); // disable the ECC block
//----------------------------------------------------------------------------
// Descriptor 4: wait for ready (CLE)
//----------------------------------------------------------------------------
write[3].dma_nxtcmdar = &write[4];                       // point to the next descriptor
write[3].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (0) |   // no dma transfer
                   BF_APBH_CHn_CMD_CMDWORDS      (1) |   // send 1 word to the GPMI
                   BF_APBH_CHn_CMD_WAIT4ENDCMD   (1) |   // wait for command to finish before
                                                         //      continuing
                   BF_APBH_CHn_CMD_SEMAPHORE     (0) |
                   BF_APBH_CHn_CMD_NANDWAIT4READY(1) |   // wait for nand to be ready
                   BF_APBH_CHn_CMD_NANDLOCK      (0) |   // relinquish nand lock
                   BF_APBH_CHn_CMD_IRQONCMPLT    (0) |
                   BF_APBH_CHn_CMD_CHAIN         (1) |   // follow chain to next command
                   BV_FLD(APBH_CHn_CMD, COMMAND, NO_DMA_XFER);           // no dma transfer
write[3].dma_bar = NULL;                                                 // field not used
// 1 word sent to the GPMI
write[3].gpmi_ctrl0 = BV_FLD(GPMI_CTRL0, COMMAND_MODE, WAIT_FOR_READY) | // wait for NAND 
ready
                      BV_FLD(GPMI_CTRL0, WORD_LENGTH,  8_BIT)         |
                      BV_FLD(GPMI_CTRL0, LOCK_CS,      DISABLED)      |
                 BF_GPMI_CTRL0_CS              (2)         | // must correspond to NAND CS 
used
                      BV_FLD(GPMI_CTRL0, ADDRESS,      NAND_DATA)     |
                      BF_GPMI_CTRL0_ADDRESS_INCREMENT  (0)            |
                      BF_GPMI_CTRL0_XFER_COUNT         (0);
//----------------------------------------------------------------------------
// Descriptor 5: psense compare (time out check)
//----------------------------------------------------------------------------
write[4].dma_nxtcmdar = &write[5];                            // point to the next descriptor
write[4].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (0)        | // no dma transfer
                   BF_APBH_CHn_CMD_CMDWORDS      (0)        | // no words sent to GPMI
                   BF_APBH_CHn_CMD_WAIT4ENDCMD   (0)        | // do not wait to continue
                   BF_APBH_CHn_CMD_SEMAPHORE     (0)        |
                   BF_APBH_CHn_CMD_NANDWAIT4READY(0)        |
                   BF_APBH_CHn_CMD_NANDLOCK      (0)        |
                   BF_APBH_CHn_CMD_IRQONCMPLT    (0)        |
                   BF_APBH_CHn_CMD_CHAIN         (1)        | // follow chain to next command
                   BV_FLD(APBH_CHn_CMD, COMMAND, DMA_SENSE);  // perform a sense check
write[4].dma_bar = dma_error_handler;              // if sense check fails, branch to error 
handler
//----------------------------------------------------------------------------
// Descriptor 6: issue NAND status command (CLE)
//----------------------------------------------------------------------------
write[5].dma_nxtcmdar = &write[6];                         // point to the next descriptor
write[5].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (1)    |  // 1 byte command
                   BF_APBH_CHn_CMD_CMDWORDS      (3)    |  // send 3 words to the GPMI
                 BF_APBH_CHn_CMD_WAIT4ENDCMD   (1)    |  // wait for command to finish 
before 
continuing
                   BF_APBH_CHn_CMD_SEMAPHORE     (0)    |
                   BF_APBH_CHn_CMD_NANDWAIT4READY(0)    |
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
579

<!-- page 580 -->

                  BF_APBH_CHn_CMD_NANDLOCK      (1)    |  // prevent other DMA channels from 
taking over
                   BF_APBH_CHn_CMD_IRQONCMPLT    (0)    |
                   BF_APBH_CHn_CMD_CHAIN         (1)    |  // follow chain to next command
                BV_FLD(APBH_CHn_CMD, COMMAND, DMA_READ);  // read data from DMA, write to 
NAND
write[5].dma_bar = &nand_cmd_addr_buffer[7];                 // point to byte 7, status 
command
write[5].gpmi_compare = NULL;                         // field not used but necessary to set 
eccctrl
write[5].gpmi_eccctrl = BV_FLD(GPMI_ECCCTRL, ENABLE_ECC, DISABLE); // disable the ECC block
// 3 words sent to the GPMI
write[5].gpmi_ctrl0 = BV_FLD(GPMI_CTRL0, COMMAND_MODE, WRITE)    | // write to the NAND
                      BV_FLD(GPMI_CTRL0, WORD_LENGTH,  8_BIT)    |
                      BV_FLD(GPMI_CTRL0, LOCK_CS,      ENABLED)  |
                   BF_GPMI_CTRL0_CS               (2)     | // must correspond to NAND CS 
used
                      BV_FLD(GPMI_CTRL0, ADDRESS,      NAND_CLE) |
                      BF_GPMI_CTRL0_ADDRESS_INCREMENT  (0)       |
                      BF_GPMI_CTRL0_XFER_COUNT         (1);        // 1 byte command
//----------------------------------------------------------------------------
// Descriptor 7: read status and compare (DATA)
//----------------------------------------------------------------------------
write[6].dma_nxtcmdar = &write[7];                         // point to the next descriptor
write[6].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (0)  |    // no dma transfer
                   BF_APBH_CHn_CMD_CMDWORDS      (2)  |    // send 2 words to the GPMI
                  BF_APBH_CHn_CMD_WAIT4ENDCMD   (1)  |    // wait for command to finish 
before
                                                           //      continuing
                   BF_APBH_CHn_CMD_SEMAPHORE     (0)  |
                   BF_APBH_CHn_CMD_NANDWAIT4READY(0)  |
                   BF_APBH_CHn_CMD_NANDLOCK      (1)  |    // maintain resource lock
                   BF_APBH_CHn_CMD_IRQONCMPLT    (0)  |
                   BF_APBH_CHn_CMD_CHAIN         (1)  |    // follow chain to next command
                   BV_FLD(APBH_CHn_CMD, COMMAND, NO_DMA_XFER);  // no dma transfer
write[6].dma_bar = NULL;                                        // field not used
// 2 word sent to the GPMI
write[6].gpmi_ctrl0 = BV_FLD(GPMI_CTRL0, COMMAND_MODE, READ_AND_COMPARE) | // read from the
                                                                           //       NAND and
//                                                                       // compare to expect
                      BV_FLD(GPMI_CTRL0, WORD_LENGTH,  8_BIT)     |
                      BV_FLD(GPMI_CTRL0, LOCK_CS,      DISABLED)  |
                  BF_GPMI_CTRL0_CS             (2)       |   // must correspond to NAND CS 
used
                      BV_FLD(GPMI_CTRL0, ADDRESS,      NAND_DATA) |
                      BF_GPMI_CTRL0_ADDRESS_INCREMENT  (0)        |
                      BF_GPMI_CTRL0_XFER_COUNT         (1);
write[6].gpmi_compare = <MASK_AND_REFERENCE_VALUE>;  // NOTE: mask and reference values are 
NAND
                                                            // SPECIFIC to evaluate the NAND 
status
//----------------------------------------------------------------------------
// Descriptor 8: psense compare (time out check)
//----------------------------------------------------------------------------
write[7].dma_nxtcmdar = &write[8];                            // point to the next descriptor
write[7].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (0)        | // no dma transfer
                   BF_APBH_CHn_CMD_CMDWORDS      (0)        | // no words sent to GPMI
                   BF_APBH_CHn_CMD_WAIT4ENDCMD   (0)        | // do not wait to continue
                   BF_APBH_CHn_CMD_SEMAPHORE     (0)        |
                   BF_APBH_CHn_CMD_NANDWAIT4READY(0)        |
                   BF_APBH_CHn_CMD_NANDLOCK      (0)        | // relinquish nand lock
                   BF_APBH_CHn_CMD_IRQONCMPLT    (0)        |
                   BF_APBH_CHn_CMD_CHAIN         (1)        | // follow chain to next command
                   BV_FLD(APBH_CHn_CMD, COMMAND, DMA_SENSE);  // perform a sense check
write[7].dma_bar = dma_error_handler;             // if sense check fails, branch to error 
handler
//----------------------------------------------------------------------------
// Descriptor 9: emit GPMI interrupt
//----------------------------------------------------------------------------
write[8].dma_nxtcmdar = NULL;                                   // not used since this is 
Programming the BCH/GPMI Interfaces
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
580
NXP Semiconductors

<!-- page 581 -->

last 
descriptor
write[8].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (0)          | // no dma transfer
                   BF_APBH_CHn_CMD_CMDWORDS      (0)          | // no words sent to GPMI
                   BF_APBH_CHn_CMD_WAIT4ENDCMD   (0)          | // do not wait to continue
                   BF_APBH_CHn_CMD_SEMAPHORE     (0)          |
                   BF_APBH_CHn_CMD_NANDWAIT4READY(0)          |
                   BF_APBH_CHn_CMD_NANDLOCK      (0)          |
                   BF_APBH_CHn_CMD_IRQONCMPLT    (1)          | // emit GPMI interrupt
                   BF_APBH_CHn_CMD_CHAIN         (0)          | // terminate DMA chain 
processing
                   BV_FLD(APBH_CHn_CMD, COMMAND, NO_DMA_XFER);  // no dma transfer
17.4.1.2
Using the BCH Encoder
To use the BCH encoder, first turn off the module-wide soft reset bit in both the GPMI
and BCH blocks before starting any DMA activity.
Turning off the soft reset must take place by itself, prior to programming the rest of the
control registers. Turn off the BCH bus master soft reset bit. Turn off the clock gate bits.
Program the remainder of the GPMI, BCH and APBH DMA as follows:
    // bring APBH out of reset
    APBH_CTRL0_CLR(BM_APBH_CTRL0_SFRST);
    APBH_CTRL0_CLR(BM_APBH_CTRL0_CLKGATE);
    // bring BCH out of reset
    BCH_CTRL_CLR(BM_BCH_CTRL_SFTRST);
    BCH_CTRL_CLR(BM_BCH_CTRL_CLKGATE);
    // bring gpmi out of reset
    GPMI_CTRL0_CLR(BM_GPMI_CTRL0_SFTRST);
    GPMI_CTRL0_CLR(BM_GPMI_CTRL0_CLKGATE);
    GPMI_CTRL1_SET(BM_GPMI_CTRL1_DEV_RESET | // deassert reset
                       BM_GPMI_CTRL1_BCH_MODE  );    // enable BCH mode
      
    // enable pinctrl
    PINCTRL_CTRL_WR(0x00000000);
    // enable gpmi pins
    PINCTRL_MUXSEL0_CLR(0x0000ffff);    // data bits
    PINCTRL_MUXSEL1_CLR(0x03ffffff);    // control bits
    PINCTRL_MUXSEL8_CLR(0x0003f3ff);    // control bits
    PINCTRL_MUXSEL8_SET(0x00015155);    // control bits
Note that for writing NANDs (ECC encoding), only GPMI DMA command complete
interrupts are used. The BCH engine is used for writing to the NAND but may optionally
produces an interrupt. From the sample code in DMA Structure Code Example :
• DMA descriptor 1 prepares the NAND for data write by using the GPMI to issue a
write setup command byte under CLE, then sends a 5-byte address under ALE. The
BCH engine is disabled and not used for these commands.
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
581

<!-- page 582 -->

• DMA descriptor 2 enables the BCH engine for encoding to begin the initial writing
of the NAND data by specifying where the data and auxiliary payload are coming
from in system memory.
• DMA descriptor 3 issues the write commit command byte under CLE to the NAND.
• DMA descriptor 4 waits for the NAND to complete the write commit/transfer by
watching the NAND's ready line status. This descriptor relinquishes the
NANDLOCK on the GPMI to enable the other DMA channels to initiate NAND
transactions on different NAND CS lines.
• DMA descriptor 6 issues a NAND status command byte under "CLE" to check the
status of the NAND device following the page write.
• DMA descriptor 7 reads back the NAND status and compares the status with an
expected value. If there are differences, then the DMA processing engine follows an
error-handling DMA descriptor path.
• DMA descriptor 8 disables the BCH engine and emits a GPMI interrupt to indicate
that the NAND write has been completed.
17.4.2
BCH Decoding for NAND Reads
When a page is read from NAND flash, BCH syndromes will be computed and, if
correctable errors are found, they will be corrected on a per block basis within the NAND
page. This decoding process is fully overlapped with other NAND data reads and with
CPU execution. The BCH decoder flowchart in the figure below shows the steps involved
in programming the decoder. The hardware flow of reading and decoding a 4096-byte
page is shown in Figure 17-10.
Programming the BCH/GPMI Interfaces
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
582
NXP Semiconductors

<!-- page 583 -->

STOP
Read NAND &
BCH Decode
Run the prescribe initialization Sequence
Point the GPMI DMA channel 4 (or 0/1/2/3/5/6/7) at
the prescribed static DMA sequence
Start the DMA
Return and wait for DMA channel 4 ( or 0/1/2/3/5/6/7)
command complete interrupt.
APBH DMA CH4 Command
Complete ISR
HW_APBH_CTRL1_CH0_CMDCMPLT_IRQ = 0
STOP
Must use SCT clear
Start GPMI DMA chain for next write or read transfer
BCH Complete ISR
Read status regs and store for processing
STOP
HW_BCH_CTRL_COMPLETE_IRQ = 0
Must use SCT clear
Figure 17-9. BCH Decode Flowchart
Conceptually, an APHB DMA Channel (0,1,2 or 3) command chain with seven command
structures linked together is used to perform the BCH decode operation (as shown in
Figure 17-10).
Note
The GPMI's DMA command structures controls the BCH
decode operation.
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
583

<!-- page 584 -->

To use the BCH decoder with the GPMI's DMA, create a DMA command chain
containing seven descriptor structures, as shown in the figure below and detailed in the
DMA structure code example that follows it in DMA Structure Code Example. The seven
DMA descriptors perform the following tasks:
1. Issue NAND read setup command byte (under "CLE") and address bytes (under
"ALE").
2. Issue NAND read execute command byte (under "CLE").
3. Wait for the NAND device to complete accessing the block data by watching the
ready signal.
4. Check for NAND timeout through "PSENSE".
5. Configure and enable the BCH block and read the NAND block data.
6. Disable the BCH block.
7. Descriptor NOP to allow NANDLOCK in the previous descriptor to the thread-safe.
Programming the BCH/GPMI Interfaces
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
584
NXP Semiconductors

<!-- page 585 -->

CMD                 <=
1 + 5
3
1
0
0
1 0 1
DMA_READ
HW_GPMI_CTRL0     <=
write
8_bit
enabled
2
NAND_CLE
1
HW_GPMI_COMPARE <=
HW_GPMI_ECCCTRL <=
1
1
1
0
0
1 0 1
DMA_READ
write
8_bit disabled 2
NAND_CLE 0
0
1
1
0
1
0 0 1 NO_DMA_XFER
wait_for_ready
8_bit
disabled 2 NAND_DATA
0
0
0
0
0
0
0 0 1
DMA_SENSE
0
6
1
0
0
1 0 1 NO_DMA_XFER
HW_GPMI_CTRL0    <=
read
8_bit disabled
2 NAND_DATA
0
HW_GPMI_COMPARE <=
HW_GPMI_ECCCTRL <=
HW_GPMI_ECCCOUNT<=
CMD                 <=
0
3
1
0
1
1 0 1 NO_DMA_XFER
HW_GPMI_CTRL0
<=
wait_for_ready
8_bit
_
disabled 0
NAND_DATA
0
HW_GPMI_COMPARE <=
HW_GPMI_ECCCTRL <=
CMD
<=
0
0
0
0
0
0 0 0 NO_DMA_XFER
Descriptor 7: NOP to ensure NANDLOCK in previous descriptor .
NEXT CMD ADDR
BUFFER ADDR
Descriptor 1: Disable BCH engine and issue NAND read set-up command and address (CLE/ALE).
----
disable
----
NEXT CMD ADDR
BUFFER ADDR
1 + 5
null
null
Descriptor 2: NAND read execute command (CLE).
NEXT CMD ADDR
BUFFER ADDR
----
disable
----
1
0
null
null
NEXT CMD ADDR
Descriptor 3: Wait for NAND ready.
NEXT CMD ADDR
BUFFER ADDR
BUFFER ADDR
0
Descriptor 4: PSENSE compare for time-out.
NEXT CMD ADDR
BUFFER ADDR
Descriptor 5: Enable BCH engine and read NAND data.
NEXT CMD ADDR
BUFFER ADDR
4096+218
null
null
HW_GPMI_PAYLOAD
HW_GPMI_AUXILIARY
Descriptor 6: Disable BCH engine (wait for ready is a NOP here).
decode_8_bit
enable
0x1FF
4096+218 (flash page size)
1 Byte NAND CMD
5 Byte ADDR
1 Byte NAND CMD
DMA Error 
Descriptor Chain
8*512 Byte Data
Payload Buffer
412 Byte Auxiliary
Payload Buffer
CMD                 <=
HW_GPMI_CTRL0     <=
HW_GPMI_CTRL0     <=
CMD                 <=
CMD                 <=
CMD                 <=
Figure 17-10. BCH Decode DMA Descriptor Chain
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
585

<!-- page 586 -->

17.4.2.1
DMA Structure Code Example
The following sample code illustrates the coding for one read transaction, consisting of a
seven DMA command structure chain for reading all 4096 bytes of payload data (eight
512-byte blocks) and 65 bytes of metadata with the associative parity bytes (8 * (18) + 9)
from a 4K NAND page sitting on GPMI CS2.
//----------------------------------------------------------------------------
// generic DMA/GPMI/ECC descriptor struct, order sensitive!
//----------------------------------------------------------------------------
typedef struct {
  // DMA related fields
  unsigned int dma_nxtcmdar;
  unsigned int dma_cmd;
  unsigned int dma_bar;
  // GPMI related fields
  unsigned int gpmi_ctrl0;
  unsigned int gpmi_compare;
  unsigned int gpmi_eccctrl;
  unsigned int gpmi_ecccount;
  unsigned int gpmi_data_ptr;
  unsigned int gpmi_aux_ptr;
} GENERIC_DESCRIPTOR;
//----------------------------------------------------------------------------
// allocate 7 descriptors for doing a NAND ECC Read
//----------------------------------------------------------------------------
GENERIC_DESCRIPTOR read[7];
//----------------------------------------------------------------------------
// DMA descriptor pointer to handle error conditions from psense checks
//----------------------------------------------------------------------------
unsigned int * dma_error_handler;
//----------------------------------------------------------------------------
// 7 byte NAND command and address buffer
// any alignment is ok, it is read by the GPMI DMA
//   byte 0 is read setup command
//   bytes 1-5 is the NAND address
//   byte 6 is read execute command
//----------------------------------------------------------------------------
unsigned char nand_cmd_addr_buffer[7];
//----------------------------------------------------------------------------
// 4096 byte payload buffer used for reads or writes
// needs to be word aligned
//----------------------------------------------------------------------------
unsigned int read_payload_buffer[(4096/4)];
//----------------------------------------------------------------------------
// 412 byte auxiliary buffer used for reads
// needs to be word aligned
//----------------------------------------------------------------------------
unsigned int read_aux_buffer[(412/4)];
//----------------------------------------------------------------------------
// Descriptor 1: issue NAND read setup command (CLE/ALE)
//----------------------------------------------------------------------------
read[0].dma_nxtcmdar = &read[1];                           // point to the next descriptor
read[0].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (1 + 5) |  // 1 byte command, 5 byte address
                  BF_APBH_CHn_CMD_CMDWORDS      (3)     |  // send 3 words to the GPMI
                  BF_APBH_CHn_CMD_WAIT4ENDCMD   (1)     |  // wait for command to finish
                                                           //     before continuing
                  BF_APBH_CHn_CMD_SEMAPHORE     (0)     |
                  BF_APBH_CHn_CMD_NANDWAIT4READY(0)     |
                  BF_APBH_CHn_CMD_NANDLOCK      (1)     |  // prevent other DMA channels from
                                                           //    taking over
                  BF_APBH_CHn_CMD_IRQONCMPLT    (0)     |
Programming the BCH/GPMI Interfaces
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
586
NXP Semiconductors

<!-- page 587 -->

                  BF_APBH_CHn_CMD_CHAIN         (1)     |   // follow chain to next command
                  BV_FLD(APBH_CHn_CMD, COMMAND, DMA_READ);  // read data from DMA, write to 
NAND
read[0].dma_bar = &nand_cmd_addr_buffer;            // byte 0 read setup, bytes 1 - 5 NAND 
address
// 3 words sent to the GPMI
read[0].gpmi_ctrl0 = BV_FLD(GPMI_CTRL0, COMMAND_MODE, WRITE)    | // write to the NAND
                     BV_FLD(GPMI_CTRL0, WORD_LENGTH,  8_BIT)    |
                     BV_FLD(GPMI_CTRL0, LOCK_CS,      ENABLED)  |
                     BF_GPMI_CTRL0_CS                 (2)       | // must correspond to NAND 
CS used
                     BV_FLD(GPMI_CTRL0, ADDRESS,      NAND_CLE) |
                     BF_GPMI_CTRL0_ADDRESS_INCREMENT  (1)       | // send command and address
                     BF_GPMI_CTRL0_XFER_COUNT         (1 + 5);    // 1 byte command, 5 byte 
address
read[0].gpmi_compare = NULL;                          // field not used but necessary to set 
eccctrl
read[0].gpmi_eccctrl = BV_FLD(GPMI_ECCCTRL, ENABLE_ECC, DISABLE); // disable the ECC block
//----------------------------------------------------------------------------
// Descriptor 2: issue NAND read execute command (CLE)
//----------------------------------------------------------------------------
read[1].dma_nxtcmdar = &read[2];                           // point to the next descriptor
read[1].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (1)    |   // 1 byte read command
                  BF_APBH_CHn_CMD_CMDWORDS      (1)    |   // send 1 word to GPMI
                  BF_APBH_CHn_CMD_WAIT4ENDCMD   (1)    |   // wait for command to finish 
before
                                                           //    continuing
                  BF_APBH_CHn_CMD_SEMAPHORE     (0)    |
                  BF_APBH_CHn_CMD_NANDWAIT4READY(0)    |
                  BF_APBH_CHn_CMD_NANDLOCK      (1)    |   // prevent other DMA channels from
                                                           //     taking over
                  BF_APBH_CHn_CMD_IRQONCMPLT    (0)    |
                  BF_APBH_CHn_CMD_CHAIN         (1)    |   // follow chain to next command
                  BV_FLD(APBH_CHn_CMD, COMMAND, DMA_READ);     // read data from DMA, write 
to NAND
read[1].dma_bar = &nand_cmd_addr_buffer[6];               // point to byte 6, read execute 
command
// 1 word sent to the GPMI
read[1].gpmi_ctrl0 = BV_FLD(GPMI_CTRL0, COMMAND_MODE, WRITE)    | // write to the NAND
                     BV_FLD(GPMI_CTRL0, WORD_LENGTH,  8_BIT)    |
                     BV_FLD(GPMI_CTRL0, LOCK_CS,      DISABLED) |
                     BF_GPMI_CTRL0_CS                 (2)       | // must correspond to NAND 
CS used
                     BV_FLD(GPMI_CTRL0, ADDRESS,      NAND_CLE) |
                     BF_GPMI_CTRL0_ADDRESS_INCREMENT  (0)       |
                     BF_GPMI_CTRL0_XFER_COUNT         (1);        // 1 byte command
//----------------------------------------------------------------------------
// Descriptor 3: wait for ready (DATA)
//----------------------------------------------------------------------------
read[2].dma_nxtcmdar = &read[3];                           // point to the next descriptor
read[2].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (0)      | // no dma transfer
                  BF_APBH_CHn_CMD_CMDWORDS      (1)      | // send 1 word to GPMI
                  BF_APBH_CHn_CMD_WAIT4ENDCMD   (1)      | // wait for command to finish 
before
                                                           //     continuing
                  BF_APBH_CHn_CMD_SEMAPHORE     (0)      |
                  BF_APBH_CHn_CMD_NANDWAIT4READY(1)      | // wait for nand to be ready
                  BF_APBH_CHn_CMD_NANDLOCK      (0)      | // relinquish nand lock
                  BF_APBH_CHn_CMD_IRQONCMPLT    (0)      |
                  BF_APBH_CHn_CMD_CHAIN         (1)      | // follow chain to next command
                  BV_FLD(APBH_CHn_CMD, COMMAND, NO_DMA_XFER);   // no dma transfer
read[2].dma_bar = NULL;                                         // field not used
// 1 word sent to the GPMI
read[2].gpmi_ctrl0 = BV_FLD(GPMI_CTRL0, COMMAND_MODE, WAIT_FOR_READY) | // wait for NAND 
ready
                     BV_FLD(GPMI_CTRL0, WORD_LENGTH,  8_BIT)          |
                     BV_FLD(GPMI_CTRL0, LOCK_CS,      DISABLED)       |
                     BF_GPMI_CTRL0_CS                 (2)             | // must correspond 
to NAND CS used
                     BV_FLD(GPMI_CTRL0, ADDRESS,      NAND_DATA)      |
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
587

<!-- page 588 -->

                     BF_GPMI_CTRL0_ADDRESS_INCREMENT  (0)             |
                     BF_GPMI_CTRL0_XFER_COUNT         (0);
//----------------------------------------------------------------------------
// Descriptor 4: psense compare (time out check)
//----------------------------------------------------------------------------
read[3].dma_nxtcmdar = &read[4];                                  // point to the next 
descriptor
read[3].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (0)        |      // no dma transfer
                  BF_APBH_CHn_CMD_CMDWORDS      (0)        |      // no words sent to GPMI
                  BF_APBH_CHn_CMD_WAIT4ENDCMD   (0)        |      // do not wait to continue
                  BF_APBH_CHn_CMD_SEMAPHORE     (0)        |
                  BF_APBH_CHn_CMD_NANDWAIT4READY(0)        |
                  BF_APBH_CHn_CMD_NANDLOCK      (0)        |
                  BF_APBH_CHn_CMD_IRQONCMPLT    (0)        |
                  BF_APBH_CHn_CMD_CHAIN         (1)        |      // follow chain to next 
command
                  BV_FLD(APBH_CHn_CMD, COMMAND, DMA_SENSE);       // perform a sense check
read[3].dma_bar = dma_error_handler;                      // if sense check fails, branch to 
error handler
//----------------------------------------------------------------------------
// Descriptor 5: read 4K page plus 65 byte meta-data Nand data
//               and send it to ECC block (DATA)
//----------------------------------------------------------------------------
read[4].dma_nxtcmdar = &read[5];                        // point to the next descriptor
read[4].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (0)   | // no dma transfer
                  BF_APBH_CHn_CMD_CMDWORDS      (6)   | // send 6 words to GPMI
                  BF_APBH_CHn_CMD_WAIT4ENDCMD   (1)   | // wait for command to finish before
                                                        //       continuing
                  BF_APBH_CHn_CMD_SEMAPHORE     (0)   |
                  BF_APBH_CHn_CMD_NANDWAIT4READY(0)   |
                  BF_APBH_CHn_CMD_NANDLOCK      (1)   | // prevent other DMA channels from 
taking over
                  BF_APBH_CHn_CMD_IRQONCMPLT    (0)   | // ECC block generates BCH interrupt
                                                        //      on completion
                  BF_APBH_CHn_CMD_CHAIN         (1)   | // follow chain to next command
                  BV_FLD(APBH_CHn_CMD, COMMAND, NO_DMA_XFER);     // no DMA transfer, 
                                                                  // ECC block handles 
transfer
read[4].dma_bar = NULL;                                           // field not used
// 6 words sent to the GPMI
read[4].gpmi_ctrl0 = BV_FLD(GPMI_CTRL0, COMMAND_MODE, READ)       |  // read from the NAND
                     BV_FLD(GPMI_CTRL0, WORD_LENGTH,  8_BIT)      |
                     BV_FLD(GPMI_CTRL0, LOCK_CS,      DISABLED)   |
                     BF_GPMI_CTRL0_CS                 (2)         |  // must correspond to 
NAND CS used
                     BV_FLD(GPMI_CTRL0, ADDRESS,      NAND_DATA)  |
                     BF_GPMI_CTRL0_ADDRESS_INCREMENT  (0)         |
                     BF_GPMI_CTRL0_XFER_COUNT         (4096+218);    // eight 512 byte data 
blocks 
                                                                     // metadata, and parity
                                                                      
read[4].gpmi_compare = NULL;                          // field not used but necessary to set 
eccctrl
// GPMI ECCCTRL PIO This launches the 4K byte transfer through BCH's
// bus master. Setting the ECC_ENABLE bit redirects the data flow
// within the GPMI so that read data flows to the BCH engine instead
// of flowing to the GPMI's DMA channel.
read[4].gpmi_eccctrl = BV_FLD(GPMI_ECCCTRL, ECC_CMD,    DECODE_8_BIT) |    // specify t = 8 
mode
                       BV_FLD(GPMI_ECCCTRL, ENABLE_ECC, ENABLE)       |    // enable ECC 
module
                       BF_GPMI_ECCCTRL_BUFFER_MASK     (0X1FF);  // read all 8 data blocks 
and 1 aux block
read[4].gpmi_ecccount = BF_GPMI_ECCCOUNT_COUNT(4096+218);        // specify number of bytes
                                                                 //        read from NAND
read[4].gpmi_data_ptr = &read_payload_buffer;                    // pointer for the 4K byte
                                                                 //    data area
read[4].gpmi_aux_ptr = &read_aux_buffer;                         // pointer for the 65 byte 
aux area +
                                                                 // parity and syndrome 
Programming the BCH/GPMI Interfaces
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
588
NXP Semiconductors

<!-- page 589 -->

bytes for both
                                                                // data and aux blocks.
//----------------------------------------------------------------------------
// Descriptor 6: disable ECC block
//----------------------------------------------------------------------------
read[5].dma_nxtcmdar = &read[6];                           // point to the next descriptor
read[5].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (0)      | // no dma transfer
                  BF_APBH_CHn_CMD_CMDWORDS      (3)      | // send 3 words to GPMI
                  BF_APBH_CHn_CMD_WAIT4ENDCMD   (1)      | // wait for command to finish 
before
                                                           //     continuing
                  BF_APBH_CHn_CMD_SEMAPHORE     (0)      |
                  BF_APBH_CHn_CMD_NANDWAIT4READY(1)      | // wait for nand to be ready
                  BF_APBH_CHn_CMD_NANDLOCK      (1)      | // need nand lock to be 
                                                           // thread safe while turn-off BCH
                  BF_APBH_CHn_CMD_IRQONCMPLT    (0)      |
                  BF_APBH_CHn_CMD_CHAIN         (1)      | // follow chain to next command
                  BV_FLD(APBH_CHn_CMD, COMMAND, NO_DMA_XFER);      // no dma transfer
read[5].dma_bar = NULL;                                            // field not used
// 3 words sent to the GPMI
read[5].gpmi_ctrl0 = BV_FLD(GPMI_CTRL0, COMMAND_MODE, READ)      |
                     BV_FLD(GPMI_CTRL0, WORD_LENGTH,  8_BIT)     |
                     BV_FLD(GPMI_CTRL0, LOCK_CS,      DISABLED)  |
                     BF_GPMI_CTRL0_CS                 (2)        | // must correspond to 
NAND CS used
                     BV_FLD(GPMI_CTRL0, ADDRESS,      NAND_DATA) |
                     BF_GPMI_CTRL0_ADDRESS_INCREMENT  (0)        |
                     BF_GPMI_CTRL0_XFER_COUNT         (0);
read[5].gpmi_compare = NULL;                          // field not used but necessary to set 
eccctrl
read[5].gpmi_eccctrl = BV_FLD(GPMI_ECCCTRL, ENABLE_ECC, DISABLE);  // disable the ECC block
//----------------------------------------------------------------------------
// Descriptor 7: deassert nand lock
//----------------------------------------------------------------------------
read[6].dma_nxtcmdar = NULL;                               // not used since this is last 
descriptor
read[6].dma_cmd = BF_APBH_CHn_CMD_XFER_COUNT    (0)   |    // no dma transfer
                  BF_APBH_CHn_CMD_CMDWORDS      (0)   |    // no words sent to GPMI
                  BF_APBH_CHn_CMD_WAIT4ENDCMD   (0)   |    // wait for command to finish 
before
                                                           //        continuing
                  BF_APBH_CHn_CMD_SEMAPHORE     (0)   |
                  BF_APBH_CHn_CMD_NANDWAIT4READY(0)   |
                  BF_APBH_CHn_CMD_NANDLOCK      (0)   |    // relinquish nand lock
                  BF_APBH_CHn_CMD_IRQONCMPLT    (0)   |    // BCH engine generates interrupt
                  BF_APBH_CHn_CMD_CHAIN         (0)   |    // terminate DMA chain processing
                  BV_FLD(APBH_CHn_CMD, COMMAND, NO_DMA_XFER);      // no dma transfer
read[6].dma_bar = NULL;                                            // field not used
17.4.2.2
Using the Decoder
As illustrated in Figure 17-10 and the sample code in DMA Structure Code Example :
• DMA descriptor 1 prepares the NAND for data read by using the GPMI to issue a
NAND read setup command byte under CLE, then sends a 5-byte address under
ALE. The BCH engine is not used for these commands.
• DMA descriptor 2 issues a one-byte read execute command to the NAND device that
triggers its read access. The NAND then goes not ready.
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
589

<!-- page 590 -->

• DMA descriptor 3 performs a wait for ready operation allowing the DMA chain to
remain dormant until the NAND device completes its read access time.
• DMA descriptor 5 handles the reading and error correction of the NAND data. This
command's PIOs activate the BCH engine to write the read NAND data to system
memory and to process it for any errors that need to be corrected. This DMA
descriptor contains two PIO values that are system memory addresses pointing to the
PAYLOAD data area and to the AUXILIARY data area. These addresses are used by
the BCH engine's AHB master to move data into system memory and to correct it.
While this example is reading an entire 4K page—payload plus metadata—it is
equally possible to read just one 512-byte payload block or just the uniquely
protected metadata block in a single 7 DMA structure transfer.
• DMA descriptor 6 disables the BCH engine with the NANDLOCK asserted. This is
necessary to ensure that the GPMI resource is not arbitrated to another DMA channel
when multiple DMA channels are active concurrently.
• DMA descriptor 7 de-asserts the NANDLOCK to free up the GPMI resource to
another channel.
As the BCH block receives data from the GPMI:
• The decoder transforms the read NAND data block into a BCH code word and
computes the codeword syndrome.
• If no errors are present, then the BCH block can immediately report back to
firmware. This report is passed as the BCH_CTRL_COMPLETE_IRQ interrupt
status bit and the associated status registers in BCH_STATUS0/1 registers.
• If an error is present, then the BCH block corrects the necessary data block or parity
block bytes, if possible (not all errors are correctable).
As the BCH decoder reads the data and parity blocks, it records a special condition, i.e.,
that all of the bits of a payload data block or metadata block are one, including any
associated parity bytes. The all-ones case for both parity and data indicates an erased
block in the NAND device.
The BCH_STATUS0 register contains a 4-bit field that indicates the final status of the
auxiliary block. A value of 0x0 indicates no errors found for a block.
• A value of 1 to 20 inclusive indicates that many correctable errors were found and
fixed.
• A value of 0xFE indicates uncorrectable errors detected on the block.
Programming the BCH/GPMI Interfaces
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
590
NXP Semiconductors

<!-- page 591 -->

• A value of 0xFF indicates that the block was in the special ALL ONES state and is
therefore considered to be an ERASED block.
• All other values are disallowed by the hardware design.
Recall that up to eight NAND devices can have DMA chains in-flight at once, i.e. they
can all be contending for access to the GPMI data bus. It is impossible to predict which
NAND device will enter the BCH engine with a transfer first, because each chain
includes a wait4ready command structure. As a result, firmware should look at the
BCH_STATUS0_COMPLETED_CE bit field to determine which block is being reported
in the status register. There is also a 16-bit HANDLE field in the GPMI_ECCCTRL
register that is passed down the pipeline with each transaction. This handle field can be
used to speed firmware's detection of which transaction is being reported.
These examples of reading and writing have focused on full page transfers of 4K page
NAND devices. Other device configurations can be specified by changing the
ECCOUNT field in the GPMI registers and reprogramming the BCH's
FLASHnLAYOUTm registers.
The BCH and GPMI blocks are designed to be very efficient at reading single 512 (or
1024)-byte pages in one transaction. With no errors, the transaction takes less than 20
HCLKs longer than the time to read the raw data from the NAND.
To summarize, the APBH DMA command chain for a BCH decode operation is shown in
Figure 17-10. Seven DMA command structures must be present for each NAND read
transaction decoded by the BCH. The seven DMA command structures for multiple
NAND read transaction blocks can be chained together to make larger units of work for
the BCH, and each will produce an appropriate error report in the BCH PIO space.
Multiple NAND devices can have such multiple chains scheduled. The results can come
back out of order with respect to the multiple chains.
17.4.3
Interrupts
There are two interrupt sources used in processing BCH protected NAND read and write
transfers.
Since all BCH operations are initiated by GPMI DMA command structures, the DMA
completion interrupt for the GPMI is an important ISR. Both of the flow charts of Figure
17-6 and Figure 17-9 show the GPMI DMA complete ISR skeleton. In both reads and
writes, the GPMI DMA completion interrupt is used to schedule work INTO the error
correction pipeline. As the front end processing completes, the DMA interrupt is
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
591

<!-- page 592 -->

generated and additional work, such as DMA chains, are passed to the GPMI DMA to
keep it fed. For write operations, this is the only interrupt that is generated for processing
the NAND write transfer.
For reads, however, two interrupts are needed. Every read is started by a GPMI DMA
command chain and the front end queue is fed as described above. The back end of the
read pipeline is drained by monitoring the BCH completion interrupt found int
HW_BCH_CTRL_COMPLETE_IRQ.
An BCH transaction consists of reading or writing all of the blocks requested in the
HW_GPMI_ECCCTRL_BUFFER_MASK bit field. As every read transaction completes,
it posts the status of all of the blocks to the HW_BCH_STATUS0 and
HW_BCH_STATUS1 registers and sets the completion interrupt. The five stages of the
BCH read pipeline completes, one in the GPMI and four in the BCH, are independently
stalled as they complete and try to deliver to the next stage in the data flow. Several of
these stages can be skipped if no-errors are found or once an uncorrectable error is found
in a block.
In any case, the final stage will stall if the status register is busy waiting for the CPU to
take status register results. The hardware monitors the state of the
HW_BCH_CTRL_COMPLETE_IRQ bit. If it is still set when the last pipeline stage is
ready to post data, then the stage will stall. It follows that the next previous stage will
stall when it is ready to hand off work to the final stage, and so on up the pipeline.
CAUTION
It is important that firmware read the STATUS0/1 results and
save them before clearing the interrupt request bit. Otherwise, a
transaction and its results could be completely lost.
17.5
Behavior During Reset
A soft reset (SFTRST) can take multiple clock periods to complete, so do NOT set
CLKGATE when setting SFTRST.
The reset process gates the clocks automatically. The example code is shown below.
// A soft reset can take multiple clocks to complete, so do NOT gate the
// clock when setting soft reset. The reset process will gate the clock
// automatically. Poll until this has happened before subsequently
// preparing soft-reset and clock gate
  BCH_CTRL_CLR(BM_BCH_CTRL_SFTRST);
  BCH_CTRL_CLR(BM_BCH_CTRL_CLKGATE);
// asserting soft-reset
  BCH_CTRL_SET(BM_BCH_CTRL_SFTRST);
// waiting for confirmation of soft-reset
  while (!BCH_CTRL.B.CLKGATE)
Behavior During Reset
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
592
NXP Semiconductors

<!-- page 593 -->

  {
// busy wait
  }
// Done.
  BCH_CTRL_CLR(BM_BCH_CTRL_SFTRST);
  BCH_CTRL_CLR(BM_BCH_CTRL_CLKGATE);
17.6
BCH Memory Map/Register Definition
BCH Hardware Register Format Summary
BCH memory map
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
180_8000
Hardware BCH ECC Accelerator Control Register
(BCH_CTRL)
32
R/W
C000_0000h
17.6.1/597
180_8004
Hardware BCH ECC Accelerator Control Register
(BCH_CTRL_SET)
32
R/W
C000_0000h
17.6.1/597
180_8008
Hardware BCH ECC Accelerator Control Register
(BCH_CTRL_CLR)
32
R/W
C000_0000h
17.6.1/597
180_800C
Hardware BCH ECC Accelerator Control Register
(BCH_CTRL_TOG)
32
R/W
C000_0000h
17.6.1/597
180_8010
Hardware ECC Accelerator Status Register 0
(BCH_STATUS0)
32
R
0000_0010h
17.6.2/599
180_8014
Hardware ECC Accelerator Status Register 0
(BCH_STATUS0_SET)
32
R
0000_0010h
17.6.2/599
180_8018
Hardware ECC Accelerator Status Register 0
(BCH_STATUS0_CLR)
32
R
0000_0010h
17.6.2/599
180_801C
Hardware ECC Accelerator Status Register 0
(BCH_STATUS0_TOG)
32
R
0000_0010h
17.6.2/599
180_8020
Hardware ECC Accelerator Mode Register (BCH_MODE)
32
R/W
0000_0000h
17.6.3/601
180_8024
Hardware ECC Accelerator Mode Register
(BCH_MODE_SET)
32
R/W
0000_0000h
17.6.3/601
180_8028
Hardware ECC Accelerator Mode Register
(BCH_MODE_CLR)
32
R/W
0000_0000h
17.6.3/601
180_802C
Hardware ECC Accelerator Mode Register
(BCH_MODE_TOG)
32
R/W
0000_0000h
17.6.3/601
180_8030
Hardware BCH ECC Loopback Encode Buffer Register
(BCH_ENCODEPTR)
32
R/W
0000_0000h
17.6.4/602
180_8034
Hardware BCH ECC Loopback Encode Buffer Register
(BCH_ENCODEPTR_SET)
32
R/W
0000_0000h
17.6.4/602
180_8038
Hardware BCH ECC Loopback Encode Buffer Register
(BCH_ENCODEPTR_CLR)
32
R/W
0000_0000h
17.6.4/602
180_803C
Hardware BCH ECC Loopback Encode Buffer Register
(BCH_ENCODEPTR_TOG)
32
R/W
0000_0000h
17.6.4/602
Table continues on the next page...
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
593

<!-- page 594 -->

BCH memory map (continued)
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
180_8040
Hardware BCH ECC Loopback Data Buffer Register
(BCH_DATAPTR)
32
R/W
0000_0000h
17.6.5/602
180_8044
Hardware BCH ECC Loopback Data Buffer Register
(BCH_DATAPTR_SET)
32
R/W
0000_0000h
17.6.5/602
180_8048
Hardware BCH ECC Loopback Data Buffer Register
(BCH_DATAPTR_CLR)
32
R/W
0000_0000h
17.6.5/602
180_804C
Hardware BCH ECC Loopback Data Buffer Register
(BCH_DATAPTR_TOG)
32
R/W
0000_0000h
17.6.5/602
180_8050
Hardware BCH ECC Loopback Metadata Buffer Register
(BCH_METAPTR)
32
R/W
0000_0000h
17.6.6/603
180_8054
Hardware BCH ECC Loopback Metadata Buffer Register
(BCH_METAPTR_SET)
32
R/W
0000_0000h
17.6.6/603
180_8058
Hardware BCH ECC Loopback Metadata Buffer Register
(BCH_METAPTR_CLR)
32
R/W
0000_0000h
17.6.6/603
180_805C
Hardware BCH ECC Loopback Metadata Buffer Register
(BCH_METAPTR_TOG)
32
R/W
0000_0000h
17.6.6/603
180_8070
Hardware ECC Accelerator Layout Select Register
(BCH_LAYOUTSELECT)
32
R/W
E4E4_E4E4h
17.6.7/603
180_8074
Hardware ECC Accelerator Layout Select Register
(BCH_LAYOUTSELECT_SET)
32
R/W
E4E4_E4E4h
17.6.7/603
180_8078
Hardware ECC Accelerator Layout Select Register
(BCH_LAYOUTSELECT_CLR)
32
R/W
E4E4_E4E4h
17.6.7/603
180_807C
Hardware ECC Accelerator Layout Select Register
(BCH_LAYOUTSELECT_TOG)
32
R/W
E4E4_E4E4h
17.6.7/603
180_8080
Hardware BCH ECC Flash 0 Layout 0 Register
(BCH_FLASH0LAYOUT0)
32
R/W
070A_4080h
17.6.8/604
180_8084
Hardware BCH ECC Flash 0 Layout 0 Register
(BCH_FLASH0LAYOUT0_SET)
32
R/W
070A_4080h
17.6.8/604
180_8088
Hardware BCH ECC Flash 0 Layout 0 Register
(BCH_FLASH0LAYOUT0_CLR)
32
R/W
070A_4080h
17.6.8/604
180_808C
Hardware BCH ECC Flash 0 Layout 0 Register
(BCH_FLASH0LAYOUT0_TOG)
32
R/W
070A_4080h
17.6.8/604
180_8090
Hardware BCH ECC Flash 0 Layout 1 Register
(BCH_FLASH0LAYOUT1)
32
R/W
10DA_4080h
17.6.9/606
180_8094
Hardware BCH ECC Flash 0 Layout 1 Register
(BCH_FLASH0LAYOUT1_SET)
32
R/W
10DA_4080h
17.6.9/606
180_8098
Hardware BCH ECC Flash 0 Layout 1 Register
(BCH_FLASH0LAYOUT1_CLR)
32
R/W
10DA_4080h
17.6.9/606
180_809C
Hardware BCH ECC Flash 0 Layout 1 Register
(BCH_FLASH0LAYOUT1_TOG)
32
R/W
10DA_4080h
17.6.9/606
180_80A0
Hardware BCH ECC Flash 1 Layout 0 Register
(BCH_FLASH1LAYOUT0)
32
R/W
070A_4080h
17.6.10/
607
180_80A4
Hardware BCH ECC Flash 1 Layout 0 Register
(BCH_FLASH1LAYOUT0_SET)
32
R/W
070A_4080h
17.6.10/
607
Table continues on the next page...
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
594
NXP Semiconductors

<!-- page 595 -->

BCH memory map (continued)
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
180_80A8
Hardware BCH ECC Flash 1 Layout 0 Register
(BCH_FLASH1LAYOUT0_CLR)
32
R/W
070A_4080h
17.6.10/
607
180_80AC
Hardware BCH ECC Flash 1 Layout 0 Register
(BCH_FLASH1LAYOUT0_TOG)
32
R/W
070A_4080h
17.6.10/
607
180_80B0
Hardware BCH ECC Flash 1 Layout 1 Register
(BCH_FLASH1LAYOUT1)
32
R/W
10DA_4080h
17.6.11/
609
180_80B4
Hardware BCH ECC Flash 1 Layout 1 Register
(BCH_FLASH1LAYOUT1_SET)
32
R/W
10DA_4080h
17.6.11/
609
180_80B8
Hardware BCH ECC Flash 1 Layout 1 Register
(BCH_FLASH1LAYOUT1_CLR)
32
R/W
10DA_4080h
17.6.11/
609
180_80BC
Hardware BCH ECC Flash 1 Layout 1 Register
(BCH_FLASH1LAYOUT1_TOG)
32
R/W
10DA_4080h
17.6.11/
609
180_80C0
Hardware BCH ECC Flash 2 Layout 0 Register
(BCH_FLASH2LAYOUT0)
32
R/W
070A_4080h
17.6.12/
610
180_80C4
Hardware BCH ECC Flash 2 Layout 0 Register
(BCH_FLASH2LAYOUT0_SET)
32
R/W
070A_4080h
17.6.12/
610
180_80C8
Hardware BCH ECC Flash 2 Layout 0 Register
(BCH_FLASH2LAYOUT0_CLR)
32
R/W
070A_4080h
17.6.12/
610
180_80CC
Hardware BCH ECC Flash 2 Layout 0 Register
(BCH_FLASH2LAYOUT0_TOG)
32
R/W
070A_4080h
17.6.12/
610
180_80D0
Hardware BCH ECC Flash 2 Layout 1 Register
(BCH_FLASH2LAYOUT1)
32
R/W
10DA_4080h
17.6.13/
612
180_80D4
Hardware BCH ECC Flash 2 Layout 1 Register
(BCH_FLASH2LAYOUT1_SET)
32
R/W
10DA_4080h
17.6.13/
612
180_80D8
Hardware BCH ECC Flash 2 Layout 1 Register
(BCH_FLASH2LAYOUT1_CLR)
32
R/W
10DA_4080h
17.6.13/
612
180_80DC
Hardware BCH ECC Flash 2 Layout 1 Register
(BCH_FLASH2LAYOUT1_TOG)
32
R/W
10DA_4080h
17.6.13/
612
180_80E0
Hardware BCH ECC Flash 3 Layout 0 Register
(BCH_FLASH3LAYOUT0)
32
R/W
070A_4080h
17.6.14/
613
180_80E4
Hardware BCH ECC Flash 3 Layout 0 Register
(BCH_FLASH3LAYOUT0_SET)
32
R/W
070A_4080h
17.6.14/
613
180_80E8
Hardware BCH ECC Flash 3 Layout 0 Register
(BCH_FLASH3LAYOUT0_CLR)
32
R/W
070A_4080h
17.6.14/
613
180_80EC
Hardware BCH ECC Flash 3 Layout 0 Register
(BCH_FLASH3LAYOUT0_TOG)
32
R/W
070A_4080h
17.6.14/
613
180_80F0
Hardware BCH ECC Flash 3 Layout 1 Register
(BCH_FLASH3LAYOUT1)
32
R/W
10DA_4080h
17.6.15/
615
180_80F4
Hardware BCH ECC Flash 3 Layout 1 Register
(BCH_FLASH3LAYOUT1_SET)
32
R/W
10DA_4080h
17.6.15/
615
180_80F8
Hardware BCH ECC Flash 3 Layout 1 Register
(BCH_FLASH3LAYOUT1_CLR)
32
R/W
10DA_4080h
17.6.15/
615
180_80FC
Hardware BCH ECC Flash 3 Layout 1 Register
(BCH_FLASH3LAYOUT1_TOG)
32
R/W
10DA_4080h
17.6.15/
615
Table continues on the next page...
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
595

<!-- page 596 -->

BCH memory map (continued)
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
180_8100
Hardware BCH ECC Debug Register0 (BCH_DEBUG0)
32
R/W
0000_0000h
17.6.16/
616
180_8104
Hardware BCH ECC Debug Register0
(BCH_DEBUG0_SET)
32
R/W
0000_0000h
17.6.16/
616
180_8108
Hardware BCH ECC Debug Register0
(BCH_DEBUG0_CLR)
32
R/W
0000_0000h
17.6.16/
616
180_810C
Hardware BCH ECC Debug Register0
(BCH_DEBUG0_TOG)
32
R/W
0000_0000h
17.6.16/
616
180_8110
KES Debug Read Register (BCH_DBGKESREAD)
32
R
0000_0000h
17.6.17/
618
180_8114
KES Debug Read Register (BCH_DBGKESREAD_SET)
32
R
0000_0000h
17.6.17/
618
180_8118
KES Debug Read Register (BCH_DBGKESREAD_CLR)
32
R
0000_0000h
17.6.17/
618
180_811C
KES Debug Read Register (BCH_DBGKESREAD_TOG)
32
R
0000_0000h
17.6.17/
618
180_8120
Chien Search Debug Read Register
(BCH_DBGCSFEREAD)
32
R
0000_0000h
17.6.18/
619
180_8124
Chien Search Debug Read Register
(BCH_DBGCSFEREAD_SET)
32
R
0000_0000h
17.6.18/
619
180_8128
Chien Search Debug Read Register
(BCH_DBGCSFEREAD_CLR)
32
R
0000_0000h
17.6.18/
619
180_812C
Chien Search Debug Read Register
(BCH_DBGCSFEREAD_TOG)
32
R
0000_0000h
17.6.18/
619
180_8130
Syndrome Generator Debug Read Register
(BCH_DBGSYNDGENREAD)
32
R
0000_0000h
17.6.19/
619
180_8134
Syndrome Generator Debug Read Register
(BCH_DBGSYNDGENREAD_SET)
32
R
0000_0000h
17.6.19/
619
180_8138
Syndrome Generator Debug Read Register
(BCH_DBGSYNDGENREAD_CLR)
32
R
0000_0000h
17.6.19/
619
180_813C
Syndrome Generator Debug Read Register
(BCH_DBGSYNDGENREAD_TOG)
32
R
0000_0000h
17.6.19/
619
180_8140
Bus Master and ECC Controller Debug Read Register
(BCH_DBGAHBMREAD)
32
R
0000_0000h
17.6.20/
620
180_8144
Bus Master and ECC Controller Debug Read Register
(BCH_DBGAHBMREAD_SET)
32
R
0000_0000h
17.6.20/
620
180_8148
Bus Master and ECC Controller Debug Read Register
(BCH_DBGAHBMREAD_CLR)
32
R
0000_0000h
17.6.20/
620
180_814C
Bus Master and ECC Controller Debug Read Register
(BCH_DBGAHBMREAD_TOG)
32
R
0000_0000h
17.6.20/
620
180_8150
Block Name Register (BCH_BLOCKNAME)
32
R
2048_4342h
17.6.21/
620
180_8154
Block Name Register (BCH_BLOCKNAME_SET)
32
R
2048_4342h
17.6.21/
620
Table continues on the next page...
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
596
NXP Semiconductors

<!-- page 597 -->

BCH memory map (continued)
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
180_8158
Block Name Register (BCH_BLOCKNAME_CLR)
32
R
2048_4342h
17.6.21/
620
180_815C
Block Name Register (BCH_BLOCKNAME_TOG)
32
R
2048_4342h
17.6.21/
620
180_8160
BCH Version Register (BCH_VERSION)
32
R
0100_0000h
17.6.22/
621
180_8164
BCH Version Register (BCH_VERSION_SET)
32
R
0100_0000h
17.6.22/
621
180_8168
BCH Version Register (BCH_VERSION_CLR)
32
R
0100_0000h
17.6.22/
621
180_816C
BCH Version Register (BCH_VERSION_TOG)
32
R
0100_0000h
17.6.22/
621
180_8170
Hardware BCH ECC Debug Register 1 (BCH_DEBUG1)
32
R/W
0000_0000h
17.6.23/
622
180_8174
Hardware BCH ECC Debug Register 1
(BCH_DEBUG1_SET)
32
R/W
0000_0000h
17.6.23/
622
180_8178
Hardware BCH ECC Debug Register 1
(BCH_DEBUG1_CLR)
32
R/W
0000_0000h
17.6.23/
622
180_817C
Hardware BCH ECC Debug Register 1
(BCH_DEBUG1_TOG)
32
R/W
0000_0000h
17.6.23/
622
17.6.1
Hardware BCH ECC Accelerator Control Register
(BCH_CTRLn)
The BCH CTRL provides overall control of the hardware ECC accelerator
Address: 180_8000h base + 0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
RSVD5
DEBUGSYNDROME
RSVD4
M2M_
LAYOUT
M2M_ENCODE
M2M_ENABLE
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
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
597

<!-- page 598 -->

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
RSVD3
DEBUG_STALL_IRQ_EN
RSVD2
COMPLETE_IRQ_EN
RSVD1
BM_ERROR_IRQ
DEBUG_STALL_IRQ
RSVD0
COMPLETE_IRQ
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
BCH_CTRLn field descriptions
Field
Description
31
SFTRST
Set this bit to 0 to enable normal BCH operation. Set this bit to 1 (default) to disable clocking with the
BCH and hold it in its reset (lowest power) state. This bit can be turned on and then off to reset the
BCH block to its default state. This bit resets all state machines except for the AHB master state
machine
0x0
RUN — Allow BCH to operate normally.
0x1
RESET — Hold BCH in reset.
30
CLKGATE
This bit must be set to 0 for normal operation. When set to 1 it gates off the clocks to the block.
0x0
RUN — Allow BCH to operate normally.
0x1
NO_CLKS — Do not clock BCH gates in order to minimize power consumption.
29–23
RSVD5
This field is reserved.
This read-only field is reserved and always has the value 0.
22
DEBUGSYNDROME
(For debug purposes only). Enable write of computed syndromes to memory on BCH decode
operations. Computed syndromes will be written to the auxiliary buffer after the status block.
Syndromes will be written as padded 16-bit values.
21–20
RSVD4
This field is reserved.
This read-only field is reserved and always has the value 0
19–18
M2M_LAYOUT
Selects the flash page format for memory-to-memory operations.
17
M2M_ENCODE
Selects encode (parity generation) or decode (correction) mode for memory-to-memory operations.
16
M2M_ENABLE
NOTE! WRITING THIS BIT INITIATES A MEMORY-TO-MEMORY OPERATION. The BCH module
must be inactive (not processing data from the GPMI) when this bit is set. The M2M_ENCODE and
Table continues on the next page...
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
598
NXP Semiconductors

<!-- page 599 -->

BCH_CTRLn field descriptions (continued)
Field
Description
M2M_LAYOUT bits as well as the ENCODEPTR, DATAPTR, and METAPTR registers are used for
memory-to-memory operations and must be correctly programmed before writing this bit.
15–11
RSVD3
This field is reserved.
This read-only field is reserved and always has the value 0
10
DEBUG_STALL_
IRQ_EN
1 = interrupt on debug stall mode is enabled. The IRQ is raised on every block
9
RSVD2
This field is reserved.
This read-only field is reserved and always has the value 0.
8
COMPLETE_IRQ_
EN
1 = interrupt on completion of correction is enabled.
7–4
RSVD1
This field is reserved.
This read-only field is reserved and always has the value 0.
3
BM_ERROR_IRQ
AHB Bus interface Error Interrupt Status. Write a 1 to the SCT clear address to clear the interrupt
status bit.
2
DEBUG_STALL_IRQ
DEBUG STALL Interrupt Status. Write a 1 to the SCT clear address to clear the interrupt status bit.
1
RSVD0
This field is reserved.
This read-only field is reserved and always has the value 0.
0
COMPLETE_IRQ
This bit indicates the state of the external interrupt line. Write a 1 to the SCT clear address to clear the
interrupt status bit. NOTE: subsequent ECC completions will be held off as long as this bit is set. Be
sure to read the data from BCH_STATUS0, 1 before clearing this interrupt bit.
17.6.2
Hardware ECC Accelerator Status Register 0
(BCH_STATUS0n)
The BCH STAT register provides visibility into the run-time status of the BCH and status
information when processing is complete. It provides overall status of the hardware ECC
accelerator.
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
599

<!-- page 600 -->

Address: 180_8000h base + 10h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
HANDLE
COMPLETED_CE
W
Reset
0
0
0
0
0
0
0
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
STATUS_BLK0
RSVD1
ALLONES
CORRECTED
UNCORRECTABLE
RSVD0
W
Reset
0
0
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
BCH_STATUS0n field descriptions
Field
Description
31–20
HANDLE
Software supplies a 12 bit handle for this transfer as part of the GPMI DMA PIO operation that started
the transaction. That handle passes down the pipeline and ends up here at the time the BCH interrupt is
signaled.
19–16
COMPLETED_CE
This is the chip enable number corresponding to the NAND device from which this data came.
15–8
STATUS_BLK0
Count of symbols in error during processing of first block of flash (metadata block). The number of
errors reported will be in the range of 0 to the ECC correction level for block 0.
0x00
ZERO — No errors found on block.
Table continues on the next page...
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
600
NXP Semiconductors

<!-- page 601 -->

BCH_STATUS0n field descriptions (continued)
Field
Description
0x01
ERROR1 — One error found on block.
0x02
ERROR2 — One errors found on block.
0x03
ERROR3 — One errors found on block.
0x04
ERROR4 — One errors found on block.
0xFE
UNCORRECTABLE — Block exhibited uncorrectable errors.
0xFF
ERASED — Page is erased.
7–5
RSVD1
This field is reserved.
This read-only field is reserved and always has the value 0.
4
ALLONES
1 = All data bits of this transaction are ONE.
3
CORRECTED
1 = At least one correctable error encountered during last processing cycle.
2
UNCORRECTABLE
1 = Uncorrectable error encountered during last processing cycle.
RSVD0
This field is reserved.
This read-only field is reserved and always has the value 0.
17.6.3
Hardware ECC Accelerator Mode Register (BCH_MODEn)
The BCH MODE register provides additional mode controls.
Contains additional global mode controls for the BCH engine.
Address: 180_8000h base + 20h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
RSVD
ERASE_THRESHOLD
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
BCH_MODEn field descriptions
Field
Description
31–8
RSVD
This field is reserved.
This read-only field is reserved and always has the value 0.
ERASE_
THRESHOLD
This value indicates the maximum number of zero bits on a flash subpage for it to be considered erased.
For SLC NAND devices, this value should be programmed to 0 (meaning that the entire page should
consist of bytes of 0xFF. For MLC NAND devices, bit errors may occur on reads (even on blank pages),
so this threshold can be used to tune the erased page checking algorithm.
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
601

<!-- page 602 -->

17.6.4
Hardware BCH ECC Loopback Encode Buffer Register
(BCH_ENCODEPTRn)
When performing memory to memory operations, indicates the address of the encode
buffer. This register should be programmed before writing a 1 to the M2M_ENABLE bit
in the CTRL register.
For memory to memory operations, this register is used as the pointer to the encoded
data, which is an output when encoding and an input while decoding.
Address: 180_8000h base + 30h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
BCH_ENCODEPTRn field descriptions
Field
Description
ADDR
Address pointer to encode buffer. This is the source for decode operations and the destination for encode
operations. This value must be aligned on a 4 bytes boundary.
17.6.5
Hardware BCH ECC Loopback Data Buffer Register
(BCH_DATAPTRn)
When performing memory to memory operations, indicates the address of the data buffer.
For memory to memory operations, this register is used as the pointer to the data to
encode or the destination buffer for decode operations.
Address: 180_8000h base + 40h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
BCH_DATAPTRn field descriptions
Field
Description
ADDR
Address pointer to data buffer. This is the source for encode operations and the destination for decode
operations. This register should be programmed before writing a 1 to the M2M_ENABLE bit in the CTRL
register. This value must be aligned on a 4 byte boundary.
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
602
NXP Semiconductors

<!-- page 603 -->

17.6.6
Hardware BCH ECC Loopback Metadata Buffer Register
(BCH_METAPTRn)
When performing memory to memory operations, indicates the address of the metadata
buffer.
For memory to memory operations, this register is used as the pointer to the metadata to
encode or the extracted metadata for decode operations.
Address: 180_8000h base + 50h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
BCH_METAPTRn field descriptions
Field
Description
ADDR
Address pointer to metadata buffer. This is the source for encode metadata read operations and the
destination for metadata decode operations. This register should be programmed before writing a 1 to the
M2M_ENABLE bit in the CTRL register. This value must be aligned on a 4 bytes boundary.
17.6.7
Hardware ECC Accelerator Layout Select Register
(BCH_LAYOUTSELECTn)
The BCH LAYOUTSELECT register provides a mapping of chip selects to layout
registers.
When the BCH engine receives a request to process a data block from the GPMI
interface, it will use this register to map the incoming chip select to one of the four
possible flash layout registers
Address: 180_8000h base + 70h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
CS15_
SELECT
CS14_
SELECT
CS13_
SELECT
CS12_
SELECT
CS11_
SELECT
CS10_
SELECT
CS9_
SELECT
CS8_
SELECT
W
Reset
1
1
1
0
0
1
0
0
1
1
1
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
CS7_
SELECT
CS6_
SELECT
CS5_
SELECT
CS4_
SELECT
CS3_
SELECT
CS2_
SELECT
CS1_
SELECT
CS0_
SELECT
W
Reset
1
1
1
0
0
1
0
0
1
1
1
0
0
1
0
0
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
603

<!-- page 604 -->

BCH_LAYOUTSELECTn field descriptions
Field
Description
31–30
CS15_SELECT
Selects which layout is used for chip select 15.
29–28
CS14_SELECT
Selects which layout is used for chip select 14.
27–26
CS13_SELECT
Selects which layout is used for chip select 13.
25–24
CS12_SELECT
Selects which layout is used for chip select 12.
23–22
CS11_SELECT
Selects which layout is used for chip select 11.
21–20
CS10_SELECT
Selects which layout is used for chip select 10.
19–18
CS9_SELECT
Selects which layout is used for chip select 9.
17–16
CS8_SELECT
Selects which layout is used for chip select 8.
15–14
CS7_SELECT
Selects which layout is used for chip select 7.
13–12
CS6_SELECT
Selects which layout is used for chip select 6.
11–10
CS5_SELECT
Selects which layout is used for chip select 5.
9–8
CS4_SELECT
Selects which layout is used for chip select 4.
7–6
CS3_SELECT
Selects which layout is used for chip select 3.
5–4
CS2_SELECT
Selects which layout is used for chip select 2.
3–2
CS1_SELECT
Selects which layout is used for chip select 1.
CS0_SELECT
Selects which layout is used for chip select 0.
17.6.8
Hardware BCH ECC Flash 0 Layout 0 Register
(BCH_FLASH0LAYOUT0n)
The flash format register contains a description of the logical layout of data on the flash
device. This register is used in conjunction with the FLASH0LAYOUT1 register to
control the format for the devices selecting layout 0 in the LAYOUTSELECT register.
Each pair of layout registers describes one of four supported flash configurations.
Software should program the LAYOUTSELECT register for each supported GPMI chip
select to select from one of the four layout values. Each pair of registers contains settings
that are used by the BCH block while reading / writing the flash page to control data,
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
604
NXP Semiconductors

<!-- page 605 -->

metadata, and flash page sizes as well as the ECC correction level. The first block written
to flash can be programmed to have different ECC, metadata, and data sizes from
subsequent data blocks on the device. In addition, the number of blocks stored on a page
of flash is not fixed, but instead is determined by the number of bytes consumed by the
initial (block 0) and subsequent data blocks.
See sections Flash Page Layout and Determining the ECC layout for a device for more
detail information on setting up the flash layout registers.
Address: 180_8000h base + 80h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
NBLOCKS
META_SIZE
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
1
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
ECC0
GF13_0_GF14_1
DATA0_SIZE
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
1
0
0
0
0
0
0
0
BCH_FLASH0LAYOUT0n field descriptions
Field
Description
31–24
NBLOCKS
Number of subsequent blocks on the flash page (excluding the data0 block). A value of 0 indicates that
only the DATA0 block is present and a value of 8 indicates that 8 subsequent blocks are present for a total
of 9 blocks on the flash (including the DATA0 block). Any values from 0 to 255 are supported by the
hardware.
23–16
META_SIZE
Indicates the size of the metadata (in bytes) to be stored on a flash page. The BCH design support from 0
to 255 bytes for metadata—if set to 0, no metadata will be stored. Metadata is stored before the
associated data in block 0. If the DATA0_SIZE field is programmed to a 0, then metadata effectively be
stored with its own parity. When both the metadata and data0 fields are programmed with non-zero
values, the first block will contain both portions of data and covered by a single parity block.
15–11
ECC0
Indicates the ECC level for the first block on the flash page. The first block covers metadata plus the
associated data from the DATA0_SIZE field.
0x0
NONE — No ECC to be performed
0x1
ECC2 — ECC 2 to be performed
0x2
ECC4 — ECC 4 to be performed
0x3
ECC6 — ECC 6 to be performed
0x4
ECC8 — ECC 8 to be performed
0x5
ECC10 — ECC 10 to be performed
0x6
ECC12 — ECC 12 to be performed
0x7
ECC14 — ECC 14 to be performed
Table continues on the next page...
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
605

<!-- page 606 -->

BCH_FLASH0LAYOUT0n field descriptions (continued)
Field
Description
0x8
ECC16 — ECC 16 to be performed
0x9
ECC18 — ECC 18 to be performed
0xA
ECC20 — ECC 20 to be performed
0xB
ECC22 — ECC 22 to be performed
0xC
ECC24 — ECC 24 to be performed
0xD
ECC26 — ECC 26 to be performed
0xE
ECC28 — ECC 28 to be performed
0xF
ECC30 — ECC 30 to be performed
0x10
ECC32 — ECC 32 to be performed
0x11
ECC34 — ECC 34 to be performed
0x12
ECC36 — ECC 36 to be performed
0x13
ECC38 — ECC 38 to be performed
0x14
ECC40 — ECC 40 to be performed
10
GF13_0_GF14_1
Select GF13 or GF14: 0-GF13; 1-GF14
DATA0_SIZE
Indicates the size of the data 0 block (in DWORDS / four bytes) to be stored on the flash page. If set to 0,
the first block only contains metadata.
17.6.9
Hardware BCH ECC Flash 0 Layout 1 Register
(BCH_FLASH0LAYOUT1n)
The flash format register contains a description of the logical layout of data on the flash
device. This register is used in conjunction with the FLASH0LAYOUT0 register to
control the format for the device selecting layout 0 in the LAYOUTSELECT register.
Address: 180_8000h base + 90h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
PAGE_SIZE
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
1
1
0
1
1
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
ECCN
GF13_0_GF14_1
DATAN_SIZE
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
1
0
0
0
0
0
0
0
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
606
NXP Semiconductors

<!-- page 607 -->

BCH_FLASH0LAYOUT1n field descriptions
Field
Description
31–16
PAGE_SIZE
Indicates the total size of the flash page (in bytes). This should be set to the page size including spare
area. The page size is programmable to accomodate different flash configurations that may be available in
the future.
15–11
ECCN
Indicates the ECC level for the subsequent blocks on the flash page (blocks 1-n). Subsequent blocks only
contain data (no metadata).
0x0
NONE — No ECC to be performed
0x1
ECC2 — ECC 2 to be performed
0x2
ECC4 — ECC 4 to be performed
0x3
ECC6 — ECC 6 to be performed
0x4
ECC8 — ECC 8 to be performed
0x5
ECC10 — ECC 10 to be performed
0x6
ECC12 — ECC 12 to be performed
0x7
ECC14 — ECC 14 to be performed
0x8
ECC16 — ECC 16 to be performed
0x9
ECC18 — ECC 18 to be performed
0xA
ECC20 — ECC 20 to be performed
0xB
ECC22 — ECC 22 to be performed
0xC
ECC24 — ECC 24 to be performed
0xD
ECC26 — ECC 26 to be performed
0xE
ECC28 — ECC 28 to be performed
0xF
ECC30 — ECC 30 to be performed
0x10
ECC32 — ECC 32 to be performed
0x11
ECC34 — ECC 34 to be performed
0x12
ECC36 — ECC 36 to be performed
0x13
ECC38 — ECC 38 to be performed
0x14
ECC40 — ECC 40 to be performed
10
GF13_0_GF14_1
Select GF13 or GF14: 0-GF13; 1-GF14
DATAN_SIZE
Indicates the size of the subsequent data blocks (in DWORDS / four bytes) to be stored on the flash page.
The size of subsequent data blocks does not have to match the data size for block 0, which is important
when metadata is stored separately or for balancing the amount of data stored in each block.
17.6.10
Hardware BCH ECC Flash 1 Layout 0 Register
(BCH_FLASH1LAYOUT0n)
The flash format register contains a description of the logical layout of data on the flash
device. This register is used in conjunction with the FLASH1LAYOUT1 register to
control the format for the devices selecting layout 1 in the LAYOUTSELECT register.
Each pair of layout registers describes one of four supported flash configurations.
Software should program the LAYOUTSELECT register for each supported GPMI chip
select to select from one of the four layout values. Each pair of registers contains settings
that are used by the BCH block while reading / writing the flash page to control data,
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
607

<!-- page 608 -->

metadata, and flash page sizes as well as the ECC correction level. The first block written
to flash can be programmed to have different ECC, metadata, and data sizes from
subsequent data blocks on the device. In addition, the number of blocks stored on a page
of flash is not fixed, but instead is determined by the number of bytes consumed by the
initial (block 0) and subsequent data blocks.
See sections Flash Page Layout and Determining the ECC layout for a device for more
detail information on setting up the flash layout registers.
Address: 180_8000h base + A0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
NBLOCKS
META_SIZE
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
1
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
ECC0
GF13_0_GF14_1
DATA0_SIZE
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
1
0
0
0
0
0
0
0
BCH_FLASH1LAYOUT0n field descriptions
Field
Description
31–24
NBLOCKS
Number of subsequent blocks on the flash page (excluding the data0 block). A value of 0 indicates that
only the DATA0 block is present and a value of 8 indicates that 8 subsequent blocks are present for a total
of 9 blocks on the flash (including the DATA0 block). Any values from 0 to 255 are supported by the
hardware.
23–16
META_SIZE
Indicates the size of the metadata (in bytes) to be stored on a flash page. The BCH design supports from
0 to 255 bytes for metadata—if set to 0, no metadata will be stored. Metadata is stored before the
associated data is in block 0. If the DATA0_SIZE field is programmed to a 0, then metadata effectively be
stored with its own parity. When both the metadata and data0 fields are programmed with non-zero
values, the first block will contain both portions of data and covered by a single parity block.
15–11
ECC0
Indicates the ECC level for the first block on the flash page. The first block covers metadata plus the
associated data from the DATA0_SIZE field.
0x0
NONE — No ECC to be performed
0x1
ECC2 — ECC 2 to be performed
0x2
ECC4 — ECC 4 to be performed
0x3
ECC6 — ECC 6 to be performed
0x4
ECC8 — ECC 8 to be performed
0x5
ECC10 — ECC 10 to be performed
0x6
ECC12 — ECC 12 to be performed
0x7
ECC14 — ECC 14 to be performed
Table continues on the next page...
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
608
NXP Semiconductors

<!-- page 609 -->

BCH_FLASH1LAYOUT0n field descriptions (continued)
Field
Description
0x8
ECC16 — ECC 16 to be performed
0x9
ECC18 — ECC 18 to be performed
0xA
ECC20 — ECC 20 to be performed
0xB
ECC22 — ECC 22 to be performed
0xC
ECC24 — ECC 24 to be performed
0xD
ECC26 — ECC 26 to be performed
0xE
ECC28 — ECC 28 to be performed
0xF
ECC30 — ECC 30 to be performed
0x10
ECC32 — ECC 32 to be performed
0x11
ECC34 — ECC 34 to be performed
0x12
ECC36 — ECC 36 to be performed
0x13
ECC38 — ECC 38 to be performed
0x14
ECC40 — ECC 40 to be performed
10
GF13_0_GF14_1
Select GF13 or GF14: 0-GF13; 1-GF14
DATA0_SIZE
Indicates the size of the data 0 block (in DWORDS / four bytes) to be stored on the flash page. If set to 0,
the first block will contains metadata.
17.6.11
Hardware BCH ECC Flash 1 Layout 1 Register
(BCH_FLASH1LAYOUT1n)
The flash format register contains a description of the logical layout of data on the flash
device. This register is used in conjunction with the FLASH1LAYOUT0 register to
control the format for the device selecting layout 1 in the LAYOUTSELECT register.
Address: 180_8000h base + B0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
PAGE_SIZE
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
1
1
0
1
1
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
ECCN
GF13_0_GF14_1
DATAN_SIZE
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
1
0
0
0
0
0
0
0
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
609

<!-- page 610 -->

BCH_FLASH1LAYOUT1n field descriptions
Field
Description
31–16
PAGE_SIZE
Indicates the total size of the flash page (in bytes). This should be set to the page size including spare
area. The page size is programmable to accomodate different flash configurations that may be available in
the future.
15–11
ECCN
Indicates the ECC level for the subsequent blocks on the flash page (blocks 1-n). Subsequent blocks only
contain data (no metadata).
0x0
NONE — No ECC to be performed
0x1
ECC2 — ECC 2 to be performed
0x2
ECC4 — ECC 4 to be performed
0x3
ECC6 — ECC 6 to be performed
0x4
ECC8 — ECC 8 to be performed
0x5
ECC10 — ECC 10 to be performed
0x6
ECC12 — ECC 12 to be performed
0x7
ECC14 — ECC 14 to be performed
0x8
ECC16 — ECC 16 to be performed
0x9
ECC18 — ECC 18 to be performed
0xA
ECC20 — ECC 20 to be performed
0xB
ECC22 — ECC 22 to be performed
0xC
ECC24 — ECC 24 to be performed
0xD
ECC26 — ECC 26 to be performed
0xE
ECC28 — ECC 28 to be performed
0xF
ECC30 — ECC 30 to be performed
0x10
ECC32 — ECC 32 to be performed
0x11
ECC34 — ECC 34 to be performed
0x12
ECC36 — ECC 36 to be performed
0x13
ECC38 — ECC 38 to be performed
0x14
ECC40 — ECC 40 to be performed
10
GF13_0_GF14_1
Select GF13 or GF14: 0-GF13; 1-GF14
DATAN_SIZE
Indicates the size of the subsequent data blocks (in DWORDS / four bytes) to be stored on the flash page.
The size of subsequent data blocks does not have to match the data size for block 0, which is important
when metadata is stored separately or for balancing the amount of data stored in each block.
17.6.12
Hardware BCH ECC Flash 2 Layout 0 Register
(BCH_FLASH2LAYOUT0n)
The flash format register contains a description of the logical layout of data on the flash
device. This register is used in conjunction with the FLASH2LAYOUT1 register to
control the format for the devices selecting layout 2 in the LAYOUTSELECT register.
Each pair of layout registers describes one of four supported flash configurations.
Software should program the LAYOUTSELECT register for each supported GPMI chip
select to select from one of the four layout values. Each pair of registers contains settings
that are used by the BCH block while reading / writing the flash page to control data,
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
610
NXP Semiconductors

<!-- page 611 -->

metadata, and flash page sizes as well as the ECC correction level. The first block written
to flash can be programmed to have different ECC, metadata, and data sizes from
subsequent data blocks on the device. In addition, the number of blocks stored on a page
of flash is not fixed, but instead is determined by the number of bytes consumed by the
initial (block 0) and subsequent data blocks.
See sections Flash Page Layout and Determining the ECC layout for a device for more
detail information on setting up the flash layout registers.
Address: 180_8000h base + C0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
NBLOCKS
META_SIZE
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
1
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
ECC0
GF13_0_GF14_1
DATA0_SIZE
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
1
0
0
0
0
0
0
0
BCH_FLASH2LAYOUT0n field descriptions
Field
Description
31–24
NBLOCKS
Number of subsequent blocks on the flash page (excluding the data0 block). A value of 0 indicates that
only the DATA0 block is present and a value of 8 indicates that eight subsequent blocks are present for a
total of nine blocks on the flash (including the DATA0 block). Any values from 0 to 255 are supported by
the hardware.
23–16
META_SIZE
Indicates the size of the metadata (in bytes) to be stored on a flash page. The BCH design support from 0
to 255 bytes for metadata—if set to 0, no metadata will be stored. Metadata is stored before the
associated data in block 0. If the DATA0_SIZE field is programmed to a 0, then metadata effectively be
stored with its own parity. When both the metadata and data0 fields are programmed with non-zero
values, the first block will contain both portions of data and will be covered by a single parity block.
15–11
ECC0
Indicates the ECC level for the first block on the flash page. The first block covers metadata plus the
associated data from the DATA0_SIZE field.
0x0
NONE — No ECC to be performed
0x1
ECC2 — ECC 2 to be performed
0x2
ECC4 — ECC 4 to be performed
0x3
ECC6 — ECC 6 to be performed
0x4
ECC8 — ECC 8 to be performed
0x5
ECC10 — ECC 10 to be performed
0x6
ECC12 — ECC 12 to be performed
0x7
ECC14 — ECC 14 to be performed
Table continues on the next page...
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
611

<!-- page 612 -->

BCH_FLASH2LAYOUT0n field descriptions (continued)
Field
Description
0x8
ECC16 — ECC 16 to be performed
0x9
ECC18 — ECC 18 to be performed
0xA
ECC20 — ECC 20 to be performed
0xB
ECC22 — ECC 22 to be performed
0xC
ECC24 — ECC 24 to be performed
0xD
ECC26 — ECC 26 to be performed
0xE
ECC28 — ECC 28 to be performed
0xF
ECC30 — ECC 30 to be performed
0x10
ECC32 — ECC 32 to be performed
0x11
ECC34 — ECC 34 to be performed
0x12
ECC36 — ECC 36 to be performed
0x13
ECC38 — ECC 38 to be performed
0x14
ECC40 — ECC 40 to be performed
10
GF13_0_GF14_1
Select GF13 or GF14: 0-GF13; 1-GF14
DATA0_SIZE
Indicates the size of the data 0 block (in DWORDS / four bytes) to be stored on the flash page. If set to 0,
the first block will only contain metadata.
17.6.13
Hardware BCH ECC Flash 2 Layout 1 Register
(BCH_FLASH2LAYOUT1n)
The flash format register contains a description of the logical layout of data on the flash
device. This register is used in conjunction with the FLASH2LAYOUT0 register to
control the format for the device selecting layout 2 in the LAYOUTSELECT register.
Address: 180_8000h base + D0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
PAGE_SIZE
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
1
1
0
1
1
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
ECCN
GF13_0_GF14_1
DATAN_SIZE
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
1
0
0
0
0
0
0
0
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
612
NXP Semiconductors

<!-- page 613 -->

BCH_FLASH2LAYOUT1n field descriptions
Field
Description
31–16
PAGE_SIZE
Indicates the total size of the flash page (in bytes). This should be set to the page size including spare
area. The page size is programmable to accomodate different flash configurations that may be available in
the future.
15–11
ECCN
Indicates the ECC level for the subsequent blocks on the flash page (blocks 1-n). Subsequent blocks only
contain data (no metadata).
0x0
NONE — No ECC to be performed
0x1
ECC2 — ECC 2 to be performed
0x2
ECC4 — ECC 4 to be performed
0x3
ECC6 — ECC 6 to be performed
0x4
ECC8 — ECC 8 to be performed
0x5
ECC10 — ECC 10 to be performed
0x6
ECC12 — ECC 12 to be performed
0x7
ECC14 — ECC 14 to be performed
0x8
ECC16 — ECC 16 to be performed
0x9
ECC18 — ECC 18 to be performed
0xA
ECC20 — ECC 20 to be performed
0xB
ECC22 — ECC 22 to be performed
0xC
ECC24 — ECC 24 to be performed
0xD
ECC26 — ECC 26 to be performed
0xE
ECC28 — ECC 28 to be performed
0xF
ECC30 — ECC 30 to be performed
0x10
ECC32 — ECC 32 to be performed
0x11
ECC34 — ECC 34 to be performed
0x12
ECC36 — ECC 36 to be performed
0x13
ECC38 — ECC 38 to be performed
0x14
ECC40 — ECC 40 to be performed
10
GF13_0_GF14_1
Select GF13 or GF14: 0-GF13; 1-GF14
DATAN_SIZE
Indicates the size of the subsequent data blocks (in DWORDS / four bytes) to be stored on the flash page.
The size of subsequent data blocks does not have to match the data size for block 0, which is important
when metadata is stored separately or for balancing the amount of data stored in each block.
17.6.14
Hardware BCH ECC Flash 3 Layout 0 Register
(BCH_FLASH3LAYOUT0n)
The flash format register contains a description of the logical layout of data on the flash
device. This register is used in conjunction with the FLASH3LAYOUT1 register to
control the format for the devices selecting layout 3 in the LAYOUTSELECT register.
Each pair of layout registers describes one of four supported flash configurations.
Software should program the LAYOUTSELECT register for each supported GPMI chip
select to select from one of the four layout values. Each pair of registers contains settings
that are used by the BCH block while reading / writing the flash page to control data,
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
613

<!-- page 614 -->

metadata, and flash page sizes as well as the ECC correction level. The first block written
to flash can be programmed to have different ECC, metadata, and data sizes from
subsequent data blocks on the device. In addition, the number of blocks stored on a page
of flash is not fixed, but instead is determined by the number of bytes consumed by the
initial (block 0) and subsequent data blocks.
See sections Flash Page Layout and Determining the ECC layout for a device for more
detail information on setting up the flash layout registers.
Address: 180_8000h base + E0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
NBLOCKS
META_SIZE
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
1
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
ECC0
GF13_0_GF14_1
DATA0_SIZE
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
1
0
0
0
0
0
0
0
BCH_FLASH3LAYOUT0n field descriptions
Field
Description
31–24
NBLOCKS
Number of subsequent blocks on the flash page (excluding the data0 block). A value of 0 indicates that
only the DATA0 block is present and a value of 8 indicates that 8 subsequent blocks are present for a total
of 9 blocks on the flash (including the DATA0 block). Any values from 0 to 255 are supported by the
hardware.
23–16
META_SIZE
Indicates the size of the metadata (in bytes) to be stored on a flash page. The BCH design support from 0
to 255 bytes for metadata—if set to 0, no metadata will be stored. Metadata is stored before the
associated data in block 0. If the DATA0_SIZE field is programmed to a 0, then metadata effectively be
stored with its own parity. When both the metadata and data0 fields are programmed with non-zero
values, the first block will contain both portions of data and will be covered by a single parity block.
15–11
ECC0
Indicates the ECC level for the first block on the flash page. The first block covers metadata plus the
associated data from the DATA0_SIZE field.
0x0
NONE — No ECC to be performed
0x1
ECC2 — ECC 2 to be performed
0x2
ECC4 — ECC 4 to be performed
0x3
ECC6 — ECC 6 to be performed
0x4
ECC8 — ECC 8 to be performed
0x5
ECC10 — ECC 10 to be performed
0x6
ECC12 — ECC 12 to be performed
0x7
ECC14 — ECC 14 to be performed
Table continues on the next page...
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
614
NXP Semiconductors

<!-- page 615 -->

BCH_FLASH3LAYOUT0n field descriptions (continued)
Field
Description
0x8
ECC16 — ECC 16 to be performed
0x9
ECC18 — ECC 18 to be performed
0xA
ECC20 — ECC 20 to be performed
0xB
ECC22 — ECC 22 to be performed
0xC
ECC24 — ECC 24 to be performed
0xD
ECC26 — ECC 26 to be performed
0xE
ECC28 — ECC 28 to be performed
0xF
ECC30 — ECC 30 to be performed
0x10
ECC32 — ECC 32 to be performed
0x11
ECC34 — ECC 34 to be performed
0x12
ECC36 — ECC 36 to be performed
0x13
ECC38 — ECC 38 to be performed
0x14
ECC40 — ECC 40 to be performed
10
GF13_0_GF14_1
Select GF13 or GF14: 0-GF13; 1-GF14
DATA0_SIZE
Indicates the size of the data 0 block (in DWORDS / four bytes) to be stored on the flash page. If set to 0,
the first block will only contain metadata.
17.6.15
Hardware BCH ECC Flash 3 Layout 1 Register
(BCH_FLASH3LAYOUT1n)
The flash format register contains a description of the logical layout of data on the flash
device. This register is used in conjunction with the FLASH3LAYOUT0 register to
control the format for the device selecting layout 3 in the LAYOUTSELECT register.
Address: 180_8000h base + F0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
PAGE_SIZE
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
1
1
0
1
1
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
ECCN
GF13_0_GF14_1
DATAN_SIZE
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
1
0
0
0
0
0
0
0
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
615

<!-- page 616 -->

BCH_FLASH3LAYOUT1n field descriptions
Field
Description
31–16
PAGE_SIZE
Indicates the total size of the flash page (in bytes). This should be set to the page size including spare
area. The page size is programmable to accomodate different flash configurations that may be available in
the future.
15–11
ECCN
Indicates the ECC level for the subsequent blocks on the flash page (blocks 1-n). Subsequent blocks only
contain data (no metadata).
0x0
NONE — No ECC to be performed
0x1
ECC2 — ECC 2 to be performed
0x2
ECC4 — ECC 4 to be performed
0x3
ECC6 — ECC 6 to be performed
0x4
ECC8 — ECC 8 to be performed
0x5
ECC10 — ECC 10 to be performed
0x6
ECC12 — ECC 12 to be performed
0x7
ECC14 — ECC 14 to be performed
0x8
ECC16 — ECC 16 to be performed
0x9
ECC18 — ECC 18 to be performed
0xA
ECC20 — ECC 20 to be performed
0xB
ECC22 — ECC 22 to be performed
0xC
ECC24 — ECC 24 to be performed
0xD
ECC26 — ECC 26 to be performed
0xE
ECC28 — ECC 28 to be performed
0xF
ECC30 — ECC 30 to be performed
0x10
ECC32 — ECC 32 to be performed
0x11
ECC34 — ECC 34 to be performed
0x12
ECC36 — ECC 36 to be performed
0x13
ECC38 — ECC 38 to be performed
0x14
ECC40 — ECC 40 to be performed
10
GF13_0_GF14_1
Select GF13 or GF14: 0-GF13; 1-GF14
DATAN_SIZE
Indicates the size of the subsequent data blocks (in DWORDS / four bytes) to be stored on the flash page.
The size of subsequent data blocks does not have to match the data size for block 0, which is important
when metadata is stored separately or for balancing the amount of data stored in each block.
17.6.16
Hardware BCH ECC Debug Register0 (BCH_DEBUG0n)
The hardware BCH accelerator internal state machines and signals can be seen in the
ECC debug register.
The BCH_DEBUG0 register provides access to various internal state information which
might prove useful during hardware debug and validation.
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
616
NXP Semiconductors

<!-- page 617 -->

Address: 180_8000h base + 100h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
RSVD1
KES_DEBUG_SYNDROME_SYMBOL
W
Reset
0
0
0
0
0
0
0
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
KES_DEBUG_SHIFT_SYND
KES_DEBUG_PAYLOAD_FLAG
KES_DEBUG_MODE4K
KES_DEBUG_KICK
KES_STANDALONE
KES_DEBUG_STEP
KES_DEBUG_STALL
BM_KES_TEST_BYPASS
RSVD0
DEBUG_REG_SELECT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
BCH_DEBUG0n field descriptions
Field
Description
31–25
RSVD1
This field is reserved.
This read-only field is reserved and always has the value 0.
24–16
KES_DEBUG_
SYNDROME_
SYMBOL
The 9 bit value in this bit field shifts into the syndrome register array at the input of the KES engine
whenever BCH_DEBUG0_KES_DEBUG_SHIFT_SYND is toggled.
0x0
NORMAL — Bus master address generator for SYND_GEN writes operates normally.
0x1
TEST_MODE — Bus master address generator always addresses last four bytes in Auxiliary block.
15
KES_DEBUG_
SHIFT_SYND
Toggling this bit causes the value in BCH_DEBUG0_KES_SYNDROME_SYMBOL to be shift into the
syndrome register array at the input to the KES engine. After shifting in 16 symbols, one can kick off both
KES and CF cycles by toggling BCH_DEBUG0_KES_DEBUG_KICK. Make sure that set
KES_BCH_DEBUG0_KES_STANDALONE mode to 1 before kicking.
Table continues on the next page...
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
617

<!-- page 618 -->

BCH_DEBUG0n field descriptions (continued)
Field
Description
14
KES_DEBUG_
PAYLOAD_FLAG
When running the stand alone debug mode on the error calculator, the state of this bit is presented to the
KES engine as the input payload flag.
0x1
DATA — Payload is set for 512 bytes data block.
0x1
AUX — Payload is set for 65 or 19 bytes auxiliary block.
13
KES_DEBUG_
MODE4K
When running the stand alone debug mode on the error calculator, the state of this bit is presented to the
KES engine as the input mode (4K or 2K pages).
0x1
4k — Mode is set for 4K NAND pages.
0x1
2k — Mode is set for 2K NAND pages.
12
KES_DEBUG_
KICK
Toggling causes KES engine FSM to start as if kick by the Bus Master. This allows stand alone testing of
the KES and Chien Search engines. Be sure to set KES_BCH_DEBUG0_KES_STANDALONE mode to 1
before kicking.
11
KES_
STANDALONE
Set to one, cause the KES engine to suppress toggling the KES_BM_DONE signal to the bus master and
suppress toggling the CF_BM_DONE signal by the CF engine.
0x0
NORMAL — Bus master address generator for SYND_GEN writes operates normally.
0x1
TEST_MODE — Bus master address generator always addresses last four bytes in Auxiliary block.
10
KES_DEBUG_
STEP
Toggling this bit causes the KES FSM to skip passed the stall state if it is in DEBUG_STALL mode and
completed processing a block.
9
KES_DEBUG_
STALL
Set to one to cause KES FSM to stall after notifying Chien search engine to start processing its block but
before notifying the bus master that the KES computation is complete. This allows a diagnostic to stall the
FSM after each blocks key equations are solved. This also has the effect of stalling the CSFE search
engine so it's state can be examined after it finishes processing the KES stalled block.
0x0
NORMAL — KES FSM proceeds to next block supplied by bus master.
0x1
WAIT — KES FSM waits after current equations are solved and the search engine is started.
8
BM_KES_TEST_
BYPASS
1 = Point all SYND_GEN writes to dummy area at the end of the AUXILLIARY block so that diagnostics
can preload all payload, parity bytes and computed syndrome bytes for test the KES engine.
0x0
NORMAL — Bus master address generator for SYND_GEN writes operates normally.
0x1
TEST_MODE — Bus master address generator always addresses last four bytes in Auxiliary block.
7–6
RSVD0
This field is reserved.
This read-only field is reserved and always has the value 0.
DEBUG_REG_
SELECT
The value loaded in this bit field is used to select the internal register state view of KES engine or the
Chien search engine.
17.6.17
KES Debug Read Register (BCH_DBGKESREADn)
The hardware BCH ECC accelerator key equation solver internal state machines and
signals can be seen in the ECC debug registers.
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
618
NXP Semiconductors

<!-- page 619 -->

Address: 180_8000h base + 110h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
VALUES
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
BCH_DBGKESREADn field descriptions
Field
Description
VALUES
This register returns the ROM BIST CRC value after a BIST test.
17.6.18
Chien Search Debug Read Register
(BCH_DBGCSFEREADn)
The hardware BCH ECC accelerator Chien Search internal state machines and signals
can be seen in the ECC debug registers.
Address: 180_8000h base + 120h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
VALUES
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
BCH_DBGCSFEREADn field descriptions
Field
Description
VALUES
Reserved
17.6.19
Syndrome Generator Debug Read Register
(BCH_DBGSYNDGENREADn)
The hardware BCH ECC accelerator syndrome generator internal state machines and
signals can be seen in the ECC debug registers.
Address: 180_8000h base + 130h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
VALUES
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
619

<!-- page 620 -->

BCH_DBGSYNDGENREADn field descriptions
Field
Description
VALUES
Reserved
17.6.20
Bus Master and ECC Controller Debug Read Register
(BCH_DBGAHBMREADn)
The hardware BCH ECC accelerator bus master, ECC controller internal state machines,
and signals can be seen in the ECC debug registers.
Address: 180_8000h base + 140h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
VALUES
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
BCH_DBGAHBMREADn field descriptions
Field
Description
VALUES
Reserved
17.6.21
Block Name Register (BCH_BLOCKNAMEn)
Read only view of the block name string BCH.
Fixed pattern read only value is for test purposes. It can be read as an ASCII string with
the zero termination coming from the first byte of the BLOCKVERSION register.
Address: 180_8000h base + 150h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
NAME
W
Reset 0
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
BCH_BLOCKNAMEn field descriptions
Field
Description
NAME
The name is in the ASCII characters BCH (0x20, H, C, B).
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
620
NXP Semiconductors

<!-- page 621 -->

17.6.22
BCH Version Register (BCH_VERSIONn)
This register always returns a known read value for debug purposes and indicates the
version of the block and RTL version in use.
Address: 180_8000h base + 160h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
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
0
0
0
0
0
0
0
0
BCH_VERSIONn field descriptions
Field
Description
31–24
MAJOR
Fixed read-only value indicates the MAJOR field of the RTL version.
23–16
MINOR
Fixed read-only value indicates the MINOR field of the RTL version.
STEP
Fixed read-only value reflecting the stepping of the RTL version.
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
621

<!-- page 622 -->

17.6.23
Hardware BCH ECC Debug Register 1 (BCH_DEBUG1n)
The BCH_DEBUG1 register provides erased zero count information and pre-erase check.
Address: 180_8000h base + 170h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
DEBUG1_PREERASECHK
RSVD
W
Reset
0
0
0
0
0
0
0
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
RSVD
ERASED_ZERO_COUNT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
BCH_DEBUG1n field descriptions
Field
Description
31
DEBUG1_
PREERASECHK
Blank page enables pre-erase check.
0x0
Turn off pre-erase check
0x1
Turn on pre-erase check
30–9
RSVD
This field is reserved.
This read-only field is reserved and always has the value 0.
Table continues on the next page...
BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
622
NXP Semiconductors

<!-- page 623 -->

BCH_DEBUG1n field descriptions (continued)
Field
Description
ERASED_
ZERO_COUNT
The zero counts on one page.
Chapter 17 40-BIT Correcting ECC Accelerator (BCH)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
623

<!-- page 624 -->

BCH Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
624
NXP Semiconductors

