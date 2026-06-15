# Chapter 48: Secure Non-Volatile Storage (SNVS)

> Nguồn: `IMX6ULLRM.pdf` — trang 3415–3450

<!-- page 3415 -->

Chapter 48
Secure Non-Volatile Storage (SNVS)
48.1
SNVS overview
The low-power (battery-backed) section incorporates a secure real time counter, a
monotonic counter, and a general-purpose register. The LP portion of the SNVS is
powered by a battery that maintains the state of the SNVS_LP registers when the chip is
powered off.
48.1.1
SNVS features
The following table summarizes the features:
Table 48-1. SNVS feature summary
Feature
What it does
(nonsecure) Real Time
Counter (HP-RTC)
• The counter is driven by a dedicated clock, which is off when the system power is down
• Programmable time alarm interrupt
• Periodic interrupt can be generated with different frequencies
Monotonic Counter (LP-MC)
• The Monotonic Counter state is nonvolatile.
• The counter can only increment.
• The counter is a non-rollover counter
• The counter value is invalidated in case of security violation.
General-Purpose Register
• The general-purpose register state is nonvolatile.
Register access protection
• Privileged software access policy
• Registers can be programmed only when the system security monitor is in functional
state.
• Some registers/values can only be programmable once per boot cycle.
48.1.2
Modes of operation
The SNVS operates in either the system power-down or the system power-up mode of
operation.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3415

<!-- page 3416 -->

During system power-down, the SNVS_HP is powered down. The SNVS_LP is powered
from the backup power supply and is electrically isolated from the rest of the chip. In this
mode, the SNVS_LP retains the state of its registers .
During the system power-up, the SNVS_HP and SNVS_LP are both powered up and all
SNVS functions are operational.
48.2
SNVS structure
The SNVS block is divided into two major submodules based on power supply: the high
power domain (SNVS_HP) and the low power domain (SNVS_LP). They are powered as
follows:
• SNVS_LP - dedicated always-powered-on domain
• SNVS_HP - system (chip) power domain
The following figure illustrates the low power and chip power domains of SNVS.
SNVS structure
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3416
NXP Semiconductors

<!-- page 3417 -->

SNVS_HP
(button)
ONOFF
Interrupt
Programming 
Interface
Arm
 SNVS_LP
SRTC (timer)
Low Power Domain
Cross Power
Domain Signals
PMIC_ON_REQ
External
Supply
VDD_HIGH_IN
VDD_SNVS_IN
High Power Domain
coin cell
Figure 48-1. SNVS Power Domains
The SNVS_HP section implements all features that enable system communication and
provisioning of the SNVS_LP section.
The SNVS_LP section provides hardware that enables secure storage and protection of
sensitive data.
48.2.1
SNVS_HP (high-power domain)
The SNVS_HP is partitioned into these functional units:
• IP bus interface
• SNVS_LP interface
• Real-time counter with alarm
• Control and status registers
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3417

<!-- page 3418 -->

The SNVS_HP is in the chip's power-supply domain and thus receives the power along
with the rest of the chip. The SNVS_HP provides an interface between the SNVS_LP and
the rest of the system; there is no way to access the SNVS_LP registers except through
the SNVS_HP. For access to the SNVS_LP registers, the SNVS_HP must be powered up.
It uses a register access permission policy to determine whether the access to the
particular registers is permitted.
48.2.2
Non-secure real-time counter
The SNVS _HP has an autonomous non-secure real-time counter. The counter is not
active and is reset when the system is powered down. The HP RTC can be used by any
application; it has no privileged software access restrictions.The counter can be
synchronized with the SNVS_LP SRTC by writing to a specific bit in the SNVS_HP
control register.
48.2.2.1
Calibrating the time counter
The RTC accuracy may suffer from a drift in the clock, which is used to increment the
RTC register. To compensate for this drift, a clock calibration mechanism can adjust the
RTC value. It is up to the system processor to decide whether the calibration is required
or not. If the RTC correction is required, enable the mechanism and set the calibration
value in the control register. The calibration value is a 5-bit value including the sign bit,
which is implemented in the 2's complement.
If the calibration mechanism is enabled, the calibration value is added or subtracted from
the RTC on a periodic basis, once per 32768 cycles of the RTC clock.
This table shows the available correction range:
Table 48-2. Time counter calibration settings
Calibration value setting
Correction in counts per 32768 cycles of the counter clock
01111
+15
:
:
00010
+2
00001
+1
00000
0
11111
-1
11110
-2
:
:
10001
-15
10000
-16
SNVS structure
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3418
NXP Semiconductors

<!-- page 3419 -->

