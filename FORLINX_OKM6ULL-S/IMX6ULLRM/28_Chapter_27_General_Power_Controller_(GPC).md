# Chapter 27: General Power Controller (GPC)

> Nguồn: `IMX6ULLRM.pdf` — trang 1325–1342

<!-- page 1325 -->

Chapter 27
General Power Controller (GPC)
27.1
Overview
The General Power Control (GPC) block includes the sub-blocks listed here.
• CPU Power Gating Control (PGC)
Each sub-block has its own IP registers.
GPC determines wake-up IRQ for exiting WAIT/STOP mode (with or without CPU
power gating).
Figure 27-1. GPC Block Diagram
27.2
Clocks
The table found here describes the clock sources for GPC.
Please see Clock Controller Module (CCM) for clock setting, configuration and gating
information.
Table 27-1. GPC Clocks
Clock name
Clock Root
Description
ipg_clk
ipg_clk_root
Peripheral clock
ipg_clk_s
ipg_clk_root
Peripheral access clock
pgc_clk
ipg_clk_root
PGC peripheral clock
sys_clk
ipg_clk_root
Module clock
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1325

<!-- page 1326 -->

27.3
Power Gating Control (PGC)
Power Gating (PGC) is applied to the ARM CPU only in STOP low power mode, after
all essential CPU registers data are saved by ARM dormant procedure.
If any of the unmasked interrupts appears, CPU is powered up and clock restore request
(exit from STOP mode) is sent to CCM.
PGC power down sequence:
• CCM sends power down request when the chip is about to enter stop mode. The user
should define which modules will be powered down (PGCR registers of
corresponding PGC module, bit 0).
PGC power up sequence:
• One of the power up irq is asserted.
• Power up request is asserted in GPC and in CCM.
• The Power Gated modules are powered up, according to PGC settings of appropriate
module.
The Power Gated modules require reset after powering up. The next figure describes
GPC-SRC handshake procedure for reset after power gating.
Power Gating Control (PGC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1326
NXP Semiconductors

<!-- page 1327 -->

Figure 27-2. GPC-SRC handshake for reset after power gating
27.3.1
Overview
The Power Gating Controller (PGC) is a power management component that controls the
power-down and power-up sequencing of individual subsystems.
The sequence timing is programmable using the PGC control registers. Figure 27-3
shows PGC as part of the SoC’s overall power management scheme.
Chapter 27 General Power Controller (GPC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1327

<!-- page 1328 -->

SoC
Power Management and Clock-Control Subsystems
Higher-level
Component
PGC
Power
Gating
Controller
Power Management
Request (Up or Down)
Acknowledge
Power and
Reset Control
(Up or Down)
Target Subsystem
to be managed
Figure 27-3. PGC Block Diagram
27.3.1.1
Features
Key features of the PGC include:
• Provides the ability to switch off power to a target subsystem.
• Generates power-up and power-down control sequences.
• Provides programmable registers to adjust the timing of the power control signals.
27.4
GPC Interrupt Controller (INTC)
The INTC (Interrupt Controller) detects an interrupt and generates the wakeup signal. It
supports up to 128 interrupts.
27.4.1
Interrupt Controller features
The features of the GPC INTC are listed below.
Features:
• Supports up to 128 interrupts
• Provides an option to mask/unmask each interrupt
• Detects interrupts and generates the wake up signal
• 32-bits IP bus interface
• All registers are byte-accessible
GPC Interrupt Controller (INTC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1328
NXP Semiconductors

<!-- page 1329 -->

27.5
GPC Memory Map/Register Definition
Detailed descriptions of each register can be found below.
GPC memory map
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
20D_C000
GPC Interface control register (GPC_CNTR)
32
R/W
0052_0000h
27.5.1/1329
20D_C004
GPC Power Gating Register (GPC_PGR)
32
R/W
0000_0000h
27.5.2/1331
20D_C008
IRQ masking register 1 (GPC_IMR1)
32
R/W
0000_0000h
27.5.3/1332
20D_C00C
IRQ masking register 2 (GPC_IMR2)
32
R/W
0000_0000h
27.5.4/1332
20D_C010
IRQ masking register 3 (GPC_IMR3)
32
R/W
0000_0000h
27.5.5/1332
20D_C014
IRQ masking register 4 (GPC_IMR4)
32
R/W
0000_0000h
27.5.6/1333
20D_C018
IRQ status resister 1 (GPC_ISR1)
32
R
0000_0000h
27.5.7/1333
20D_C01C
IRQ status resister 2 (GPC_ISR2)
32
R
0000_0000h
27.5.8/1334
20D_C020
IRQ status resister 3 (GPC_ISR3)
32
R
0000_0000h
27.5.9/1334
20D_C024
IRQ status resister 4 (GPC_ISR4)
32
R
0000_0000h
27.5.10/
1335
27.5.1
GPC Interface control register (GPC_CNTR)
Address: 20D_C000h base + 0h offset = 20D_C000h
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
L2_
PGE
GPCIRQM
1
0
VADC_EXT_PWD_N
VADC_ANALOG_OFF
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
1
0
1
0
0
1
0
Chapter 27 General Power Controller (GPC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1329

<!-- page 1330 -->

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
DISPLAY_PUP_REQ
DISPLAY_PDN_REQ
MEGA_PUP_REQ
MEGA_PDN_REQ
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
GPC_CNTR field descriptions
Field
Description
31–23
Reserved
This read-only field is reserved and always has the value 0.
22
L2_PGE
L2 Cache Power Gate Enable
1
L2 cache power gate off request, L2 cache will be power down once when CPU core is power down
and will be hardware invalidated automatically when CPU core is re-power up
0
L2 cache will keep power on even if CPU core is power down and will not be hardware invalidated
when CPU core is re-power up the reset value is 1'b1
21
GPCIRQM
GPC interrupt/event masking
1
interrupt/event is masked
0
not masked
20
Reserved
This read-only field is reserved and always has the value 1.
19
Reserved
This read-only field is reserved and always has the value 0.
18
VADC_EXT_
PWD_N
VADC power down bit
0
— VADC power down
1
— VADC not power down
17
VADC_
ANALOG_OFF
Indication to VADC whether the analog power to VADC is available or not
0
— VADC analog power is on
1
— VADC analog power is off
16
-
This field is reserved.
Reserved
15–6
Reserved
This read-only field is reserved and always has the value 0.
5
DISPLAY_PUP_
REQ
Display Power Up request. Self-cleared bit.
NOTE: Software may directly control display power gate and utilize hardware control for reset sequence
1
Request Power Up sequence to start for Display
0
no request
4
DISPLAY_PDN_
REQ
Display Power Down request. Self-cleared bit.
NOTE: Software may directly control display power gate and utilize hardware control for reset sequence
Table continues on the next page...
GPC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1330
NXP Semiconductors

<!-- page 1331 -->

GPC_CNTR field descriptions (continued)
Field
Description
1
Request Power Down sequence to start for Display
0
no request
3
MEGA_PUP_
REQ
MEGA domain power up request. Self-clear bit.
NOTE: Software may directly control display power gate and utilize hardware control for reset sequence.
0
— No Request
1
— Request power up sequence
2
MEGA_PDN_
REQ
MEGA domain power down request. Self-clear bit.
NOTE: Software may directly control display power gate and utilize hardware control for reset sequence.
Caution, MEGA domain is not allowed to power down when CPU is not powered down.
0
— No Request
1
— Request power down sequence
Reserved
This read-only field is reserved and always has the value 0.
27.5.2
GPC Power Gating Register (GPC_PGR)
Address: 20D_C000h base + 4h offset = 20D_C004h
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
DRCIC
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
GPC_PGR field descriptions
Field
Description
31
Reserved
This read-only field is reserved and always has the value 0.
30–29
DRCIC
Debug ref cir in mux control
00
ccm_cosr_1_clk_in
01
ccm_cosr_2_clk_in
10
restricted
11
restricted
Reserved
This read-only field is reserved and always has the value 0.
Chapter 27 General Power Controller (GPC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1331

<!-- page 1332 -->

27.5.3
IRQ masking register 1 (GPC_IMR1)
IMR1 Register - masking of irq[63:32].
Address: 20D_C000h base + 8h offset = 20D_C008h
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
IMR1
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
GPC_IMR1 field descriptions
Field
Description
IMR1
IRQ[63:32] masking bits: 1-irq masked, 0-irq is not masked
27.5.4
IRQ masking register 2 (GPC_IMR2)
IMR2 Register - masking of irq[95:64].
Address: 20D_C000h base + Ch offset = 20D_C00Ch
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
IMR2
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
GPC_IMR2 field descriptions
Field
Description
IMR2
IRQ[95:64] masking bits: 1-irq masked, 0-irq is not masked
27.5.5
IRQ masking register 3 (GPC_IMR3)
IMR3 Register - masking of irq[127:96].
Address: 20D_C000h base + 10h offset = 20D_C010h
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
IMR3
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
GPC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1332
NXP Semiconductors

<!-- page 1333 -->

GPC_IMR3 field descriptions
Field
Description
IMR3
IRQ[127:96] masking bits: 1-irq masked, 0-irq is not masked
27.5.6
IRQ masking register 4 (GPC_IMR4)
IMR4 Register - masking of irq[159:128].
Address: 20D_C000h base + 14h offset = 20D_C014h
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
IMR4
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
GPC_IMR4 field descriptions
Field
Description
IMR4
IRQ[159:128] masking bits: 1-irq masked, 0-irq is not masked
27.5.7
IRQ status resister 1 (GPC_ISR1)
ISR1 Register - status of irq [63:32].
Address: 20D_C000h base + 18h offset = 20D_C018h
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
ISR1
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
GPC_ISR1 field descriptions
Field
Description
ISR1
IRQ[63:32] status, read only
Chapter 27 General Power Controller (GPC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1333

<!-- page 1334 -->

27.5.8
IRQ status resister 2 (GPC_ISR2)
ISR2 Register - status of irq [95:64].
Address: 20D_C000h base + 1Ch offset = 20D_C01Ch
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
ISR2
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
GPC_ISR2 field descriptions
Field
Description
ISR2
IRQ[95:64] status, read only
27.5.9
IRQ status resister 3 (GPC_ISR3)
ISR3 Register - status of irq [127:96].
Address: 20D_C000h base + 20h offset = 20D_C020h
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
ISR3
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
GPC_ISR3 field descriptions
Field
Description
ISR3
IRQ[127:96] status, read only
GPC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1334
NXP Semiconductors

<!-- page 1335 -->

27.5.10
IRQ status resister 4 (GPC_ISR4)
ISR4 Register - status of irq [159:128].
Address: 20D_C000h base + 24h offset = 20D_C024h
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
ISR4
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
GPC_ISR4 field descriptions
Field
Description
ISR4
IRQ[159:128] status, read only
27.6
PGC Memory Map/Register Definition
The PGC registers can be accessed only in supervisor mode.
Attempts to access registers when not in supervisor mode or attempts to access an
unimplemented address location might trigger a bus transfer error. (The hardware asserts
the signal ips_xfr_err if the PGC has been integrated with resp_sel tied low.) In this case,
software should take appropriate action (such as ignore the error, log the error, or initiate
a soft reset).
All PGC registers are byte-accessible.
NOTE
The base address of each PGC module instantiation is specified
in the GPC module. Absolute address values will be calculated
by [GPC base address] + [PGC CPU/GPU/DISPLAY Offset].
PGC memory map
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
20D_C220
PGC Mega Control Register (PGC_MEGA_CTRL)
32
R/W
0000_0000h
27.6.1/1336
Table continues on the next page...
Chapter 27 General Power Controller (GPC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1335

<!-- page 1336 -->

PGC memory map (continued)
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
20D_C224
PGC Mega Power Up Sequence Control Register
(PGC_MEGA_PUPSCR)
32
R/W
0000_0F01h
27.6.2/1337
20D_C228
PGC Mega Pull Down Sequence Control Register
(PGC_MEGA_PDNSCR)
32
R/W
0000_0101h
27.6.3/1337
20D_C22C
PGC Mega Power Gating Controller Status Register
(PGC_MEGA_SR)
32
R/W
0000_0000h
27.6.4/1338
20D_C2A0
PGC CPU Control Register (PGC_CPU_CTRL)
32
R/W
0000_0000h
27.6.5/1339
20D_C2A4
PGC CPU Power Up Sequence Control Register
(PGC_CPU_PUPSCR)
32
R/W
0000_0F01h
27.6.6/1339
20D_C2A8
PGC CPU Pull Down Sequence Control Register
(PGC_CPU_PDNSCR)
32
R/W
0000_0101h
27.6.7/1340
20D_C2AC
PGC CPU Power Gating Controller Status Register
(PGC_CPU_SR)
32
R/W
0000_0000h
27.6.8/1341
27.6.1
PGC Mega Control Register (PGC_MEGA_CTRL)
The PGCR enables the response to a power-down request.
Address: 20D_C000h base + 220h offset = 20D_C220h
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
PCR
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
PGC_MEGA_CTRL field descriptions
Field
Description
31–1
Reserved
This read-only field is reserved and always has the value 0.
0
PCR
Power Control
NOTE: PCR must not change from power-down request (pdn_req) assertion until the target subsystem is
completely powered up.
0
Do not switch off power even if pdn_req is asserted.
1
Switch off power when pdn_req is asserted.
PGC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1336
NXP Semiconductors

<!-- page 1337 -->

27.6.2
PGC Mega Power Up Sequence Control Register
(PGC_MEGA_PUPSCR)
The PUPSCR contains the power-up timing parameters.
Address: 20D_C000h base + 224h offset = 20D_C224h
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
SW2ISO
0
SW
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
PGC_MEGA_PUPSCR field descriptions
Field
Description
31–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
SW2ISO
After asserting power toggle on/off signal (switch_b), the PGC waits a number of IPG clocks equal to the
value of SW2ISO before negating isolation.
NOTE: SW2ISO must not be programmed to zero.
7–6
Reserved
This read-only field is reserved and always has the value 0.
SW
After a power-up request (pup_req assertion), the PGC waits a number of IPG clocks equal to the value of
SW before asserting power toggle on/off signal (switch_b).
NOTE: SW must not be programmed to zero.
NOTE: The PGC clock is generated from the IPG_CLK_ROOT. for frequency configuration of the
IPG_CLK_ROOT. See Clock Controller Module (CCM).
27.6.3
PGC Mega Pull Down Sequence Control Register
(PGC_MEGA_PDNSCR)
The PDNSCR contains the power-down timing parameters.
Address: 20D_C000h base + 228h offset = 20D_C228h
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
ISO2SW
0
ISO
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
1
0
0
0
0
0
0
0
1
Chapter 27 General Power Controller (GPC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1337

<!-- page 1338 -->

PGC_MEGA_PDNSCR field descriptions
Field
Description
31–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
ISO2SW
After asserting isolation, the PGC waits a number of IPG clocks equal to the value of ISO2SW before
negating power toggle on/off signal (switch_b).
NOTE: ISO2SW must not be programmed to zero.
7–6
Reserved
This read-only field is reserved and always has the value 0.
ISO
After a power-down request (pdn_req assertion), the PGC waits a number of IPG clocks equal to the value
of ISO before asserting isolation.
NOTE: ISO must not be programmed to zero.
27.6.4
PGC Mega Power Gating Controller Status Register
(PGC_MEGA_SR)
The SR contains the status parameters.
Address: 20D_C000h base + 22Ch offset = 20D_C22Ch
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
PSR
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
PGC_MEGA_SR field descriptions
Field
Description
31–1
Reserved
This read-only field is reserved and always has the value 0.
0
PSR
Power status. When in functional (or software-controlled debug) mode, PGC hardware sets PSR as soon
as any of the power control output changes its state to one. Write one to clear this bit. Software should
clear this bit after power up; otherwise, PSR continues to reflect the power status of the initial power down.
0
The target subsystem was not powered down for the previous power-down request.
1
The target subsystem was powered down for the previous power-down request.
PGC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1338
NXP Semiconductors

<!-- page 1339 -->

27.6.5
PGC CPU Control Register (PGC_CPU_CTRL)
The PGCR enables the response to a power-down request.
Address: 20D_C000h base + 2A0h offset = 20D_C2A0h
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
PCR
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
PGC_CPU_CTRL field descriptions
Field
Description
31–1
Reserved
This read-only field is reserved and always has the value 0.
0
PCR
Power Control
NOTE: PCR must not change from power-down request (pdn_req) assertion until the target subsystem is
completely powered up.
0
Do not switch off power even if pdn_req is asserted.
1
Switch off power when pdn_req is asserted.
27.6.6
PGC CPU Power Up Sequence Control Register
(PGC_CPU_PUPSCR)
The PUPSCR contains the power-up timing parameters.
Address: 20D_C000h base + 2A4h offset = 20D_C2A4h
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
SW2ISO
0
SW
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
Chapter 27 General Power Controller (GPC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1339

<!-- page 1340 -->

PGC_CPU_PUPSCR field descriptions
Field
Description
31–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
SW2ISO
There are two different silicon revisions: 1.0 and 1.1 (defined by USB_ANALOG_DIGPROG).
• For silicon revision 1.0: PGC waits for 2048*SW2ISO cycles of IPG_CLK before negating isolation.
• For silicon revision 1.1:
• SW[5] = 1: PGC waits for 64*SW2ISO cycles of IPG_CLK before negating isolation.
• SW[5] = 0: PGC waits for 2048*SW2ISO cycles of IPG_CLK before negating isolation.
NOTE: SW2ISO must not be programmed to zero. The SW2ISO value should be chosen such that the
delay before negating isolation is greater than the LDO ramp-up time.
7–6
Reserved
This read-only field is reserved and always has the value 0.
SW
There are two different silicon revisions: 1.0 and 1.1 (defined by USB_ANALOG_DIGPROG). When
IPG_CLK frequency is slow down in low power mode, it can set SW[5] to speed up ARM wakeup time.
• For silicon revision 1.0: PGC waits for 2048*SW[5:0] cycles of IPG_CLK to switch on ARM power
after pup_reg is asserted.
• For silicon revision 1.1:
• SW[5] = 1: PGC waits for 64*SW[4:0] cycles of IPG_CLK to switch on ARM power after
pup_req is asserted.
• SW[5] = 0: PGC waits for 2048*SW[4:0] cycles of IPG_CLK to switch on ARM power after
pup_req is asserted.
NOTE: SW[4:0] can be programmed to zero.
27.6.7
PGC CPU Pull Down Sequence Control Register
(PGC_CPU_PDNSCR)
The PDNSCR contains the power-down timing parameters.
Address: 20D_C000h base + 2A8h offset = 20D_C2A8h
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
ISO2SW
0
ISO
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
1
0
0
0
0
0
0
0
1
PGC_CPU_PDNSCR field descriptions
Field
Description
31–14
Reserved
This read-only field is reserved and always has the value 0.
13–8
ISO2SW
After asserting isolation, the PGC waits a number of 32k clocks equal to the value of ISO2SW before
negating .
Table continues on the next page...
PGC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1340
NXP Semiconductors

<!-- page 1341 -->

PGC_CPU_PDNSCR field descriptions (continued)
Field
Description
NOTE: ISO2SW must not be programmed to zero.
7–6
Reserved
This read-only field is reserved and always has the value 0.
ISO
After a power-down request (pdn_req assertion), the PGC waits a number of 32k clocks equal to the value
of ISO before asserting isolation.
NOTE: ISO must not be programmed to zero.
27.6.8
PGC CPU Power Gating Controller Status Register
(PGC_CPU_SR)
The SR contains the status parameters.
Address: 20D_C000h base + 2ACh offset = 20D_C2ACh
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
PSR
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
PGC_CPU_SR field descriptions
Field
Description
31–1
Reserved
This read-only field is reserved and always has the value 0.
0
PSR
Power status. When in functional (or software-controlled debug) mode, PGC hardware sets PSR as soon
as any of the power control output changes its state to one. Write one to clear this bit. Software should
clear this bit after power up; otherwise, PSR continues to reflect the power status of the initial power down.
0
The target subsystem was not powered down for the previous power-down request.
1
The target subsystem was powered down for the previous power-down request.
Chapter 27 General Power Controller (GPC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1341

<!-- page 1342 -->

PGC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1342
NXP Semiconductors

