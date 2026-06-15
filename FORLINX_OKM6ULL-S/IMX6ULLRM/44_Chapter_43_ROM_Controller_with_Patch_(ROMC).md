# Chapter 43: ROM Controller with Patch (ROMC)

> Nguồn: `IMX6ULLRM.pdf` — trang 3075–3090

<!-- page 3075 -->

Chapter 43
ROM Controller with Patch (ROMC)
43.1
Overview
The Read Only Memory Controller with ROM Patch (ROMC) acts as an interface
between the Arm advanced high-performance bus (AHB - Lite) and the Read Only
Memory. The ROMC consists of a ROM Controller and a ROM Patch. The ROM Patch
is used to either patch code routines or fix data tables in the ROM area. There is an IP
Bus interface to access the ROM Patch Registers. The following figure depicts the main
functional sub-blocks of the ROMC.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3075

<!-- page 3076 -->

ROMC
AHB
Signals
hr data
rom_data
rompatch_data
rompatch
override
ROM
Patch
IP Bus
(to Registers)
ROM
Controller
(ROMC)
addr, ce
ROM
BIST
hready
Figure 43-1. ROMC Block Diagram
43.1.1
Features
• Supports ROM size ranges from 16 Kbyte up to 4 Mbyte with increments of 1 Kbyte
• Supports opcode patching for a maximum of 16 different addresses in 4 Mbytes of
ROM space
• Supports one-word data fixes for a max of 8 memory locations in 4 Mbytes of ROM
space
• Supports patching of the Reset Vector (at 0x0000_0000) to allow external booting
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3076
NXP Semiconductors

<!-- page 3077 -->