48.2.2.2
Time counter alarm
The SNVS_HP non-secure RTC has its own time-alarm register. Any application can
update this register. The SNVS_HP time alarm can generate interrupts to alert the host
processor and can wake up the host processor from one of its low-power modes. Note
that this alarm can't wake up the entire system if it is powered off because this alarm
would also be powered off.
48.2.2.3
Periodic interrupt
The SNVS_HP non-secure RTC incorporates a periodic interrupt. The periodic interrupt
is generated when a zero-to-one or one-to-zero transition occurs on the selected bit of the
RTC. The periodic interrupt source is chosen from the 16 bits of the HP RTC according
to the PI_FREQ field setting in the HP control register. This bit selection also defines the
frequency of the periodic interrupt.
This figure shows the SNVS_HP RTC and its interrupts:
Figure 48-2. SNVS_HP RTC, alarm, and interrupts
48.3
SNVS_LP (low-power domain)
The SNVS_LP has these functional units:
• Non-rollover monotonic counter
• General-purpose register
• Control and status registers
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3419

<!-- page 3420 -->

The SNVS_LP is a data storage subsystem. Its purpose is to store and protect system
data, regardless of the main system power state.
The SNVS_LP is in the always-powered-up domain, which is a separate power domain
with its own power supply.
48.3.1
Behavior during system power down
When the chip power-supply domain loses power, the The SNVS_LP continues to
operate normally and ignores all inputs from the SNVS_HP.
48.3.2
Monotonic Counter (MC)
This figure shows the MC and its rollover security violation:
Figure 48-3. SNVS_LP monotonic counter
Some security applications require a Monotonic Counter (MC) that can't be exhausted or
returned to any previous value during the product's lifetime. Because the MC should
never repeat a number, it can't be reset or cycled back to its starting count. If it reaches its
maximum value it does not rollover. Instead, a monotonic counter rollover indication is
generated to the SNVS_LP tamper monitor. This generates an interrupt to the host
processor.
The MON_COUNTER fields of the MC register are implemented in flip flops within the
LP section. If LP power is lost, the MON_COUNTER value will be lost. To preserve
monotonicity in this event, the most significant bits of MC (the MC_ERA_BITS field)
are derived from fuses. This means that the MC_ERA_BITS value is preserved across LP
section power failures. The next time that the chip powers up following an LP section
SNVS_LP (low-power domain)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3420
NXP Semiconductors

<!-- page 3421 -->

power failure, the chip's boot firmware will note that the monotonic counter value is
invalid and will blow another of the fuses that drive the MC_ERA_bits field. This will
result in a larger value in the MC_ERA MC field and since this field forms the most-
significant bits of MC, this guarantees that the new value of MC is greater than any of its
past values.
48.4
SNVS reset and system powerup
This table describes the reset actions for the SNVS.
Table 48-3. Reset summary
Reset
Source
Characteristics
Internally resets
HP hard
ipg_hard_async_re
set_b
active-low,
asynchronous
All SNVS_HPSNVS_LP registers and flops.
LP Power On
Reset (POR)
lp_por_b
active-low,
asynchronous
All SNVS_LP registers and flops.
LP software
reset
software
active-high,
synchronous,
one cycle
All SNVS_LP registers and flops. The LP software reset can be
asserted if not disabled.
48.4.1
PMIC interface
The on/off logic inside the SNVS_LP allows for connecting directly to a PMIC or other
voltage-regulator device. The logic takes the button input signal and then outputs the
PMIC "ON" request and the "Power Off" interrupt. The PMIC logic also supports the
SNVS_LP tamper logic which allows to wake the system up when a tamper event has
happened while in the OFF state. The logic has two different modes of operation (the
dumb and smart modes).
Dumb PMIC mode:
The dumb PMIC mode uses the PMIC "ON" request to issue a level signal for the ON
and OFF states. The dumb PMIC mode has many different configuration options which
include debounce, off-to-on time, and maximum timeout.
• Debounce—the debounce configuration supports 0 ms, 50 ms, 100 ms, and 500 ms.
The debounce is used to generate the set_pwr_off_irq interrupt. While it is in the ON
state and the button is pressed longer than the debounce time, the set_pwr_off_irq is
generated.
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3421

<!-- page 3422 -->

• Off-to-on time—the off-to-on configuration supports 0 ms, 50 ms, 100 ms, and 500
ms. This configuration supports the time it takes to request the power-on after the
configured button press time is reached. When the button is pressed longer than the
configuration time, the state machine transitions from the OFF to the ON state.
• Max timeout—the maximum timeout configuration supports 5 s, 10 s, 15 s, and
disable. This configuration supports the time it takes to request the power down after
the button is pressed for the defined time.
The dumb PMIC mode uses a 2-state state machine, as shown in the following figure.
The output of the pmic_en_b is generated by the state of the state machine.
Smart PMIC mode:
The smart PMIC mode is meant to connect to another PMIC. The PMIC "ON" request
signal issues a pulse instead of a level signal. The only configuration option available for
this mode is the Debounce configuration that is used for the "Power Off" interrupt.
48.5
SNVS interrupts and alarms
SNVS provides these interrupt and alarm lines:
• Functional interrupt (active-low)
SNVS interrupts and alarms
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3422
NXP Semiconductors

