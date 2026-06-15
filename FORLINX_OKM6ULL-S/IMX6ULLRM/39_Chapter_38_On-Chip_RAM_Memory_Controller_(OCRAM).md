# Chapter 38: On-Chip RAM Memory Controller (OCRAM)

> Nguồn: `IMX6ULLRM.pdf` — trang 2435–2440

<!-- page 2435 -->

Chapter 38
On-Chip RAM Memory Controller (OCRAM)
38.1
Overview
There is 1 OCRAM controller implemented in the chip. One controller is for the 128KB
on-chip RAM.
The on-chip RAM block is implemented as an slave module on the 64-bit system AXI
bus. Designed as a simple on-chip memory controller, it supports only one AXI port with
memory banks. For the AXI port, the read and write transactions are handled by two
independent modules. As it is possible to have simultaneous read and write request from
the AXI bus, each memory bank has an arbiter with round-robin scheme. After
arbitration, the granted read or write access command can then be issued to the memory
cell through a read/write MUX.
The memory banks are organized with the lower 2 bits of the address which is the AXI
bus address and is 64 bits aligned interleaved. This allows a read access and a write
access to be processed at the same time if they are targeted to different memory banks.
Various options are provided for adding a pipeline or wait-states in a read/write access, in
order to ensure flexible timing control at both high and low frequencies.
The internal block diagram is shown in the figure below.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2435

<!-- page 2436 -->

Read
Control
Module
Write
Control
Module
RAM
MUX
RD
REQ
DEC
WR
REQ
DEC
Arbiter
RAM
MUX
RAM
MUX
RAM
MUX
Arbiter
Arbiter
Arbiter
Read Control
Write Control
WDATA [63:0]
MUX
RDATA 0[63:0]
RDATA 1[63:0]
RDATA 2[63:0]
RDATA 3[63:0]
MEM_WE[3..0]
MEM_ADDR[3..0]
MEM_SEL[3..0]
MEM_WDATA [3..0]
OCRAM CONTROLLER
AXI RADDR
AXI RDATA
AXI WADDR
AXI WDATA
AXI WRESP
Timing
Configuration
Figure 38-1. On-chip RAM Block Diagram
38.2
Basic Functions
38.2.1
Read/Write Arbitration
The detailed rules used in arbitration are as follows:
• If there is no granted read or write in the last cycle, and there is only a read request or
a write request, the request will be granted.
• If there is no granted read or write in the last cycle, and there are both read or write
requests coming in at the same time, the read request will be granted first.
Basic Functions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2436
NXP Semiconductors

<!-- page 2437 -->

• If a granted read/write transaction has just finished, the write/read request will have
the higher priority in the next cycle.
• If the first read/write access request in a transaction is granted, all the data transfer in
this burst will be finished before the next arbitration begins, that is, the round-robin
arbitration mechanism is based on AXI transaction, not data access.
38.3
Advanced Features
This section describes some advanced features designed to avoid timing issues when the
on-chip RAM is working at high frequency.
All of the features can be disabled/enabled by programming the corresponding fields of
the General Purpose Register (IOMUXC.GPR3) bits [24:21] and bits [3:0] in the IOMUX
chapter.
38.3.1
Read Data Wait State
When the wait state is enabled, it will take 2 cycles for each read access (each beat of a
read burst).
This can avoid the potential timing problem caused by the longer memory access time at
higher frequency.
When this feature is disabled, it only takes 1 clock cycle to finish a read transaction. That
is, read data is available in the next cycle of read request becomes valid on the bus.
For the normal OCRAM, the read data wait state is configurable via
IOMUXC.GPR3[21].
38.3.2
Read Address Pipeline
When this feature is enabled, the read address from the AXI master is delayed 1 cycle
before it can be accepted by the on-chip RAM.
This can avoid setup time issues for the read access on the memory cell at high
frequency. Enabling this feature can cost, at most, 1 more clock cycle for each AXI read
transaction, that is, at most 1 more clock cycle for each read burst with multiple beats of
data.
Chapter 38 On-Chip RAM Memory Controller (OCRAM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2437

<!-- page 2438 -->

When this feature is disabled, the read address from the AXI master can be accepted by
the on-chip RAM without delay, and data can become ready for master at next clock
cycle (if no other access and no read data wait).
For the normal OCRAM, the read address pipeline is configurable via
IOMUXC.GPR3[22]. For the L2 cache as OCRAM, the read address pipeline is
configurable via IOMUXC.GPR3[1].
38.3.3
Write Data Pipeline
When this feature is enabled, the write data from the AXI master would be delayed 1
cycle before it can be accepted by the on-chip RAM.
This can avoid setup time issue for the write access on the memory cell at high
frequency. Enabling this feature would cost at most 1 more clock cycle for each AXI
write transaction, that is, at most 1 more clock cycle for each write burst with multiple
beats of data.
When this feature is disabled, the write data from the AXI master can be accepted by the
on-chip RAM without delay, and data can be written to memory at this cycle (if no other
access and write address is also ready at this cycle).
For the normal OCRAM, the write data pipeline is configurable via IOMUXC.GPR3[23].
For the L2 cache as OCRAM, the write data pipeline is configurable via
IOMUXC.GPR3[2].
38.3.4
Write Address Pipeline
When this feature is enabled, the write address from the AXI master would be delayed 1
cycle before it can be accepted by the on-chip RAM.
This can avoid setup time issue for the write access on the memory cell at high
frequency. Enabling this feature would take at most 1 more clock cycle for each AXI
write transaction, that is, at most 1 more clock cycle for each write burst with multiple
beats of data.
When this feature is disabled, the write address from the AXI master can be accepted by
the on-chip RAM without delay, and data can be written to memory at this cycle (if no
other access and write data is also ready at this cycle).
For the normal OCRAM, the write address pipeline is configurable via
IOMUXC.GPR3[24]. For the L2 cache as OCRAM, the write address pipeline is
configurable via IOMUXC.GPR3[3]
Advanced Features
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2438
NXP Semiconductors

<!-- page 2439 -->

38.4
Programmable Registers
There are no programmable registers in this block; however, OCRAM configurable bits
can be found in the IOMUX Controller (IOMUXC) general purpose registers found here.
• TrustZone bits: IOMUXC_GPR10
• WAIT state / Pipeline bits: IOMUXC_GPR3
Chapter 38 On-Chip RAM Memory Controller (OCRAM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2439

<!-- page 2440 -->

Programmable Registers
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2440
NXP Semiconductors

