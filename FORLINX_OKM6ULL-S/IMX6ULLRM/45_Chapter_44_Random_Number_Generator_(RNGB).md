# Chapter 44: Random Number Generator (RNGB)

> Nguồn: `IMX6ULLRM.pdf` — trang 3091–3106

<!-- page 3091 -->

Chapter 44
Random Number Generator (RNGB)
44.1
Introduction
The purpose of the RNGB is to generate cryptographically strong random data.
It uses the True Random Number Generator (TRNG) and a Pseudo-Random Number
Generator (PRNG) to achieve a true randomness and cryptographic strength. The RNGB
generates random numbers for secret keys, per message secrets, random challenges, and
other similar quantities used in the cryptographic algorithms.
This chapter describes the Random Number Generator (RNGB), including the
programming model, functional description, and application information.
44.1.1
Block diagram
These figures show the RNGB's three main blocks: PRNG, TRNG, and XSEED
generator.
XSEED
Generator
PRNG
Internal Bus
Registers &
Internal Bus Interface
Random Number Generator
TRNG
FSM
SIM
Reseed
Figure 44-1. RNG block diagram
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3091

<!-- page 3092 -->

44.1.2
Features
The RNG includes these distinctive features:
• National Institute of Standards and Technology (NIST)-approved pseudo-random
number generator
• http://csrc.nist.gov
• Supports the key generation algorithm defined in the Digital Signature Standard
• http://www.itl.nist.gov/fipspubs/fip186.htm
• Integrated entropy sources capable of providing the PRNG with the entropy for its
seed.
44.2
Modes of operation
Operational modes of the RNGB can be found here.
44.2.1
Self-test mode
In this mode, the RNGB performs a self test of the statistical counters and the PRNG
algorithm to verify that the hardware is functioning properly. The self test takes ~29,000
cycles to complete. When the self test completes, an interrupt can be generated if there
are no outstanding commands in the command register. This mode is entered by setting
the RNG_CMD[ST] bit. When the self-test mode completes, the RNGB remains idle
until the seed mode is requested or the RNGB transitions to seed mode if the automatic
seeding is enabled.
44.2.2
Seed-generation mode
During the seed generation, the RNGB adds the entropy generated in the TRNG to the
256-bit XKEY register. The PRNG algorithm executes 20,000 entropy samples from the
TRNG to create an initial seed for the random number generation. At the same time, the
TRNG runs simple statistical tests on its output.
Modes of operation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3092
NXP Semiconductors

<!-- page 3093 -->