<!-- page 3423 -->

• Real-time clock period interrupt
• Power off (button) interrupt
This table summarizes all SNVS interrupts and alarm sources.
Table 48-4. Interrupts and alarms summary
Interrupt
Source
Default
configuration1
Configuration
options
SNVS functional interrupt
RTC time alarm
Disable
Enable/Disable
RTC periodic interrupt
Disable
Enable/Disable
SNVS power off (button) interrupt
BTN input signal
50 ms debounce
Debounce time
1.
Default behavior refers to the setting after the LP/HP reset.
48.6
Programming guidelines
This section provides the initialization and application information for the SNVS module.
48.6.1
RTC control bits setting
All SNVS registers are programmed from the register bus. Therefore, any changes are
synchronized with the IP clock. Several registers can also change synchronously with the
RTC clock after they are programmed. To avoid IP clock and RTC clock synchronization
issues, these values can only be programmed when the corresponding function is
disabled. This table presents the list of these values with the control bit setting required
for programming:
Table 48-5. RTC synchronized values list
Function
Value/register
Control bit setting
HP section
HP real-time counter
HPRTCMR and HPRTCLR registers RTC_EN = 0—HPRTCMR/HPRTCLR can be programmed
RTC_EN = 1—HPRTCMR/HPRTCLR can't be
programmed
HP time alarm
HPTAMR and HPTALR registers
HPTA_EN = 0—HPTAMR/HPTALR can be programmed
HPTA_EN = 1—HPTAMR/HPTALR can't be programmed
HP time calibration value
HPCALB_VAL value
HPCALB_EN = 0—HPCALB_VAL can be programmed
HPCALB_EN = 1—HPCALB_VAL can't be programmed
Perform these steps to program the synchronized values:
1. Check the enable bit value. If it is set, clear it.
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3423

<!-- page 3424 -->

2. Verify that the enable bit is cleared.
There are two reasons to verify the enable bit's setting:
• The enable bit clearing does not happen immediately. It takes three IPclock
cycles and two RTC clock cycles to change the enable bit's value.
• If the enable bit is locked for programming, it can't be cleared.
3. Program the desired value.
4. Set the enable bit. It takes three IP clock cycles and two RTC clock cycles for the bit
to set.
NOTE
Incrementing the value programmed into the RTC registers by
two compensates for the two RTC clock cycle delays that are
required to enable the counter.
48.6.2
RTC value read
There are two scenarios when the software can read the corrupted values from the RTC
(HPRTCMR and HPRTCLR) registers:
• The RTC counters are incremented by the slow 32-kHz clock, which is asynchronous
to the system clock. The counter value is synchronized to the system clock before the
software reads that. The synchronization register can capture the counter value in the
middle of the counter update. In this case, it is not guaranteed that all bits are
properly sampled by the synchronization register; the value read by the software can
be wrong.
• The RTC value is longer than the single bus read transaction of 32 bits. Therefore,
the software reads two registers with each holding a portion of the counter value.
After reading one of these registers but before reading the second register, both
registers can update their values. In this case, the value combined by the software is
incorrect.
To avoid these issues, it is strongly recommended that the software performs two
consecutive reads of the RTC value:
• If the two consecutive reads are similar, the value is correct.
• If the two consecutive reads are different, perform two more reads.
The worst-case scenario can require three sessions of two consecutive reads.
Programming guidelines
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3424
NXP Semiconductors

<!-- page 3425 -->

48.6.3
General initialization guidelines
Perform these steps to properly initialize the module:
1. Enable the interrupts in the SNVS control and configuration registers.
2. Program the SNVS general functions/configurations.
3. User-specific: Set the lock bits.
48.7
SNVS memory map/register definition
This section contains detailed register descriptions for the SNVS registers. Each
description includes a standard register diagram and a register table. The register table
provides detailed descriptions of the register bit and field functions in the bit order.
The SNVS registers consist of two types:
• Privileged read/write accessible
• Non-privileged read/write accessible
The privileged read/write accessible registers can only be accessed for read/write by the
privileged software. Unauthorized write accesses are ignored, and unauthorized read
accesses return zero. The non-privileged software can access privileged access registers
when the non-privileged software access enable bit is set in the SNVS_HPcommand
register.
• Non-secure
• Trusted
• Secure
The non-privileged read/write accessible registers are read/write accessible by any
software.
The following table shows the SNVS memory map. The LP register values are set only
on the LP POR and are unaffected by the system (HP) POR. The HP registers are set only
on the system POR and are unaffected by the LP POR.
SNVS memory map
Offset
address
(hex)
Register name
Width
(in bits)
Access
Reset value
Section/
page
20C_C000
SNVS_HP Lock register (SNVS_HPLR)
32
R/W
0000_0000h
48.7.1/3427
20C_C004
SNVS_HP Command register (SNVS_HPCOMR)
32
R/W
0000_0000h
48.7.2/3429
Table continues on the next page...
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3425

<!-- page 3426 -->