43.1.2
Modes of Operation
There are two modes of operation: normal mode and BIST mode. In normal mode, the
ROMC ensures correct reads from the ROM, assuming the memory complies with the
characteristics and requirements for which the ROMC was designed.
43.1.2.1
Low Power Mode
There are two clock enables that are used to switch off parts of the ROMC logic when
inactive. The first clock enable is used to disable the ROM Controller when the master
connected to the AHB interface is not initiating a read to the ROM. The second clock
enable is used to disable the registers used to program the ROM patch feature when the
registers are not being accessed.
43.2
Clocks
The table found here describes the clock sources for ROMCP.
Please see Clock Controller Module (CCM) for clock setting, configuration and gating
information.
Table 43-1. ROMCP Clocks
Clock name
Clock Root
Description
hclk
ahb_clk_root
System / bus clock
hclk_reg
ipg_clk_root
System access clock
96krom_CLK
ahb_clk_root
ROM clock
43.3
Memory Map
43.3.1
ROM Memory Map in detail
The ROMC supports ROM sizes with a range of 16 Kbyte to 4 Mbyte with an increment
of 1 Kbyte. The 16 Kbyte lower limit was chosen because the minimum size of security
code on an Arm platform is approximately 16 Kbyte of code, which is only accessible in
supervisor mode. Note that it is the MMU that controls whether any region of memory is
secure.
Chapter 43 ROM Controller with Patch (ROMC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3077

<!-- page 3078 -->

The exception vectors must be secured as well, and must be put in the same area as the
security code. Since they must reside at address 0x0000_0000, the entire 16 Kbyte of
ROM which can only be accessible in supervisor mode is located at the very beginning of
the platform memory map.
If the user chooses not to use the security code, a memory size smaller than 16 Kbyte can
be connected to the platform (minimum of 1 Kbyte). The MMU can be programmed to
allow any kind of access into this memory. However, if the ROM size is less than 16
Kbyte, memory aliasing will occur for all invalid addresses greater than the memory size
but within the 16 Kbyte of space.
For ROM sizes bigger than 16 Kbyte, the rest of its physical size resides at the address
starting at 0x0040_4000 (4 M+16 Kbyte) going up to [0x0040_4000 + (mem. size -
16Kbyte)]. .
43.4
Functional Description
This section is divided up into the ROM Controller Functional Description and the
ROMC functional description.
43.4.1
ROM Controller (ROMC) Functional Description
43.4.1.1
Functionality overview
The ROMC serves two main functions. First, as an interface between the AHB-Lite bus
on an Arm platform and the ROM. Second, it drives and receives several signals for the
BIST engine. In normal mode of operation, the ROMC monitors the AHB-Lite for
memory access requests and performs the memory operation to the ROM.
The ROMC includes the option to wait state all accesses from either the Arm or non-Arm
masters to ROM in the event that timing requirements will not allow single HCLK clock
cycle reads. If a wait state is required, the static inputs rom_wait_arm or
rom_wait_alt_mstr can be set to 1 and accesses will take two HCLK clock cycles. If wait
states are not required, rom_wait_arm or rom_wait_alt_mstr can be set to 0 and accesses
will take one HCLK clock cycle to complete.
43.4.2
ROMC Functional Description
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3078
NXP Semiconductors

<!-- page 3079 -->

43.4.2.1
ROMC Disabling
All the bits in the ROMC_ROMPATCHENL register are cleared on Reset, disabling all
the address comparators. Once the comparators have been enabled, the ROMC functions
of data fixing and opcode patching can be quickly disabled by setting the DIS bit in the
ROMC_ROMPATCHCNTL register. This bit is used to enable secure operations in
which patching functions need to be disabled. This bit is cleared on Reset.
43.4.2.2
ROMC Event Priority
The ROMC has a total of 16 address comparators. The first 8 (0 through 7) comparators
can be programmed for the data fixing function (through the 8 data fix enable bits in the
ROMC_ROMPATCHCNTL register) while the rest are for opcode patching by default.
This allows for potential multiple matching events involving both data fixing and opcode
patch types. In these cases the ROMC assigns the highest priority to a data fixing event.
For example, if the ROMC is set up to data fix a certain address with comparator 4 and
also opcode patch the same address with comparator 7, it will let comparator 4 have
higher priority in indicating a match, and data from ROMC_ROMPATCHD4 will be put
on the rompatch_romc_hrdata bus as the override value.
If multiple address matches of the same type level occur concurrently, then the ROMC
will choose the source number based on the one with the highest source number. For
example, the ROMC is setup to data fix the same location with address comparators 4
and 7, then address comparator 7 will have higher priority in indicating a match, and the
value from ROMC_ROMPATCHD7 will be put on the rompatch_romc_hrdata bus as the
orverride value. The same priority applies for an opcode patch event, except the override
data is in the form of an SWI instruction with the comment field set to the source number
with the highest priority.
43.4.2.3
Data Fixing
The data fixing feature allows ROM data to be updated by direct replacement when it is
being read. This data usually originates from data tables, but can include Arm
instructions. To enable data fixing on a certain address, this address value is written in to
one of the first eight (0 through 7) of ROMC_ROMPATCHAxx registers and the same
numbered bit set in the ROMC_ROMPATCHENL and ROMC_ROMPATCHCNTL
registers. The data to be used for replacement is placed in the corresponding
ROMC_ROMPATCHDxx.
Chapter 43 ROM Controller with Patch (ROMC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3079

<!-- page 3080 -->

The ROMC looks for a read access to ROM (either code fetch or data load) by snooping
the AHB interface for read transactions. The address is compared with the values stored
in the ROMC_ROMPATCHAxx[22:2] registers. If a match occurs from one of the
comparators, the ROMC places the value in the corresponding ROMC_ROMPATCHDxx
register on the read data bus by overriding the read data coming from the actual ROM
(see the mux in Figure 43-1). The value on the read data bus is maintained until hready is
asserted to terminate the access. In data fixing, the entire word is replaced so if a byte or
half-word access occurs on a "data fix" location, the entire data word is replaced. The
word being replaced is word aligned. (The two LSBs of the matching
ROMC_ROMPATCHAxx are ignored in the data fix operation.)
43.4.2.4
Opcode Patching
The opcode patch feature provides the Arm core a mechanism to fetch updated versions
of code routines that were originally programmed in ROM. This patching mechanism
makes use of the SWI (software interrupt instruction) and a table of function pointers
residing in writable memory. The opcode being patched is replaced with a SWI
instruction by the ROMC. Subsequent processing of the SWI reads from a function
pointers table to obtain the address of the replacement code. Execution resumes with this
code patch.
To enable opcode patching of a certain address, this address value is written into one of
the ROMPATCHAxx registers and the corresponding bit set in the ROMPATCHENL to
enable the associated comparator. The register's LSB (ROMC_ROMPATCHxx[0])
should be set if THUMB mode patching is in effect for this address. The ROMC
identifies a ROM read access by snooping the AHB interface. The address is compared
with the values stored in the ROMC_ROMPATCHAxx[22:2] registers. If a match occurs
from one of the comparators, the ROMC generates the opcode of a software interrupt
(SWI) instruction with the comment field containing the number of the matching address
comparator. This opcode and comment is placed on the read data bus until hready is
asserted by the ROM controller to terminate the read access.
The type of SWI generated, (that is, either Arm or THUMB), is determined by the LSB
of the ROMC_ROMPATCHAxx register associated with the opcode patch. This bit is
cleared for Arm mode (32 bits). The ROMC generates a 32-bit SWI (opcode field is
0xEF, occupying bits [31:24] of the word), with the least significant 5 bits of the 24-bit
comment field (bits [23:0]) containing the number of the matching address comparator.
The rest of the comment field is filled with zeros. This means that the ROMC will use 16
of the 16777216 possible software interrupts. The ROMC overrides the read data from
the ROM.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3080
NXP Semiconductors

<!-- page 3081 -->

If the LSB of the matching ROMC_ROMPATCHAxx register is set, the opcode patch is
in THUMB mode (16 bits or half word). The ROMC generates a 16-bit SWI instruction
(opcode field is 0xDF, occupying bits [15:8] of the half word) with the least significant 5
bits of the 8-bit comment field containing with the source number of the address
comparator. The rest of the comments field is filled with zeros. This means that the
ROMC will use 16 of the 256 possible software interrupts. The ROMC puts this 16 bit
SWI instruction value on the proper half of the rompatch_romc_hrdata bus. The other
half is zeroed out. Which half of the bus contains the SWI opcode and comment depends
on the mode (Big Endian or Little Endian) and the bit 1 of the matching
ROMC_ROMPATCHAxx register. In Little Endian mode, the lower half is bits {15:0]
and the upper half is bits {31:16]. The order is reversed in Big Endian mode.
In Little Endian mode (bigend signal negated), if bit 1 of the matching
ROMC_ROMPATCHAxx is cleared (lower half word selected) then the SWI instruction
is put on the lower 16 bits of the read data bus and the upper 16 bits are zeroed out. Only
the lower 16 bits of the read data bus is overwritten by the ROMC data. If
ROMC_ROMPATCHAxx[1] is set (upper half word selected), the SWI instruction is put
on the upper 16 bits of the read data bus and the lower 16 bits are zeroed out. Only the
upper 16 bits of the read data bus is overwritten.
In Big Endian mode (bigend asserted), if bit 1 of the matching ROMC_ROMPATCHAxx
is cleared (lower half word selected) then the SWI instruction is put on the upper 16 bits
of the read data bus while the lower 16 bits are zeroed out. Only the upper 16 bits of the
read data bus is overwritten. If ROMC_ROMPATCHAxx[1] is set (upper word selected),
the SWI instruction is put on the lower 16 bits and the upper 16 bits are zeroed out. Only
the lower 16 bits of the read data bus is overwritten.
The eventual execution of the SWI causes the Arm to save the CPSR in SPSR_SVC, the
address of the next instruction after the SWI in R14_SVC, enter Supervisor mode, and
fetch the SWI vector at 0x8, which then takes it to a handler for further processing as
described in the next section.
43.4.2.4.1
Typical Software Response to Opcode Patch
When the SWI handler executes it needs to determine whether the SWI was generated by
the ROMC. This is done by loading the SWI instruction and extracting its comment field.
The state of the Arm core (Arm or THUMB) when the SWI was executed dictates
whether to load the instruction word (Arm) or half word (THUMB). This state
information can be determined by testing the T bit (bit 5) of the SPSR. If it's set, the
execution was in THUMB mode.
Chapter 43 ROM Controller with Patch (ROMC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3081

<!-- page 3082 -->

By convention, if the comment field of the SWI is greater than 16, the software interrupt
was initiated by software (i.e. an operating system call), and a branch is taken to the
appropriate handler routine for further processing. If the comment field is less than 16,
the SWI was generated by the ROMC performing a code patch operation. In this case, the
software then reads from a table of function pointers, using the value in the SWI
comment field as the index into the table. The value that is read is the address of the code
patch. This value is loaded into the PC to begin the execution of the code patch. The
following code segment illustrates a typical handling of the SWI.
          stmfd        sp!, {r0-r1,lr}       @ push register onto SWI stack
          mrs         r0, spsr        @ get saved status register
          tst          r0, #0x20     @ check if call was in THUMB mode
          ldrneh      r0, [lr,#-2]       @ yes: load opcode half-word and
          bicne       r0, r0, #0xff00   @ yes: extract THUMB comment
          ldreq       r0, [lr,#-4]       @ no: load opcode word and
          biceq       r0, r0, #0xff000000 @ no: extract ARM comment
                               @ now r0 has comment field
          cmp        r0, #16      @ compare to 16 (maximum for ROMC)
          ldrlt         lr, =rompatch_tbl_ptr @ < 16: get top of current ROMC
                               @ table; global variable which is 
                               @ changeable per context
          ldrlt         r1, [lr, r0, lsl #2]   @ < 16: read function pointer from 
                               @ table assumed an array of pointers
                               @ patch functions
          strlt          r1, [sp, #8]     @ < 16: store function pointer onto
                               @ stack in position of link register
          ldmltfd       sp!, {r0-r1,pc}^      @ < 16: "fake" return from SWI, will
                               @ vector core to appropriate patch 
                               @ function and set core back to previous
                               @ mode of operating
          ldr         r1, =swi_hdler   @ >= 16: pointer to standard SWI 
                               @ handler
          mov        lr, pc         @ >= 16: set link register
          bx         r1          @ >= 16: jump to standard SWI
                               @ handler
          ldmfd       sp!, {r0-r1,pc}^      @ >= 16: pop registers from stack
43.4.2.5
External Boot Feature
Following a Reset event, the Arm issues an instruction fetch of the Reset Vector from
address 0x0. This instruction, normally residing in ROM is usually a branch to a Reset
handler or boot code which also normally resides in ROM. The ROMC external boot
feature allows the bypassing of this code, using a different boot code residing perhaps in
external memory.
This feature uses the data fix mechanism and works as follows: if the boot_int signal is
negated when a Reset event occurred, the ROMC will perform a data fix of the Reset
Vector at 0x0 with the following instruction (opcode 0xE59FF00C):
          ldr         pc,[pc,#12]      @ read 0x0000_0014 for reset_vector
The value of PC when this instruction is executed is 8 so that a PC relative offset of 12
makes the source address 20 or 0x14. When this instruction executes, the Arm core reads
from address 0x0000_0014, triggering a ROMC data fix operation which places the value
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3082
NXP Semiconductors

<!-- page 3083 -->

taken from the external boot address on the read data bus, with the two LSBs zeroed out.
This value is returned to the Arm to be placed in the PC causing code fetch and execution
to start from that address.
43.4.2.6
Alternate Masters and ROMC
The ROMC sits on the AHB bus of the internal ROM (ROMC). This means that the
ROMC can modify values on the read data bus going to the master. Therefore, any
master which reads an opcode patched or data patched location will read patched data.
43.5
ROMCP Memory Map/Register Definition
All registers are accessible through an IP Bus and can only be accessed in privileged
mode. These registers can only be written with 32-bits stores and are clocked by
hclk_reg.
ROMC memory map
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
21A_C0D4
ROMC Data Registers (ROMC_ROMPATCH7D)
32
R/W
0000_0000h
43.5.1/3084
21A_C0D8
ROMC Data Registers (ROMC_ROMPATCH6D)
32
R/W
0000_0000h
43.5.1/3084
21A_C0DC
ROMC Data Registers (ROMC_ROMPATCH5D)
32
R/W
0000_0000h
43.5.1/3084
21A_C0E0
ROMC Data Registers (ROMC_ROMPATCH4D)
32
R/W
0000_0000h
43.5.1/3084
21A_C0E4
ROMC Data Registers (ROMC_ROMPATCH3D)
32
R/W
0000_0000h
43.5.1/3084
21A_C0E8
ROMC Data Registers (ROMC_ROMPATCH2D)
32
R/W
0000_0000h
43.5.1/3084
21A_C0EC
ROMC Data Registers (ROMC_ROMPATCH1D)
32
R/W
0000_0000h
43.5.1/3084
21A_C0F0
ROMC Data Registers (ROMC_ROMPATCH0D)
32
R/W
0000_0000h
43.5.1/3084
21A_C0F4
ROMC Control Register (ROMC_ROMPATCHCNTL)
32
R/W
0840_0000h
43.5.2/3085
21A_C0F8
ROMC Enable Register High (ROMC_ROMPATCHENH)
32
R
0000_0000h
43.5.3/3086
21A_C0FC
ROMC Enable Register Low (ROMC_ROMPATCHENL)
32
R/W
0000_0000h
43.5.4/3086
21A_C100
ROMC Address Registers (ROMC_ROMPATCH0A)
32
R/W
0000_0000h
43.5.5/3087
21A_C104
ROMC Address Registers (ROMC_ROMPATCH1A)
32
R/W
0000_0000h
43.5.5/3087
21A_C108
ROMC Address Registers (ROMC_ROMPATCH2A)
32
R/W
0000_0000h
43.5.5/3087
21A_C10C
ROMC Address Registers (ROMC_ROMPATCH3A)
32
R/W
0000_0000h
43.5.5/3087
21A_C110
ROMC Address Registers (ROMC_ROMPATCH4A)
32
R/W
0000_0000h
43.5.5/3087
21A_C114
ROMC Address Registers (ROMC_ROMPATCH5A)
32
R/W
0000_0000h
43.5.5/3087
21A_C118
ROMC Address Registers (ROMC_ROMPATCH6A)
32
R/W
0000_0000h
43.5.5/3087
Table continues on the next page...
Chapter 43 ROM Controller with Patch (ROMC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3083

<!-- page 3084 -->

ROMC memory map (continued)
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
21A_C11C
ROMC Address Registers (ROMC_ROMPATCH7A)
32
R/W
0000_0000h
43.5.5/3087
21A_C120
ROMC Address Registers (ROMC_ROMPATCH8A)
32
R/W
0000_0000h
43.5.5/3087
21A_C124
ROMC Address Registers (ROMC_ROMPATCH9A)
32
R/W
0000_0000h
43.5.5/3087
21A_C128
ROMC Address Registers (ROMC_ROMPATCH10A)
32
R/W
0000_0000h
43.5.5/3087
21A_C12C
ROMC Address Registers (ROMC_ROMPATCH11A)
32
R/W
0000_0000h
43.5.5/3087
21A_C130
ROMC Address Registers (ROMC_ROMPATCH12A)
32
R/W
0000_0000h
43.5.5/3087
21A_C134
ROMC Address Registers (ROMC_ROMPATCH13A)
32
R/W
0000_0000h
43.5.5/3087
21A_C138
ROMC Address Registers (ROMC_ROMPATCH14A)
32
R/W
0000_0000h
43.5.5/3087
21A_C13C
ROMC Address Registers (ROMC_ROMPATCH15A)
32
R/W
0000_0000h
43.5.5/3087
21A_C208
ROMC Status Register (ROMC_ROMPATCHSR)
32
w1c
0000_0000h
43.5.6/3088
43.5.1
ROMC Data Registers (ROMC_ROMPATCHnD)
The ROMC data registers (ROMC_ROMPATCH 7D through ROMC_ROMPATCH 0D)
store the data to use for the 8 1-word data fix events. Each register is associated with an
address comparator ( 7 through 0). When a data fixing event occurs, the value in the data
register corresponding to the comparator that has the address match is put on the
romc_hrdata[31:0] bus until romc_hready is asserted by the ROM controller to terminate
the access. A MUX external to the ROMC will select this data over that of
romc_hrdata[31:0] in returning read data to the Arm core. The selection is done with the
control bus rompatch_romc_hrdata_ovr[1:0] with both bits asserted by the ROMC.
If more than one address comparators match, the highest-numbered one takes precedence,
and the value in corresponding data register is used for the patching event.
Address: 21A_C000h base + D4h offset + (4d × i), where i=0d to 7d
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
DATAX
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
ROMC_ROMPATCHnD field descriptions
Field
Description
DATAX
Data Fix Registers - Stores the data used for 1-word data fix operations.
The values stored within these registers do not affect the writes to the memory system. They are selected
over the read data from ROM when a data fix event occurs.
If any part of the 1-word data fix is read, then the entire word is replaced. Therefore, a byte or half-word
read will cause the ROMC to replace the entire word. The word is word address aligned.
ROMCP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3084
NXP Semiconductors

<!-- page 3085 -->

43.5.2
ROMC Control Register (ROMC_ROMPATCHCNTL)
The ROMC control register (ROMC_ROMPATCHCNTL) contains the block disable bit
and the data fix enable bits. The block disable bit provides a means to disable the ROMC
data fix and opcode patching functions, even when the address comparators are enabled.
The External Boot feature is not affected by this bit. The eight data fix enable bits (0
through 7), when set, assign the associated address comparators to data fix operations
NOTE
Bits 27 and 22 always read as 1s.
Address: 21A_C000h base + F4h offset = 21A_C0F4h
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
DIS
Reserved
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
1
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
DATAFIX
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
ROMC_ROMPATCHCNTL field descriptions
Field
Description
31–30
-
This field is reserved.
Reserved
29
DIS
ROMC Disable -- This bit, when set, disables all ROMC operations.
This bit is used to enable secure operations.
0
Does not affect any ROMC functions (default)
1
Disable all ROMC functions: data fixing, and opcode patching
28–8
-
This field is reserved.
Reserved
DATAFIX
Data Fix Enable - Controls the use of the first 8 address comparators for 1-word data fix or for
code patch routine.
0
Address comparator triggers a opcode patch
1
Address comparator triggers a data fix
Chapter 43 ROM Controller with Patch (ROMC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3085

<!-- page 3086 -->

43.5.3
ROMC Enable Register High (ROMC_ROMPATCHENH)
The ROMC enable register high (ROMC_ROMPATCHENH) and ROMC enable register
low (ROMC_ROMPATCHENL) control whether or not the associated address
comparator can trigger a opcode patch or data fix event. This implementation of the
ROMC only has 16 comparators, therefore ROMC_ROMPATCHENH and the upper half
of ROMC_OMPATCHENL are read-only. ROMC_ROMPATCHENL[15:0] are
associated with comparators 15 through 0. ROMC_ROMPATCHENLH[31:0] would
have been associated with comparators 63 through 32.
Address: 21A_C000h base + F8h offset = 21A_C0F8h
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
ROMC_ROMPATCHENH field descriptions
Field
Description
-
This field is reserved.
Reserved
43.5.4
ROMC Enable Register Low (ROMC_ROMPATCHENL)
The ROMC enable register high (ROMC_ROMPATCHENH) and ROMC enable register
low (ROMC_ROMPATCHENL) control whether or not the associated address
comparator can trigger a opcode patch or data fix event. This implementation of the
ROMC only has 16 comparators, therefore ROMC_ROMPATCHENH and the upper half
of ROMC_ROMPATCHENL are read-only. ROMC_ROMPATCHENL[15:0] are
associated with comparators 15 through 0. ROMC_ROMPATCHENLH[31:0] would
have been associated with comparators 63 through 32.
Address: 21A_C000h base + FCh offset = 21A_C0FCh
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
ENABLE
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
ROMCP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3086
NXP Semiconductors

<!-- page 3087 -->

ROMC_ROMPATCHENL field descriptions
Field
Description
31–16
Reserved
This field is reserved.
ENABLE
Enable Address Comparator - This bit enables the corresponding address comparator to trigger an
event.
0
Address comparator disabled
1
Address comparator enabled, ROMC will trigger a opcode patch or data fix event upon matching of
the associated address
43.5.5
ROMC Address Registers (ROMC_ROMPATCHnA)
The ROMC address registers (ROMC_ROMPATCHA0 through
ROMC_ROMPATCHA15) store the memory addresses where opcode patching begins
and data fixing occurs. The address registers ROMC_ROMPATCHA0 through
ROMC_ROMPATCHA15 are each 21 bits wide and dedicated to one 4 Mbyte memory
space. Bits 21 through 2 are address bits, to be compared with romc_haddr[21:2] for a
match; bit 1 is also an address bit used for half word selection. Bit 0 is the mode bit (set
to 1 for THUMB mode). 1-word data fixing can only be used on the first 8 of the address
comparators. ROMC_ROMPATCHA0 through ROMC_ROMPATCHA15 are associated
each with address comparators 0 through 15.
Address: 21A_C000h base + 100h offset + (4d × i), where i=0d to 15d
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
ADDRX
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
ADDRX
THUMBX
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
ROMC_ROMPATCHnA field descriptions
Field
Description
31–23
-
This field is reserved.
Reserved
Table continues on the next page...
Chapter 43 ROM Controller with Patch (ROMC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3087

<!-- page 3088 -->

ROMC_ROMPATCHnA field descriptions (continued)
Field
Description
22–1
ADDRX
Address Comparator Registers - Indicates the memory address to be watched. All 16 registers can be
used for code patch address comparison. Only the first 8 registers can be used for a 1-word data fix
address comparison.
Bit 1 is ignored if data fix. Only used in code patch
0
THUMBX
THUMB Comparator Select - Indicates that this address will trigger a THUMB opcode patch or an Arm
opcode patch. If this watchpoint is selected to be a data fix, then this bit is ignored as all data fixes are 1-
word data fixes.
0
Arm patch
1
THUMB patch (ignore if data fix)
43.5.6
ROMC Status Register (ROMC_ROMPATCHSR)
The ROMC status register (ROMC_ROMPATCHSR) indicates the current state of the
ROMC and the source number of the most recent address comparator event.
Address: 21A_C000h base + 208h offset = 21A_C208h
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
SW
Reserv
ed
W
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
SOURCE
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
ROMC_ROMPATCHSR field descriptions
Field
Description
31–18
-
This field is reserved.
Reserved
17
SW
ROMC AHB Multiple Address Comparator matches Indicator - Indicates that multiple address comparator
matches occurred. Writing a 1 to this bit will clear this it.
0
no event or comparator collisions
1
a collision has occurred
16–6
-
This field is reserved.
Reserved
SOURCE
ROMC Source Number - Binary encoding of the number of the address comparator which has an address
match in the most recent patch event on ROMC AHB. If multiple matches occurred, the highest priority
source number is used.
Table continues on the next page...
ROMCP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3088
NXP Semiconductors

<!-- page 3089 -->

ROMC_ROMPATCHSR field descriptions (continued)
Field
Description
0
Address Comparator 0 matched
1
Address Comparator 1 matched
15
Address Comparator 15 matched
Chapter 43 ROM Controller with Patch (ROMC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3089

<!-- page 3090 -->

ROMCP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3090
NXP Semiconductors

