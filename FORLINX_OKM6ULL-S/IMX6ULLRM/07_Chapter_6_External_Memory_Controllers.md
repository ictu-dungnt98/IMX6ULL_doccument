# Chapter 6: External Memory Controllers

> Nguồn: `IMX6ULLRM.pdf` — trang 235–238

<!-- page 235 -->

Chapter 6
External Memory Controllers
6.1
Overview
This chip has these external memory interfaces and controllers:
• Multi-Mode DDR Controller (MMDC)
• EIM-PSRAM/NOR flash controller
6.2
Multi-mode DDR controller (MMDC) overview and feature
summary
The MMDC module is a DDR controller that supports several types of DDR memories.
Table 6-1. MMDC feature summary
Feature
Description
Supported standards
• LPDDR2 1ch x16, LV-DDR3, DDR3 x16
DDR interface
• Density of 256 MB-4 GB
• Column size of 8-12 bits
• Row size of 11-16 bits
• Supports burst length of 8 (aligned) for DDR3 and burst lengths of 4 for
LPDDR2
DDR performance
• Supports Real-Time priority by means of QoS the sideband priority signals
from the chip to enable different priority levels in the re-ordering mechanism
• Page hit/page miss optimizations
• Consecutive read/write access optimizations
• Supports deep read and write requests queues to enable bank prediction
• Drives back the critical word in a read transaction as soon as it is received by
the DDR device (doesn't wait until the whole data phase has been
completed)
• Can track open memory pages
• Supports bank interleaving
• Special optimization for non-aligned wrap accesses in burst length 8
AXI interface
• AXI bus compliant with glueless interface to PL301 AXI network interconnect
Table continues on the next page...
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
235

<!-- page 236 -->

Table 6-1. MMDC feature summary (continued)
Feature
Description
DDR calibration and delay-lines
• All calibrations can be done automatically by hardware or manually by
software.
• ZQ calibration for an external DDR device (in DDR3 through the ZQ
calibration command and in LPDDR2 through the MRW command).
• Can be handled automatically for ZQ Short (periodically) and ZQ Long
(at exit from self-refresh).
• Can be handled manually at ZQ INIT.
DDR general
• Configurable timing parameters
• Configurable refresh scheme
• Supports dynamic voltage, frequency change, and low-power mode entry
through hardware negotiation with the system (req/ack handshake)
• Suppors automatic self-refresh and power down entry and exit
• Supports the fast and slow precharge power down in DDR3
• Supports various ODT control schemes.
• Assertion/Deassertion of ODT control per read or write accesses and
for active or passive CS
• Supports MRW and MRR commands for LPDDR2
• Software control for moving to derated timing parameters and derated
refresh rate according to the temperature variation.
• Supports various debug and profiling modes
6.3
EIM-PSRAM/NOR flash controller overview
EIM is an external interface module that manages the interface to external chip devices,
including the generation of chip selects, clocks, and control for external peripherals and
memory.
It provides asynchronous and synchronous access to devices with an SRAM-like
interface.
6.3.1
EIM features
• Up to four (software configurable) chip selects for external devices
• Flexible address decoding; each chip-select memory space is determined
separately according to the GPR bits in IOMUXC.
• Maximum supported density is 128 MB by default (AUS bit is cleared). When
the AUS bit is set, the maximum supported density is 32 MB.
• Selectable write protection for each chip select
• Programmable wait-state generator for each chip select, for write and read accesses
separately
• Asynchronous accesses with programmable setup and hold times for control signals
EIM-PSRAM/NOR flash controller overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
236
NXP Semiconductors

<!-- page 237 -->

• Independent synchronous memory burst write mode support for PSRAM and NOR-
flash memories (CellularRAMTM from Micron, Infineon, and Cypress, OneNANDTM
and utRAMTM from Samsung, and COSMORAMTMfrom Toshiba)
• Supports NAND-flash devices with a NOR-flash interfaces - OneNANDTM
(Samsung)
• Independent programmable variable/fix latency support for read and write
synchronous (burst) mode
• Support for little-endian operation
• ARM AXI slave interface accesses are only handled in parallel for single AXI ID
transactions
• External interrupt support using the RDY_INT signal function as an external
interrupt pin
• Boot from external device support according to boot signals, using the RDY_INT
signal
• RDY signal support assertion after reset
• INT signal support assertion after reset for OneNANDTM (Samsung) device
• Supports little-endian mode only
6.3.2
EIM boot scenarios
EIM allows booting from NOR-flash devices. To select the NOR flash as the boot source,
use either the boot mode and configuration GPIO pins or the internal boot-related fuses.
See Sytem Boot for more information.
6.3.3
EIM boot configuration
This table shows the EIM boot configuration:
Table 6-2. EIM boot configuration
EIM_BOOT_CFG bus
EIM affected bits
EIM register
12
NUM16_BYP_GRANT
CS0GCR2
11
DSZ[2]
CS0GCR1
10
AUS
CS0GCR1
[9:8]
CSREC[2:1]
CS0GCR1
[7:5]
RWSC[4:2]
WWSC[4:2]
CS0GCR1
CS0WCR
4
ERRST
WCR
3
RAL
CS0RCR1
Table continues on the next page...
Chapter 6 External Memory Controllers
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
237

<!-- page 238 -->

Table 6-2. EIM boot configuration (continued)
EIM_BOOT_CFG bus
EIM affected bits
EIM register
WAL
CS0WCR
2
MUM
OEA[1]
CS0GCR1
CS0RCR1
[1:0]
DSZ[1:0]
CS0GCR1
6.3.4
OneNAND requirements
By default, the Ready/Busy pin is not in use, perform these steps to configure the
OneNAND:
• Poll the device to see whether it is ready; software performs a read from the device.
• Connect the Ready/Busy signal of the OneNAND device to any GPIO pin and use it
as an interrupt that indicates the OneNAND device ready state.
EIM-PSRAM/NOR flash controller overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
238
NXP Semiconductors