SNVS memory map (continued)
Offset
address
(hex)
Register name
Width
(in bits)
Access
Reset value
Section/
page
20C_C008
SNVS_HP Control register (SNVS_HPCR)
32
R/W
0000_0000h
48.7.3/3431
20C_C014
SNVS_HP Status register (SNVS_HPSR)
32
R/W
8000_0000h
48.7.4/3434
20C_C024
SNVS_HP Real-Time Counter MSB Register
(SNVS_HPRTCMR)
32
R/W
0000_0000h
48.7.5/3436
20C_C028
SNVS_HP Real-Time Counter LSB Register
(SNVS_HPRTCLR)
32
R/W
0000_0000h
48.7.6/3437
20C_C02C
SNVS_HP Time Alarm MSB Register (SNVS_HPTAMR)
32
R/W
0000_0000h
48.7.7/3437
20C_C030
SNVS_HP Time Alarm LSB Register (SNVS_HPTALR)
32
R/W
0000_0000h
48.7.8/3438
20C_C034
SNVS_LP Lock Register (SNVS_LPLR)
32
R/W
0000_0000h
48.7.9/3439
20C_C038
SNVS_LP Control Register (SNVS_LPCR)
32
R/W
0000_0020h
48.7.10/
3441
20C_C04C
SNVS_LP Status Register (SNVS_LPSR)
32
R/W
0000_0008h
48.7.11/
3444
20C_C05C
SNVS_LP Secure Monotonic Counter MSB Register
(SNVS_LPSMCMR)
32
R/W
0000_0000h
48.7.12/
3446
20C_C060
SNVS_LP Secure Monotonic Counter LSB Register
(SNVS_LPSMCLR)
32
R/W
0000_0000h
48.7.13/
3447
20C_C068
SNVS_LP General-Purpose Register (SNVS_LPGPR)
32
R/W
0000_0000h
48.7.14/
3447
20C_CBF8
SNVS_HP Version ID Register 1 (SNVS_HPVIDR1)
32
R
003E_0300h
48.7.15/
3448
20C_CBFC
SNVS_HP Version ID Register 2 (SNVS_HPVIDR2)
32
R
0300_0000h
48.7.16/
3448
SNVS memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3426
NXP Semiconductors

<!-- page 3427 -->

48.7.1
SNVS_HP Lock register (SNVS_HPLR)
The SNVS_HP lock register contains the lock bits for the SNVS registers. This is a
privileged write register.
Address: 20C_C000h base + 0h offset = 20C_C000h
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
-
-
-
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
-
-
Reserved
Reserved
GPR_SL
MC_SL
-
-
-
-
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
SNVS_HPLR field descriptions
Field
Description
31–29
-
This field is reserved.
28
-
This field is reserved.
27
-
This field is reserved.
26
-
This field is reserved.
25
-
This field is reserved.
24
-
This field is reserved.
23–19
-
This field is reserved.
Table continues on the next page...
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3427

<!-- page 3428 -->

SNVS_HPLR field descriptions (continued)
Field
Description
18
-
Security-related field
17
-
Security-related field
16
-
Security-related field
15–10
-
This field is reserved.
9
-
Security-related field
8
-
Security-related field
7
-
This field is reserved.
6
-
This field is reserved.
5
GPR_SL
General-Purpose Register Soft Lock
When set, it prevents any writes to the GPR. Once set, this bit can only be reset by the system reset.
0
Write access is allowed.
1
Write access is not allowed.
4
MC_SL
Monotonic Counter Soft Lock
When set, it prevents any writes (increments) to the MC registers and the MC_ENV bit. Once set, this bit
can only be reset by the system reset.
0
Write access (increment) is allowed.
1
Write access (increment) is not allowed.
3
-
Security-related field
2
-
Security-related field
1
-
Security-related field
0
-
Security-related field.
SNVS memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3428
NXP Semiconductors

<!-- page 3429 -->

48.7.2
SNVS_HP Command register (SNVS_HPCOMR)
The SNVS_HP command register contains the command, configuration, and control bits
for the SNVS block. This is a privileged write register.
Address: 20C_C000h base + 4h offset = 20C_C004h
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
NPSWA_EN
Reserved
-
-
-
-
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
-
-
-
-
-
Reserved
LP_SWR_DIS
Reserved
-
-
-
W
LP_SWR
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
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3429

<!-- page 3430 -->

