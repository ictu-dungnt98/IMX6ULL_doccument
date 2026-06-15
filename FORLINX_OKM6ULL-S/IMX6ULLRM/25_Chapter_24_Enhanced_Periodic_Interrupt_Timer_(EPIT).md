# Chapter 24: Enhanced Periodic Interrupt Timer (EPIT)

> Nguồn: `IMX6ULLRM.pdf` — trang 1167–1178

<!-- page 1167 -->

Chapter 24
Enhanced Periodic Interrupt Timer (EPIT)
24.1
Overview
EPIT is a 32-bit set-and-forget timer that is capable of providing precise interrupts at
regular intervals with minimal processor intervention. EPIT begins counting after it is
enabled by software.
The following figure shows the EPIT block diagram.
Counter Register
32 bit
Load Register
32 bit
Compare Register
32 bit
CMP
ITIF
Counter Reload
OM
ipg_clk_highfreq
ipg_clk_32k
Clock off
12 bit Prescaler
1 ... 4096
EPITn_OUT
ITIE
interrupt
Prescaled
Clock
Peripheral Bus
32
ipg_clk
Figure 24-1. EPIT block diagram
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1167

<!-- page 1168 -->

24.1.1
EPIT features
EPIT has the following key features:
• 32-bit down counter with clock source selection
• 12-bit prescaler for division of input clock frequency
• Counter value that can be programmed on the fly
• Can be programmed to be active during low-power and debug modes
• Interrupt generation when counter reaches the compare value
24.1.2
EPIT modes and operations
EPIT supports the following modes: set-and-forget and free running. See the following
sections for more information.
• Operating in set-and-forget mode
• Operating in free-running mode
See Operations for a description of the operations that EPIT supports.
24.2
External signals
The following table describes EPIT's I/O signals.
Table 24-1. EPIT External Signals
Signal
Description
Pad
Mode
Direction
EPIT1_OUT
Indicate the occurrence of EPIT1
output compare event through a
specified transition.
UART3_RX_DATA
ALT8
O
JTAG_TMS
ALT8
O
EPIT2_OUT
Indicate the occurrence of EPIT2
output compare event through a
specified transition.
UART3_CTS_B
ALT8
O
JTAG_TDO
ALT8
O
24.3
Clocks
The table found here describes the clock sources for EPIT.
Please see Clock Controller Module (CCM) for clock setting, configuration and gating
information.
External signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1168
NXP Semiconductors

<!-- page 1169 -->