When the seed generation is complete, the TRNG reports the pass/fail result of the tests
through RNG_ESR. If the new seed passes the statistical tests, the RNG_SR[SDN] is set,
signalling that the RNG is ready to compute the secure pseudo-random data. The RNG
then transitions to the random number generation mode.
44.2.3
Random number generation mode
When the seed-generation mode completes and the output FIFO is empty, the RNG enters
this mode automatically. The random number generation mode quickly creates the
computationally-random data that is derived by the initial seed produced in the seed-
generation mode.
During the random number generation, a new 160-bit random number is generated
whenever the five-word output FIFO is empty. When the output FIFO contains data, the
RNGB automatically enters the sleep mode, waiting for the data to be read. When the
data is read, the RNGB generates a new 160-bit word and goes back to sleep.
After generating 220 words of random data, the RNGB lets the user know that it requires
reseeding through RNG_SR and continues to generate random data until it is directed to
reseed. However, if the auto-seeding is selected, the RNGB automatically completes the
seeding whenever it is needed.
44.3
Memory map/register definition
The following table shows the address map for the RNGB module. The detailed register
descriptions are explained in the following sections.
RNG memory map
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
228_4000
RNGB version ID register (RNG_VER)
32
R
1000_0280h
44.3.1/3094
228_4004
RNGB command register (RNG_CMD)
32
R/W
0000_0000h
44.3.2/3094
228_4008
RNGB control register (RNG_CR)
32
R/W
0000_0000h
44.3.3/3096
228_400C
RNGB status register (RNG_SR)
32
R
0000_500Dh
44.3.4/3098
228_4010
RNGB error status register (RNG_ESR)
32
R
0000_0000h
44.3.5/3100
228_4014
RNGB Output FIFO (RNG_OUT)
32
R
0000_0000h
44.3.6/3102
Chapter 44 Random Number Generator (RNGB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3093

<!-- page 3094 -->

44.3.1
RNGB version ID register (RNG_VER)
The read-only RNG_VER register contains the current version of the RNGB. It consists
of the RNG type and the major and minor revision numbers.
Address: 228_4000h base + 0h offset = 228_4000h
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
TYPE
0
MAJOR
MINOR
W
Reset 0
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
RNG_VER field descriptions
Field
Description
31–28
TYPE
Random number generator type
0000
RNGA
0001
RNGB (This is the type used in this module.)
0010
RNGC
Else
Reserved
27–16
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
15–8
MAJOR
Major version number
This field is always set to 0x02.
MINOR
Minor version number
Subject to change
44.3.2
RNGB command register (RNG_CMD)
The RNG_CMD controls the RNG's operating modes and interrupt status.
Address: 228_4000h base + 4h offset = 228_4004h
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
0
0
0
0
GS
ST
W
SR
CE
CI
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
Memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3094
NXP Semiconductors

<!-- page 3095 -->

RNG_CMD field descriptions
Field
Description
31–7
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
6
SR
Software reset
Perform a software reset of the RNGB. This bit is self-clearing.
0
Do not perform a software reset.
1
Software reset
5
CE
Clear the error.
Clear the errors in the RNG_ESR register and the RNGB interrupt. This bit is self-clearing.
0
Do not clear the errors and the interrupt.
1
Clear the errors and the interrupt.
4
CI
Clear the interrupt.
Clear the RNGB interrupt if an error is not present. This bit is self-clearing.
0
Do not clear the interrupt.
1
Clear the interrupt.
3–2
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
1
GS
Generate the seed.
Initiates the seed generation process. The seed generation starts.
• When the RNG_SR[BUSY] is cleared.
• If set simultaneously with the ST, after the self test.
When the seed generation process completes, this bit automatically clears and an interrupt can be
generated if all requested operations are complete.
0
Not in the seed generation mode
1
Generate the seed mode.
0
ST
Self test
Initiates a self test of the RNGB's internal logic. The self test starts.
• When RNG_SR[BUSY] is cleared.
• If set simultaneously with the GS, the self test takes the precedence and is completed first.
When the self test completes, this bit automatically clears and an interrupt may be generated if all
requested operations are complete.
0
Not in the self-test mode
1
Self-test mode
Chapter 44 Random Number Generator (RNGB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3095

<!-- page 3096 -->

44.3.3
RNGB control register (RNG_CR)
By using this register, the RNGB can be programmed to provide a slightly different
functionality based on its desired use.
Address: 228_4000h base + 8h offset = 228_4008h
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
0
MASKERR
MASKDONE
AR
0
FUFMOD
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
RNG_CR field descriptions
Field
Description
31–10
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
9–7
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
6
MASKERR
Mask the error interrupt.
Masks the interrupts generated by errors in the RNGB. These errors can still be viewed in RNG_ESR.
NOTE: Because the masked errors do not interrupt the operation of the RNGB and thus hide the
potentially fatal errors or conditions that can result in corrupted results, it is strongly
recommended to mask the errors while debugging. All errors are considered fatal, requiring the
RNGB to be reset. Until the reset occurs, the RNGB does not service any random data.
0
No mask is applied.
1
The mask applied to the error interrupt
5
MASKDONE
Mask the interrupt done.
Masks the interrupts generated upon the completion of the seed and self-test modes. The status of these
jobs can be viewed by:
• Reading the RNG_SR and viewing the seed done and the self-test done bits (RNG_SR[SDN,
STDN]).
• Viewing the RNG_CMD for the generate-seed or the self-test bits (RNG_CMD[GS,ST]) being set,
indicating that the operation is still taking place.
Table continues on the next page...
Memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3096
NXP Semiconductors

<!-- page 3097 -->

RNG_CR field descriptions (continued)
Field
Description
0
No mask is applied.
1
The mask is applied.
4
AR
Auto-reseed
Setting this bit enables the RNGB to automatically generate a new seed whenever it is needed. This
enables the software to never use the RNG_CMD[GS], although it is still possible. A new seed is needed
whenever the RNG_SR[RS] is set.
0
Do not enable the automatic reseeding.
1
Enable the automatic reseeding.
3–2
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
FUFMOD
FIFO underflow response mode
Controls the RNGB's response to a FIFO underflow condition.
00
Return all zeros and set the RNG_ESR[FUFE].
01
Return all zeros and set the RNG_ESR[FUFE].
10
Generate the bus transfer error
11
Generate the interrupt and return all zeros (overrides the RNG_CR[MASKERR]).
Chapter 44 Random Number Generator (RNGB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3097

<!-- page 3098 -->

44.3.4
RNGB status register (RNG_SR)
The RNGBSR is a read-only register which reflects the internal status of the RNGB.
Address: 228_4000h base + Ch offset = 228_400Ch
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
STATPF
ST_PF
0
ERR
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
FIFO_SIZE
FIFO_LVL
0
NSDN
SDN
STDN
RS
SLP
BUSY
1
W
Reset
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
1
1
0
1
RNG_SR field descriptions
Field
Description
31–24
STATPF
Statistics test pass failed.
Indicates the pass or fail status of the various statistics tests on the last seed generated.
• Bit 31 - Long run test (>34)
• Bit 30 - Length 6+ run test
• Bit 29 - Length 5 run test
• Bit 28 - Length 4 run test
• Bit 27 - Length 3 run test
• Bit 26 - Length 2 run test
• Bit 25 - Length 1 run test
• Bit 24 - Monobit test
0
Pass
1
Fail
23–21
ST_PF
Self-test pass fail
Indicates the pass or fail status of the TRNG, PRNG, and RESEED self tests.
• Bit 23 - TRNG self test pass/fail
Table continues on the next page...
Memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3098
NXP Semiconductors

<!-- page 3099 -->

RNG_SR field descriptions (continued)
Field
Description
• Bit 22 - PRNG self test pass/fail
• Bit 21 - RESEED self test pass/fail
0
Pass
1
Fail
20–17
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
16
ERR
Error
Indicates that an error was detected in the RNGB. Read the RNG_ESR register for details.
0
No error
1
Error detected
15–12
FIFO_SIZE
FIFO size
Size of the FIFO, and the maximum possible FIFO level. The bits must be interpreted as an integer. This
value is set to 5 on the default version of the RNGB.
11–8
FIFO_LVL
FIFO level
Indicates the number of random words currently in the output FIFO. The bits must be interpreted as an
integer.
7
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
6
NSDN
New seed done
Indicates that a new seed is ready for use during the next seed-generation process.
5
SDN
Seed done
Indicates that the RNG generated the first seed.
0
The seed-generation process is not complete.
1
Completed the seed generation since the last reset
4
STDN
Self test done
Indicates that the self test is complete. This bit is cleared by the hardware reset or a new self test is
initiated by setting the RNG_CMD[ST].
0
Self test not completed
1
Completed a self test since the last reset
3
RS
Reseed needed
Indicates that the RNGB needs to be reseeded. This is done by setting the RNG_CMD[GS], or
automatically if the RNG_CR[AR] is set.
0
The RNGB does not need to be reseeded.
1
The RNGB needs to be reseeded.
2
SLP
Sleep
Indicates whether the RNGB is in the sleep mode. When set, the RNGB is in the sleep mode and all
internal clocks are disabled. While in this mode, access to the FIFO is allowed. Once the FIFO is empty,
the RNGB fills the FIFO and then enters sleep mode again.
Table continues on the next page...
Chapter 44 Random Number Generator (RNGB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3099

<!-- page 3100 -->

RNG_SR field descriptions (continued)
Field
Description
0
The RNGB is not in the sleep mode.
1
The RNGB is in the sleep mode.
1
BUSY
Busy.
Reflects the current state of the RNGB. If the RNGB is currently seeding, generating the next seed,
creating a new random number, or performing a self test, this bit is set.
0
Not busy
1
Busy
0
Reserved
This field is reserved.
This read-only field is reserved and always has the value 1.
44.3.5
RNGB error status register (RNG_ESR)
Address: 228_4000h base + 10h offset = 228_4010h
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
FUFE
SATE
STE
OSCE
LFE
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
RNG_ESR field descriptions
Field
Description
31–5
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3100
NXP Semiconductors

<!-- page 3101 -->

RNG_ESR field descriptions (continued)
Field
Description
4
FUFE
FIFO underflow error
Indicates that the RNGB has experienced a FIFO underflow condition, resulting in the last random data
read being unreliable. This bit can be masked by the RNG_CR[FUFMOD] and is cleared by a hardware or
software reset or by writing 1 to the RNG_CMD[CE].
0
FIFO underflow did not occur.
1
FIFO underflow occurred.
3
SATE
Statistical test error
Indicates whether the RNGB failed the statistical tests for the last generated seed. This bit is sticky and is
cleared by a hardware or software reset or by writing 1 to the RNG_CMD[CE].
0
The RNGB did not fail the statistical tests.
1
The RNGB failed the statistical tests during the initialization.
2
STE
Self-test error
Indicates that the RNGB failed the most recent self test. This bit is sticky and can only be reset by a
hardware reset or by writing 1 to the RNG_CMD[CE].
0
The RNGB did not fail the self test.
1
The RNGB failed the self test.
1
OSCE
Oscillator error
Indicates that the oscillator in the RNG can be broken. This bit is sticky and can only be cleared by a
software or hardware reset.
0
The RNG oscillator is working properly.
1
A problem with the RNG oscillator was detected.
0
LFE
Linear feedback shift register (LFSR) error
When this bit is set, the interrupt generated was caused by a failure of one of the LFSRs in one of the
RNGB's three entropy sources. This bit is sticky and can only be cleared by a software or hardware reset.
0
The LFSRs are working properly.
1
The LFSR failure occurred.
Chapter 44 Random Number Generator (RNGB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3101

<!-- page 3102 -->

44.3.6
RNGB Output FIFO (RNG_OUT)
The RNGBOUT provides a temporary storage for the random data generated by the
RNGB. This enables the user to read multiple random longwords back-to-back. A read of
this address when the FIFO is not empty returns 32 bits of random data. If the FIFO is
read when empty, a FIFO underrun response is returned according to the
RNG_CR[FUFMOD]. For optimal system performance, poll the RNG_SR[FIFO_LVL]
to ensure that random values are present before reading the FIFO.
Address: 228_4000h base + 14h offset = 228_4014h
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
RANDOUT
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
RNG_OUT field descriptions
Field
Description
RANDOUT
Random output
44.4
Functional description
The RNGB performs two functional operations: the seed generation and the random
number generation.
These operations (described in Modes of operation) are performed in conjunction with
the major functional blocks in the RNGB described below.
44.4.1
Pseudo-Random Number Generator (PRNG)
The PRNG implements the NIST-approved PRNG described in the Digital Signature
Standard. The 160-bit output of the SHA-1 block are the next five words of random data.
The PRNG is designed to generate 220 words of random data before requiring reseeding,
using the TRNG only during the seeding/initialization process. The initial seed takes
approximately two million clock cycles. After this, the RNGB can generate five 32-bit
words every 112 clock cycles. The reseeding takes place transparently using the
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3102
NXP Semiconductors

<!-- page 3103 -->

simultaneous reseed LFSRs. The entropy stored in this 128-bit LFSR and the 128-bit shift
register is added directly into the XKEY structure via the RNGB XSEED generator
whenever the reseeding is required.
44.4.2
True Random Number Generator (TRNG)
The TRNG comprises of two entropy sources, with each providing a single bit of output.
Concatenated together, these two output bits are expected to provide one bit of entropy
every 100 clock cycles. In addition to generating the entropy, the TRNG also performs
several statistical tests on its output. The pass/fail status of these tests is reflected in the
RNG_ESR.
44.4.3
Resets
There are two ways to reset the RNGB: the power-on/hardware reset and the software
reset. The software reset is functionally equivalent to the power-on/hardware reset. The
power-on/hardware reset is asynchronous. The software reset is performed by setting the
RNG_CMD[SR] bit. The resets are summarized in this table:
Table 44-1. Reset summary
Reset
Source
Characteristics
Internal resets
Effect on the external
signal
Hardware
ipg_hard_async_reset_b
Active-low,
asynchronous,
minimum 1-cycle
Resets all interface
registers and puts the
RNGB into the IDLE
state
—
Software
RNG_CMD[SR]
Active-high
Resets all interface
registers and puts the
RNGB into the IDLE
state
—
44.4.3.1
Power-on/hardware reset
Asserting the ipg_hard_async_reset_b signal sets all interface registers to their default
state and puts the state machine into the IDLE state.
Chapter 44 Random Number Generator (RNGB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3103

<!-- page 3104 -->

44.4.3.2
Software reset
The software reset is functionally equivalent to the hardware reset, but enables the RNGB
to be fully reset by writing to the SW_RST bit (bit-6) into the RNGB command register.
This bit is self-resetting. The software reset can be performed at any time.
44.4.4
RNG interrupts
There is a single RNG interrupt , generated to the processor's interrupt controller. The
source of the interrupt is determined by reading the RNG status register. If an error is the
cause of the interrupt, further information is available by reading the RNG error status
register. The interrupts can be masked by the RNG_CR[MASKDONE or MASKERR]
bits.
It is strongly recommended to mask the error interrupt only while debugging because
masking the error interrupt can hide the potentially fatal errors or conditions that can
result in corrupted results. All errors are considered fatal, requiring the RNG to be reset.
The RNG does not service any random data until a reset occurs.
The available interrupt sources are described in this table:
Table 44-2. RNG interrupt sources
Sources
Status bit field
RNG_CR
mask bit field
Description
Seed generation done
RNG_SR[SDN]
MASKDONE
The first seed was generated
Self test done
RNG_SR[STDN]
MASKDONE
Self test finished
Error
RNG_SR[ERR]
MASKERR
Error detected—see RNG_ESR for details
Linear Feedback Shift
Register (LFSR)
RNG_ESR[LSFRE]
MASKERR
Fault in one of the TRNG's LFSRs
Oscillator
RNG_ESR[OSCE]
MASKERR
TRNG ring oscillator may be
malfunctioning
Self test
RNG_ESR[STE]
MASKERR
Self test failed
Statistical test
RNG_ESR[SATE]
MASKERR
Statistics test for the last seed generation
failed
FIFO underflow
RNG_ESR[FUFE]
MASKERR
FIFO read while empty
44.5
Initialization/application information
The information located here describes the module initialization.
Initialization/application information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3104
NXP Semiconductors

<!-- page 3105 -->

44.5.1
Manual seeding
The intended general operation of the RNGB is as follows:
1. Reset/initialize.
2. Write to the RNG_CR to setup the RNGB for the desired functionality.
3. Write to the RNG_CMD to run the self test or seed generation.
4. Wait for an interrupt to indicate the completion of the requested operation(s).
5. Repeat steps 3–4 if the seed generation is not complete.
6. Poll the RNG_SR for the FIFO level.
7. Read the available random data from the output FIFO.
8. Repeat steps 6 and 7 as needed, until 220 words are generated.
9. Write to the RNG_CMD to run the seed mode.
10. Repeat steps 4–9.
44.5.2
Automatic seeding
The intended general operation of the RNGB with the automatic seeding enabled is as
follows:
1. Reset/initialize.
2. Write to the RNG_CR to setup the RNGB for automatic seeding and the desired
functionality.
3. Wait for an interrupt to indicate the completion of the first seed.
4. Poll the RNG_SR for the FIFO level.
5. Read the available random data from the output FIFO.
6. Repeat steps 4 and 5 as needed. The automatic seeding occurs when necessary and is
transparent to the operation.
Chapter 44 Random Number Generator (RNGB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3105

<!-- page 3106 -->

Initialization/application information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3106
NXP Semiconductors