SNVS_HPCOMR field descriptions
Field
Description
31
NPSWA_EN
Non-Privileged Software Access Enable
When set, it allows non-privileged software to access all SNVS registers, including those that are
privileged-software read/write access only.
0—only the privileged software can access the privileged registers.
1—any software can access the privileged registers.
30–20
-
This field is reserved.
19
-
Security-related field
18
-
Security-related field
17
-
Security-related field
16
-
Security-related field
15–14
-
This field is reserved.
13
-
Security-related field
12–11
-
Security-related field
10
-
Security-related field
9
-
Security-related field
8
-
Security-related field
7–6
-
This field is reserved.
5
LP_SWR_DIS
LP Software Reset Disable
When set, it disables the LP software reset. Once set, this bit can only be reset by the system reset.
0
LP software reset is enabled.
1
LP software reset is disabled.
4
LP_SWR
LP Software Reset
When set, it resets the SNVS_LP section. This bit can't be set when the LP_SWR_DIS bit is set. This self-
clearing bit is always read as zero.
0
No action
1
Reset LP section
3
-
This field is reserved.
2
-
Security-related field
1
-
Security-related field
Table continues on the next page...
SNVS memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3430
NXP Semiconductors

<!-- page 3431 -->

SNVS_HPCOMR field descriptions (continued)
Field
Description
0
-
Security-related field
48.7.3
SNVS_HP Control register (SNVS_HPCR)
The SNVS_HP control register contains various control bits of the HP section of the
SNVS. .
Address: 20C_C000h base + 8h offset = 20C_C008h
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
BTN_MASK
BTN_CONFIG
Reserved
-
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
HPCALB_VAL
Reserved
HPCALB_EN
PI_FREQ
PI_EN
Reserved
HPTA_EN
RTC_EN
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
SNVS_HPCR field descriptions
Field
Description
31–28
-
This field is reserved.
27
BTN_MASK
Button interrupt mask. This bit is used to mask the ipi_snvs_btn_int_b (button) interrupt request.
0—interrupt is disabled.
1—interrupt is enabled.
26–24
BTN_CONFIG
Button configuration. This field is used to configure which feature of the button (BTN) input signal
constitutes "active".
Table continues on the next page...
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3431

<!-- page 3432 -->

SNVS_HPCR field descriptions (continued)
Field
Description
000—button signal is active-low.
001—button signal is active-high.
010—button signal is active on the rising edge.
011—button signal is active on the falling edge.
100—button signal is active on any edge.
All other patterns are reserved.
23–17
-
This field is reserved.
16
-
Security-related field
15
-
This field is reserved.
14–10
HPCALB_VAL
HP Calibration Value
Defines the signed calibration value for the HP real-time counter. This field can be programmed only when
the RTC calibration is disabled (HPCALB_EN is not set). This is a 5-bit 2's complement value, hence the
allowable calibration values are in the range from -16 to +15 counts per 32768 ticks of the counter.
00000
+0 counts per each 32768 ticks of the counter
00001
+1 counts per each 32768 ticks of the counter
00010
+2 counts per each 32768 ticks of the counter
01111
+15 counts per each 32768 ticks of the counter
10000
-16 counts per each 32768 ticks of the counter
10001
-15 counts per each 32768 ticks of the counter
11110
-2 counts per each 32768 ticks of the counter
11111
-1 counts per each 32768 ticks of the counter
9
-
This field is reserved.
8
HPCALB_EN
HP Real-Time Counter Calibration Enabled
Indicates that the time-calibration mechanism is enabled.
0
HP timer calibration is disabled.
1
HP timer calibration is enabled.
7–4
PI_FREQ
Periodic Interrupt Frequency
Defines the frequency of the periodic interrupt. The interrupt is generated when a zero-to-one or one-to-
zero transition occurs on the selected bit of the HP real-time counter, and the real-time counter and the
periodic interrupt are both enabled (RTC_EN and PI_EN are set). It is recommended to program this field
when the periodic interrupt is disabled (PI_EN is not set). The possible frequencies are:
0000
- Bit 0 of the RTC is selected as the source of the periodic interrupt.
0001
- Bit 1 of the RTC is selected as the source of the periodic interrupt.
0010
- Bit 2 of the RTC is selected as the source of the periodic interrupt.
0011
- Bit 3 of the RTC is selected as the source of the periodic interrupt.
0100
- Bit 4 of the RTC is selected as the source of the periodic interrupt.
0101
- Bit 5 of the RTC is selected as the source of the periodic interrupt.
0110
- Bit 6 of the RTC is selected as the source of the periodic interrupt.
0111
- Bit 7 of the RTC is selected as the source of the periodic interrupt.
Table continues on the next page...
SNVS memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3432
NXP Semiconductors

<!-- page 3433 -->

SNVS_HPCR field descriptions (continued)
Field
Description
1000
- Bit 8 of the RTC is selected as the source of the periodic interrupt.
1001
- Bit 9 of the RTC is selected as the source of the periodic interrupt.
1010
- Bit 10 of the RTC is selected as the source of the periodic interrupt.
1011
- Bit 11 of the RTC is selected as the source of the periodic interrupt.
1100
- Bit 12 of the RTC is selected as the source of the periodic interrupt.
1101
- Bit 13 of the RTC is selected as the source of the periodic interrupt.
1110
- Bit 14 of the RTC is selected as the source of the periodic interrupt.
1111
- Bit 15 of the RTC is selected as the source of the periodic interrupt.
3
PI_EN
HP Periodic Interrupt Enable
The periodic interrupt can be generated only if the HP real-time counter is enabled.
0
HP periodic interrupt is disabled.
1
HP periodic interrupt is enabled.
2
-
This field is reserved.
1
HPTA_EN
HP Time Alarm Enable
When set, the time alarm interrupt is generated if the value in the HP time alarm registers is equal to the
value of the HP real-time counter.
0
HP time alarm interrupt is disabled.
1
HP time alarm interrupt is enabled.
0
RTC_EN
HP Real-Time Counter Enable
0
RTC is disabled.
1
RTC is enabled.
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3433