Table 24-2. EPIT Clocks
Clock name
Clock Root
Description
ipg_clk
ipg_clk_root
Peripheral clock
ipg_clk_32k
ckil_sync_clk_root
Low-frequency reference clock (32 kHz)
ipg_clk_highfreq
perclk_clk_root
High-frequency reference clock
ipg_clk_s
ipg_clk_root
Peripheral access clock
The clock that feeds the prescaler can be selected from among the following sources:
• High-frequency reference clock (ipg_clk_highfreq)
This clock is provided by the Clock Control Module (CCM). This clock remains on
during low-power mode when the peripheral clock is turned off, allowing EPIT to
use this clock in low-power mode. In normal mode, the CCM synchronizes this clock
to ahb_clk; in low-power mode, CCM switches to an unsynchronized version.
• Low-frequency reference clock (ipg_clk_32k)
This 32 kHz reference clock is provided by the CCM. This clock remains on in low-
power mode when the peripheral clock is turned off, so EPIT can use this clock
during low-power mode. In normal mode, the CCM synchronizes this clock to
ahb_clk; in low-power mode, CCM switches to an unsynchronized version. This
clock is derived from the external 32 kHz crystal.
• Peripheral clock (ipg_clk)
This is the peripheral clock (PER Clock) which is provided (and optionally gated) by
the CCM. This clock is typically used in normal operations. In low-power modes, if
the EPIT is programmed to be disabled (via STOPEN or WAITEN), then the
peripheral clock can be switched off.
The clock input source is determined by the CLKSRC field in the control register. The
clock input to the prescaler can also be disabled by setting CLKSRC to 0b00. This field
value should only be changed after first disabling the EPIT by clearing the EN bit in
the EPIT_EPITCR. For other programming requirements that apply while changing
clock source, refer section Change of Clock Source.
The PRESCALER field in the control register is used to select the divide ratio of the
input clock that drives the main counter. The prescaler can divide the input clock by a
value between 1 and 4096. A change in the value of the PRESCALER field is
immediately reflected on its output clock frequency. The following figure shows the
timing for a change in the prescaler value.
Chapter 24 Enhanced Periodic Interrupt Timer (EPIT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1169

<!-- page 1170 -->

Clk
100
010
Prescaler Value
Prescaled Clk
Figure 24-2. Prescaler Value Change Diagram
24.4
Functional Description
This section provides a complete functional description of the block.
24.4.1
Operating modes
EPIT can operate in either set-and-forget or free-running mode. Use EPIT_CR[RLD] to
select the desired mode.
24.4.1.1
Operating in set-and-forget mode
To select this mode of operation, set the RLD bit in the control register (EPIT_CR).
In this mode, the counter obtains its data from the load register (EPIT_LR); it cannot be
written to directly from the block data bus. Whenever the counter reaches zero, the value
in EPIT_LR is loaded into the counter. This value is then decremented to zero.
To directly initialize the counter instead of waiting for the count to reach zero, set the
EPIT counter overwrite enable bit (EPIT_CR[IOVW]) and write to EPIT_LR with the
required initialization value.
24.4.1.2
Operating in free-running mode
To select this mode of operation, clear the RLD bit.
In this mode, the counter rolls over from 0000 0000h to FFFF FFFFh without reloading
from the modulus register. After rolling over, the counter continues counting down.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1170
NXP Semiconductors

<!-- page 1171 -->

To directly initalize the counter, set the EPIT counter overwrite enable bit
(EPIT_EPITCL[IOVW]) and write to EPIT_EPITLR with the required initialization
value.
24.4.2
Operations
EPIT has a single 32-bit down counter, which starts counting when the block is enabled
by software.
The start value of the counter is loaded from the EPIT load register, which can be written
to at any time by the processor. The value in the compare register determines the time
that the interrupt occurs.
When EPIT is disabled (EN = 0), both the main counter and the prescaler counter freeze
their count at their current count values. When EPIT is re-enabled (EN = 1), the ENMOD
bit, which is a RW bit, decides the counter value:
• If ENMOD is set, the main counter is loaded with the load value (If RLD = 1)/
FFFF FFFFh (If RLD = 0) and the prescaler counter is reset (000h).
• If ENMOD is cleared, both main counter and prescaler counter restart counting from
their frozen values.
If EPIT is programmed to be disabled in a low-power mode (STOP/WAIT), both the
main counter and the prescaler counter freeze at their current count values when EPIT
enters low-power mode. When EPIT exits the low-power mode, both the main counter
and the prescaler counter start counting from their frozen values regardless of the
ENMOD bit.
A hardware reset resets all EPIT registers to their respective reset values. There is a
software reset which has the same effect on all registers except for the EN, ENMOD,
STOPEN and WAITEN bits in the control register. The state of these bits are not affected
by software reset. A software reset can be asserted even when the EPIT is disabled.
24.4.3
Compare Event
When the programmed value of EPIT_EPITCMPR matches the value in EPIT_EPITCNR
a compare status flag is set, and an interrupt is generated if the OCIEN bit is set in the
control register.
Chapter 24 Enhanced Periodic Interrupt Timer (EPIT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1171

<!-- page 1172 -->

The compare output pin is set, cleared, toggled, or not affected at all depending on the
setting of the output mode (OM) bits in the control register. If an interrupt is required at
rollover (when the counter value reaches 0x0000_0000 and the new value is loaded) then
the compare register value should be set equal to the load register value in set-and-forget
mode, or equal to 0xFFFF_FFFF in free-running mode.
The following figure shows the timing for a compare event and interrupt.
0
4
3
2
1
0
4
3
2
1
0
4
3
2
1
0
2
4
001
010
011
toggle
clear
set
Clk
Counter
Compare Value
Load Value
Output Signal
Interrupt
Output Mode
Figure 24-3. Compare Event and Interrupt Timing Diagram
EPIT will generate a compare event in the next count if the EPITx_CNR from the
previous count equals the new EPITx_CMPR configured before re-enabling the EPIT in
the next count. Even in case a new start counter value was updated in EPITx_LR before
re-enabling the EPIT for the next round. To avoid this, configure the EPITx_CMPR to
previous EPITx_CNR+1. Or, in set and forget mode, configure EPITx_LR with
IOVW=1, before disabling EPIT. Also can do an extra disable/enable iteration to clear
OCIF and update EPITx_CNR.
24.4.3.1
Counter Value Overwrite
The EPIT counter value can be overwritten to acquire a desired value at any point of
time. The procedure for this is to set the IOVW bit in the control register and then write
the desired value into the load register.
This results in the load register acquiring that value and also the counter being
overwritten with it. If the EPIT is running the counter resumes counting from the
overwritten value.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1172
NXP Semiconductors

<!-- page 1173 -->

24.4.3.2
Low-Power Mode Behavior
The EPIT timer's behavior in low-power modes depends on which clock source is being
used.
If the selected clock source is available and the corresponding low-power enable bit is
set, then the EPIT continues to function in the low-power mode. If the EPIT is
programmed to be disabled in a low-power mode (STOP/WAIT), then main counter and
the prescaler counter freeze at the current count values when the EPIT enters low-power
mode. When the EPIT exits the low-power mode, both main counter and prescaler
counter start counting from their frozen values irrespective of the ENMOD bit.
24.4.3.3
Debug Mode Behavior
In debug mode, the user has the option to run or halt the EPIT timers. If the DBGEN bit
is reset in the EPIT Control Register, the timer is halted.
When debug mode is exited, the timer operation reverts to what it was prior to entering
debug mode.
24.5
Initialization/ Application Information
24.5.1
Change of Clock Source
The CLKSRC field in EPIT_EPITCR determines the clock source. This field value
should be changed only after disabling the EPIT (EN = 0).
Below is the software sequence which must be followed while changing clock source.
1. Disable the EPIT - set EN=0 in EPIT_EPITCR.
2. Disable EPIT ouput - program OM=00 in the EPIT_EPITCR.
3. Disable EPIT interrupts.
4. Program CLKSRC to desired clock source in EPIT_EPITCR.
5. Clear the EPIT status register (EPIT_EPITSR), that is, write "1" to clear (w1c).
6. Set ENMOD= 1 in the EPIT_EPITCR, to bring the EPIT Counter to defined state
(EPIT_EPITLR value or 0xFFFF_FFFF).
7. Enable EPIT - set (EN=1) in the EPIT_EPITCR
8. Enable the EPIT interrupts.
Chapter 24 Enhanced Periodic Interrupt Timer (EPIT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1173

<!-- page 1174 -->

24.6
EPIT Memory Map/Register Definition
The EPIT includes five user-accessible 32-bit registers. The following table summarizes
these registers and their addresses.
Peripheral bus write access to the EPIT control register (EPITCR) and the EPIT load
register (EPITLR) results in one cycle of wait state, while other valid peripheral bus
accesses are with 0 wait state.
EPIT memory map
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
20D_0000
Control register (EPIT1_CR)
32
R/W
0000_0000h
24.6.1/1174
20D_0004
Status register (EPIT1_SR)
32
R/W
0000_0000h
24.6.2/1177
20D_0008
Load register (EPIT1_LR)
32
R/W
FFFF_FFFFh 24.6.3/1177
20D_000C
Compare register (EPIT1_CMPR)
32
R/W
0000_0000h
24.6.4/1178
20D_0010
Counter register (EPIT1_CNR)
32
R
FFFF_FFFFh 24.6.5/1178
20D_4000
Control register (EPIT2_CR)
32
R/W
0000_0000h
24.6.1/1174
20D_4004
Status register (EPIT2_SR)
32
R/W
0000_0000h
24.6.2/1177
20D_4008
Load register (EPIT2_LR)
32
R/W
FFFF_FFFFh 24.6.3/1177
20D_400C
Compare register (EPIT2_CMPR)
32
R/W
0000_0000h
24.6.4/1178
20D_4010
Counter register (EPIT2_CNR)
32
R
FFFF_FFFFh 24.6.5/1178
24.6.1
Control register (EPITx_CR)
The EPIT control register (EPIT_CR) is used to configure the operating settings of the
EPIT. It contains the clock division prescaler value and also the interrupt enable bit.
Additionally, it contains other control bits which are described below.
Peripheral Bus Write access to EPIT Control Register (EPIT_CR) results in one cycle of
the wait state, while other valid peripheral bus accesses are with 0 wait state.
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
R
0
CLKSRC
OM
STOPEN
0
WAITEN
DBGEN
IOVW
SWR
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
EPIT Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1174
NXP Semiconductors

<!-- page 1175 -->

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
PRESCALAR
RLD
OCIEN
ENMOD
EN
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
EPITx_CR field descriptions
Field
Description
31–26
Reserved
This read-only field is reserved and always has the value 0.
25–24
CLKSRC
Select clock source
These bits determine which clock input is to be selected for running the counter. This field value should
only be changed when the EPIT is disabled by clearing the EN bit in this register. For other programming
requirements while changing clock source, refer to Change of Clock Source.
00
Clock is off
01
Peripheral clock
10
High-frequency reference clock
11
Low-frequency reference clock
23–22
OM
EPIT output mode.This bit field determines the mode of EPIT output on the output pin.
00
EPIT output is disconnected from pad
01
Toggle output pin
10
Clear output pin
11
Set output pin
21
STOPEN
EPIT stop mode enable. This read/write control bit enables the operation of the EPIT during stop mode.
This bit is reset by a hardware reset and unaffected by software reset.
0
EPIT is disabled in stop mode
1
EPIT is enabled in stop mode
20
Reserved
This read-only field is reserved and always has the value 0.
19
WAITEN
This read/write control bit enables the operation of the EPIT during wait mode. This bit is reset by a
hardware reset. A software reset does not affect this bit.
0
EPIT is disabled in wait mode
1
EPIT is enabled in wait mode
18
DBGEN
This bit is used to keep the EPIT functional in debug mode. When this bit is cleared, the input clock is
gated off in debug mode.This bit is reset by hardware reset. A software reset does not affect this bit.
0
Inactive in debug mode
1
Active in debug mode
17
IOVW
EPIT counter overwrite enable. This bit controls the counter data when the modulus register is written.
When this bit is set, all writes to the load register overwrites the counter contents and the counter starts
subsequently counting down from the programmed value.
0
Write to load register does not result in counter value being overwritten.
1
Write to load register results in immediate overwriting of counter value.
Table continues on the next page...
Chapter 24 Enhanced Periodic Interrupt Timer (EPIT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1175

<!-- page 1176 -->

EPITx_CR field descriptions (continued)
Field
Description
16
SWR
Software reset. The EPIT is reset when this bit is set to 1. It is a self clearing bit. This bit is set when the
block is in reset state and is cleared when the reset procedure is over. Setting this bit resets all the
registers to their reset values, except for the EN, ENMOD, STOPEN, WAITEN and DBGEN bits in this
control register
0
EPIT is out of reset
1
EPIT is undergoing reset
15–4
PRESCALAR
Counter clock prescaler value. This bit field determines the prescaler value by which the clock is divided
before it goes to the counter
0x000
Divide by 1
0x001
Divide by 2...
0xFFF
Divide by 4096
3
RLD
Counter reload control.
This bit is cleared by hardware reset. It decides the counter functionality, whether to run in free-running
mode or set-and-forget mode.
0
When the counter reaches zero it rolls over to 0xFFFF_FFFF (free-running mode)
1
When the counter reaches zero it reloads from the modulus register (set-and-forget mode)
2
OCIEN
Output compare interrupt enable.
This bit enables the generation of interrupt on occurrence of compare event.
0
Compare interrupt disabled
1
Compare interrupt enabled
1
ENMOD
EPIT enable mode.
When EPIT is disabled (EN=0), both main counter and prescaler counter freeze their count at current
count values. ENMOD bit is a r/w bit that determines the counter value when the EPIT is enabled again by
setting EN bit. If ENMOD bit is set, then main counter is loaded with the load value (If RLD=1)/
0xFFFF_FFFF (If RLD=0) and prescaler counter is reset, when EPIT is enabled (EN=1). If ENMOD is
programmed to 0 then both main counter and prescaler counter restart counting from their frozen values
when EPIT is enabled (EN=1). If EPIT is programmed to be disabled in a low-power mode (STOP/WAIT/
DEBUG), then both the main counter and the prescaler counter freeze at their current count values when
EPIT enters low-power mode. When EPIT exits the low-power mode, both main counter and prescaler
counter start counting from their frozen values irrespective of the ENMOD bit. This bit is reset by a
hardware reset. A software reset does not affect this bit.
0
Counter starts counting from the value it had when it was disabled.
1
Counter starts count from load value (RLD=1) or 0xFFFF_FFFF (If RLD=0)
0
EN
This bit enables the EPIT. EPIT counter and prescaler value when EPIT is enabled (EN = 1), is dependent
upon ENMOD and RLD bit as described for ENMOD bit. It is recommended that all registers be properly
programmed before setting this bit. This bit is reset by a hardware reset. A software reset does not affect
this bit.
0
EPIT is disabled
1
EPIT is enabled
EPIT Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1176
NXP Semiconductors

<!-- page 1177 -->

24.6.2
Status register (EPITx_SR)
The EPIT status register (EPIT_SR) has a single status bit for the output compare event.
The bit is a write 1 to clear bit.
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
OCIF
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
EPITx_SR field descriptions
Field
Description
31–1
Reserved
This read-only field is reserved and always has the value 0.
0
OCIF
Output compare interrupt flag. This bit is the interrupt flag that is set when the content of counter equals
the content of the compare register (EPIT_CMPR). The bit is a write 1 to clear bit.
0
Compare event has not occurred
1
Compare event occurred
24.6.3
Load register (EPITx_LR)
The EPIT load register (EPIT_LR) contains the value that is to be loaded into the counter
when EPIT counter reaches zero if the RLD bit in EPIT_CR is set. If the IOVW bit in the
EPIT_CR is set then a write to this register overwrites the value of the EPIT counter
register in addition to updating this registers value. This overwrite feature is active even
if the RLD bit is not set.
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
LOAD
W
Reset 1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
Chapter 24 Enhanced Periodic Interrupt Timer (EPIT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1177

<!-- page 1178 -->

EPITx_LR field descriptions
Field
Description
LOAD
Load value. Value that is loaded into the counter at the start of each count cycle.
24.6.4
Compare register (EPITx_CMPR)
The EPIT compare register (EPIT_CMPR) holds the value that determines when a
compare event is generated.
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
COMPARE
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
EPITx_CMPR field descriptions
Field
Description
COMPARE
Compare Value. When the counter value equals this bit field value a compare event is generated.
24.6.5
Counter register (EPITx_CNR)
The EPIT counter register (EPIT_CNR) contains the current count value and can be read
at any time without disturbing the counter. This is a read-only register and any attempt to
write into it generates a transfer error. But if the IOVW bit in EPIT_CR is set, the value
of this register can be overwritten with a write to EPIT_LR. This change is reflected
when this register is subsequently read.
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
COUNT
W
Reset 1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
EPITx_CNR field descriptions
Field
Description
COUNT
Counter value. This contains the current value of the counter.
EPIT Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1178
NXP Semiconductors