<!-- page 3434 -->

48.7.4
SNVS_HP Status register (SNVS_HPSR)
The SNVS_HP status register reflects the internal state of the SNVS.
Address: 20C_C000h base + 14h offset = 20C_C014h
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
Reserved
-
Reserved
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
0
0
0
0
SNVS memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3434
NXP Semiconductors

<!-- page 3435 -->

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
-
-
-
BI
BTN
Reserved
Reserved
-
-
W
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
SNVS_HPSR field descriptions
Field
Description
31
-
Security-related field
30–28
-
This field is reserved.
27
-
Security-related field
26–25
-
This field is reserved.
24–16
-
Security-related field
15
-
Security-related field
14–12
-
Security-related field
11–8
-
Security-related field
7
BI
Button interrupt. The ipi_snvs_btn_int_b signal was asserted.
Table continues on the next page...
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3435

<!-- page 3436 -->

SNVS_HPSR field descriptions (continued)
Field
Description
6
BTN
Value of the BTN input. This is the external button used for the PMIC control.
0—BTN is not pressed.
1—BTN is pressed.
5
-
This field is reserved.
4–2
-
This field is reserved.
1
-
Security-related field
0
-
Security-related field
48.7.5
SNVS_HP Real-Time Counter MSB Register (SNVS_HPRTCMR)
The SNVS_HP real-time counter MSB register contains the most significant bits of the
HP real-time counter.
Address: 20C_C000h base + 24h offset = 20C_C024h
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
RTC
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
SNVS_HPRTCMR field descriptions
Field
Description
RTC
HP Real-Time Counter
Most significant 32 bits. This register can be programmed only when the RTC is not active (the RTC_EN
bit is not set).
SNVS memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3436
NXP Semiconductors

<!-- page 3437 -->

48.7.6
SNVS_HP Real-Time Counter LSB Register (SNVS_HPRTCLR)
The SNVS_HP real-time counter LSB register contains the 32 least significant bits of the
HP real-time counter.
Address: 20C_C000h base + 28h offset = 20C_C028h
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
RTC
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
SNVS_HPRTCLR field descriptions
Field
Description
RTC
HP Real-Time Counter
Least significant 32 bits. This register can be programmed only when the RTC is not active (the RTC_EN
bit is not set).
48.7.7
SNVS_HP Time Alarm MSB Register (SNVS_HPTAMR)
The SNVS_HP time alarm MSB register contains the most significant bits of the
SNVS_HP time alarm value.
Address: 20C_C000h base + 2Ch offset = 20C_C02Ch
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
HPTA
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
SNVS_HPTAMR field descriptions
Field
Description
31–15
-
This field is reserved.
HPTA
HP Time Alarm
Most significant 15 bits. This register can be programmed only when the HP time alarm is disabled (the
HPTA_EN bit is not set).
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3437

<!-- page 3438 -->

48.7.8
SNVS_HP Time Alarm LSB Register (SNVS_HPTALR)
The SNVS_HP time alarm LSB register contains the 32 least significant bits of the
SNVS_HP time alarm value.
Address: 20C_C000h base + 30h offset = 20C_C030h
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
HPTA
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
SNVS_HPTALR field descriptions
Field
Description
HPTA
HP Time Alarm
The least significant bits. This register can be programmed only when the HP time alarm is disabled (the
HPTA_EN bit is not set).
SNVS memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3438
NXP Semiconductors

<!-- page 3439 -->

48.7.9
SNVS_LP Lock Register (SNVS_LPLR)
The SNVS_LP lock register contains the lock bits for the SNVS_LP registers.
Address: 20C_C000h base + 34h offset = 20C_C034h
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
-
-
Reserved
Reserved
GPR_HL
MC_HL
-
-
-
-
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
SNVS_LPLR field descriptions
Field
Description
31–29
-
This field is reserved.
28
-
This field is reserved.
27
-
This field is reserved.
26
-
This field is reserved.
25
-
This field is reserved.
24
-
This field is reserved.
23–10
-
This field is reserved.
Table continues on the next page...
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3439

<!-- page 3440 -->

SNVS_LPLR field descriptions (continued)
Field
Description
9
-
Security-related field
8
-
Security-related field
7
-
This field is reserved.
>
6
-
This field is reserved.
5
GPR_HL
General-Purpose Register Hard Lock
When set, it blocks any writes to the GPR. Once set, this bit can only be reset by the LP POR.
0
Write access is allowed.
1
Write access is not allowed.
4
MC_HL
Monotonic Counter Hard Lock
When set, it blocks any writes (increments) to the MC registers and the MC_ENV bit. Once set, this bit can
only be reset by the LP POR.
0
Write access (increment) is allowed.
1
Write access (increment) is not allowed.
3
-
Security-related field
2
-
Security-related field
1
-
Security-related field
0
-
Security-related field
SNVS memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3440
NXP Semiconductors

<!-- page 3441 -->

48.7.10
SNVS_LP Control Register (SNVS_LPCR)
The SNVS_LP control register contains various control bits of the LP section of the
SNVS.
Address: 20C_C000h base + 38h offset = 20C_C038h
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
PK_OVERRIDE
PK_EN
ON_TIME
DEBOUNCE
BTN_PRESS_TIME
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
-
Reserved
-
PWR_GLITCH_EN
TOP
DP_
EN
-
-
MC_
ENV
-
-
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
SNVS_LPCR field descriptions
Field
Description
31–25
-
This field is reserved.
24
-
This field is reserved.
23
PK_OVERRIDE
PMIC On Request Override. The value written to the PK_OVERRIDE is asserted on the output signal
snvs_lp_pk_override. This signal is used to override the IOMUX control for the PMIC I/O pad.
22
PK_EN
PMIC On Request Enable. The value written to the PK_EN is asserted on the output signal
snvs_lp_pk_en. This signal is used to turn off the pullup/pulldown circuitry in the PMIC I/O pad.
21–20
ON_TIME
The ON_TIME field is used to configure the period of time after the BTN is asserted before the pmic_en_b
is asserted to turn on the SoC power.
00: 500 ms off->on transition time
01: 50 ms off->on transition time
10: 100 ms off->on transition time
Table continues on the next page...
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3441

<!-- page 3442 -->

SNVS_LPCR field descriptions (continued)
Field
Description
11: 0 ms off->on transition time
19–18
DEBOUNCE
This field configures the amount of debounce time for the BTN input signal.
00: 50 ms debounce
01: 100 ms debounce
10: 500 ms debounce
11: 0 ms debounce
17–16
BTN_PRESS_
TIME
Button press timeout values for the PMIC logic.
00 : 5 s
01 : 10 s
10 : 15 s
11 : long press is disabled (pmic_en_b is not asserted, regardless of how long the BTN is asserted)
15
-
This field is reserved.
14–10
-
Security-related field
9
-
This field is reserved.
8
-
Security-related field
7
PWR_GLITCH_
EN
By default, the detection of a power glitch does not cause the pmic_en_b signal to be asserted. Setting the
power glitch enable bit to 1 enables the power-glitch event for the PMIC.
0—disabled
1—enabled
6
TOP
Turn off System Power
Asserting this bit causes a signal to be sent to the power management IC to turn the system power off.
This bit clears once the power is off. This bit is only valid when the dumb PMIC is enabled.
0
Leave the system power on.
1
Turn the system power off.
5
DP_EN
Dumb PMIC Enabled
When set, the software can control the system power. When cleared, the system requires the smart PMIC
to automatically turn the power off.
0
Smart PMIC is enabled.
1
Dumb PMIC is enabled.
4
-
Security-related field
3
-
Security-related field
2
MC_ENV
Monotonic Counter Enable and Valid
When set, the MC can be incremented (by a write transaction to the LPSMCMR or LPSMCLR). This bit
can't be changed once the MC_SL or MC_HL bits are set.
Table continues on the next page...
SNVS memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3442
NXP Semiconductors

<!-- page 3443 -->

SNVS_LPCR field descriptions (continued)
Field
Description
0
MC is disabled or invalid.
1
MC is enabled and valid.
1
-
Security-related field
0
-
Security-related field
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3443

<!-- page 3444 -->

48.7.11
SNVS_LP Status Register (SNVS_LPSR)
The SNVS_LP status register reflects the internal state and behavior of the SNVS_LP.
Address: 20C_C000h base + 4Ch offset = 20C_C04Ch
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
Reserved
-
Reserved
SPO
EO
-
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
-
-
-
-
-
-
-
-
MCR
-
-
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
1
0
0
0
SNVS memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3444
NXP Semiconductors

<!-- page 3445 -->

SNVS_LPSR field descriptions
Field
Description
31
-
Security-related field
30
-
Security-related field
29–21
-
This field is reserved.
20
-
Security-related field.
19
-
This field is reserved.
18
SPO
Set Power Off
The SPO bit is set when the set_pwr_off_irq interrupt is triggered, which happens when the software
writes a 1 to the TOP bit in the LPCR or when the power button is pressed longer than the configured
debounce time. Writing to the SPO bit clears the set_pwr_off_irq interrupt.
0
Emergency off is not detected.
1
Emergency off is detected.
17
EO
Emergency Off
This bit is set when a power off is requested.
0
Emergency off is not detected.
1
Emergency off is detected.
16
-
Security-related field
15–11
-
This field is reserved.
10
-
Security-related field
9
-
Security-related field
8
-
Security-related field
7
-
Security-related field
6
-
Security-related field
5
-
Security-related field
4
-
Security-related field
3
-
Security-related field
2
MCR
Monotonic Counter Rollover
0
MC did not reach its maximum value.
1
MC reached its maximum value.
Table continues on the next page...
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3445

<!-- page 3446 -->

SNVS_LPSR field descriptions (continued)
Field
Description
1
-
Security-related field
0
-
Security-related field
48.7.12
SNVS_LP Secure Monotonic Counter MSB Register
(SNVS_LPSMCMR)
The SNVS_LP secure monotonic counter MSB register contains the monotonic counter
era bits and the most-significant 16 bits of the monotonic counter. The monotonic counter
is incremented by one if there is a write command to the LPSMCMR register or the
LPSMCLR register.
Address: 20C_C000h base + 5Ch offset = 20C_C05Ch
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
MC_ERA_BITS
MON_COUNTER
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
SNVS_LPSMCMR field descriptions
Field
Description
31–16
MC_ERA_BITS
Monotonic Counter Era Bits
These bits are the inputs to the module and are typically connected to the fuses.
MON_COUNTER Monotonic Counter Most-Significant 16 Bits
The MC is incremented by one when:
• A write transaction to the LPSMCMR register or the LPSMCLR register is detected.
• The MC_ENV bit is set.
• The MC_SL and MC_HL bits are not set.
SNVS memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3446
NXP Semiconductors

<!-- page 3447 -->

48.7.13
SNVS_LP Secure Monotonic Counter LSB Register
(SNVS_LPSMCLR)
The SNVS_LP secure monotonic counter LSB register contains the 32 least-significant
bits of the monotonic counter. The MC is incremented by one if there is a write command
to the LPSMCMR register or the LPSMCLR register.
Address: 20C_C000h base + 60h offset = 20C_C060h
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
MON_COUNTER
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
SNVS_LPSMCLR field descriptions
Field
Description
MON_COUNTER Monotonic Counter bits
The MC is incremented by one when:
• A write transaction to the LPSMCMR register or the LPSMCLR register is detected.
• The MC_ENV bit is set.
• The MC_SL and MC_HL bits are not set.
48.7.14
SNVS_LP General-Purpose Register (SNVS_LPGPR)
The SNVS_LP general-purpose register is a 32-bit read/write register located in the low-
power domain. Because the LPGPR is located in the battery-backed power domain, the
LPGPR can be used by any application for retaining data during the SoC power-down
mode. The LPGPR is automatically zeroized when a tamper event occurs, unless the GPR
zeroization is disabled via the GPR_Z_DIS bit in the LP control register.
Address: 20C_C000h base + 68h offset = 20C_C068h
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
GPR
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
SNVS_LPGPR field descriptions
Field
Description
GPR
General-Purpose Register
When the GPR_SL or GPR_HL bit is set, the register can't be programmed.
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3447

<!-- page 3448 -->

48.7.15
SNVS_HP Version ID Register 1 (SNVS_HPVIDR1)
The SNVS_HP Version ID Register 1 is a read-only register that contains the current
version of the SNVS. The version consists of a module ID, a major version number, and a
minor version number.
Address: 20C_C000h base + BF8h offset = 20C_CBF8h
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
IP_ID
MAJOR_REV
MINOR_REV
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
1
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
1
0
0
0
0
0
0
0
0
SNVS_HPVIDR1 field descriptions
Field
Description
31–16
IP_ID
SNVS block ID
15–8
MAJOR_REV
SNVS block major version number
MINOR_REV
SNVS block minor version number
48.7.16
SNVS_HP Version ID Register 2 (SNVS_HPVIDR2)
The SNVS_HP version ID register 2 is a read-only register that indicates the current
version of the SNVS. The version ID register 2 consists of these fields: integration
options, ECO revision, and configuration options.
Address: 20C_C000h base + BFCh offset = 20C_CBFCh
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
IP_ERA
INTG_OPT
ECO_REV
CONFIG_OPT
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
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
SNVS_HPVIDR2 field descriptions
Field
Description
31–24
IP_ERA
Era of the IP design
00h - Era 1 or 2
03h - Era 3
Table continues on the next page...
SNVS memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3448
NXP Semiconductors

<!-- page 3449 -->

SNVS_HPVIDR2 field descriptions (continued)
Field
Description
04h - Era 4
05h - Era 5
23–16
INTG_OPT
SNVS Integration Option
15–8
ECO_REV
SNVS ECO Revision
CONFIG_OPT
SNVS Configuration Option
Chapter 48 Secure Non-Volatile Storage (SNVS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3449

<!-- page 3450 -->

SNVS memory map/register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3450
NXP Semiconductors

