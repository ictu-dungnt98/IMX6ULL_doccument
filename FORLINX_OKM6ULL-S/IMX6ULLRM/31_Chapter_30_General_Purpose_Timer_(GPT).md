# Chapter 30: General Purpose Timer (GPT)

> Nguồn: `IMX6ULLRM.pdf` — trang 1421–1444

<!-- page 1421 -->

Chapter 30
General Purpose Timer (GPT)
30.1
Overview
This chapter describes the General Purpose Timer (GPT) module interface. It is also a
reference for software driver programming. The GPT has a 32-bit up-counter. The timer
counter value can be captured in a register using an event on an external pin. The capture
trigger can be programmed to be a rising or/and falling edge. The GPT can also generate
an event on the output compare pins and an interrupt when the timer reaches a
programmed value. The GPT has a 12-bit prescaler, which provides a programmable
clock frequency derived from multiple clock sources.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1421

<!-- page 1422 -->

Prescaler
12-bit
1...  4096
Prescaler
output
Timer
Counter
32-bit
FRR
ROVIE
sync
IM1
IF1
GPT_CAPTURE 1
IF1IE
IF2IE
sync
IM2
IF2
GPT_CAPTURE2
Processor Data Bus
Timer
Input Reg 1
32-bit
Timer
Input Reg 2
32-bit
Timer
Output Reg1
32-bit
Timer
Output Reg2
32-bit
Timer
Output Reg3
32-bit
ROV
Counter Value Bus
GPT interrupts
Processor Interrupt Bus
OF1IE
cmp
cmp
cmp
OF1
OM1
GPT_COMPARE1
OF2IE
OF2
OM2
GPT_COMPARE2
OF3IE
OF3
GPT_COMPARE3
OM3
Clock input from
clock selection
block
Figure 30-1. GPT Block Diagram
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1422
NXP Semiconductors

<!-- page 1423 -->

Clock off
External Clock 
(GPT_CLK)
Peripheral Clock
Low Frequency Reference Clock
High Frequency Reference Clock
Sync
To Prescaler
(ipg_clk)
(ipg_clk_32k)
(ipg_clk_highfreq)
Prescaler 24M
Crystal Oscillator
(ipg_clk_24M)
Figure 30-2. GPT Counter Clocks Diagram
30.1.1
Features
• One 32-bit up-counter with clock source selection, including external clock.
• Two input capture channels with a programmable trigger edge.
• Three output compare channels with a programmable output mode. A "forced
compare" feature is also available.
• Can be programmed to be active in low power and debug modes.
• Interrupt generation at capture, compare, and rollover events.
• Restart or free-run modes for counter operations.
30.1.2
Modes and Operation
The GPT supports the modes described in the indicated sections:
• Operating Modes
• Restart Mode
• Free-Run Mode
Chapter 30 General Purpose Timer (GPT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1423

<!-- page 1424 -->

30.2
External Signals
The GPT follows the IP Bus protocol for interfacing with the processor core. The GPT
does not have any interface signals with any other module inside the chip, except for the
clock and reset inputs (from the clock and reset controller module) and for the interrupt
signals to the processor interrupt handler. There are functional and clock inputs, and
functional output signals going outside the chip boundary.
The following table describes all block signals that connect off-chip.
Table 30-1. GPT External Signals
Signal
Description
Pad
Mode
Direction
GPT1_CLK
Input pin for an external clock that
the counter can be operated at.
ENET1_TX_CLK
ALT8
I
UART1_RX_DATA
ALT4
GPT1_CAPTURE1
Input pin for a capture event for
Input Capture Channel 1.
GPIO1_IO00
ALT1
I
UART2_TX_DATA
ALT4
GPT1_CAPTURE2
Input pin for a capture event for
Input Capture Channel 2.
ENET1_RX_ER
ALT8
I
UART2_RX_DATA
ALT4
GPT1_COMPARE1
Output pin that indicates a "compare
event" occurrence in Output
Compare Channel 1.
GPIO1_IO01
ALT1
O
UART1_TX_DATA
ALT4
GPT1_COMPARE2
Output pin that indicates a "compare
event" occurrence in Output
Compare Channel 2.
GPIO1_IO02
ALT1
O
UART2_CTS_B
ALT4
GPT1_COMPARE3
Output pin that indicates a "compare
event" occurrence in Output
Compare Channel 3.
GPIO1_IO03
ALT1
O
UART2_RTS_B
ALT4
GPT2_CLK
Input pin for an external clock that
the counter can be operated at.
JTAG_MODE
ALT1
I
SD1_DATA1
ALT1
GPT2_CAPTURE1
Input pin for a capture event for
Input Capture Channel 1.
JTAG_TMS
ALT1
I
SD1_DATA2
ALT1
GPT2_CAPTURE2
Input pin for a capture event for
Input Capture Channel 2.
JTAG_TDO
ALT1
I
SD1_DATA3
ALT1
GPT2_COMPARE1
Output pin that indicates a "compare
event" occurrence in Output
Compare Channel 1.
JTAG_TDI
ALT1
O
SD1_CMD
ALT1
GPT2_COMPARE2
Output pin that indicates a "compare
event" occurrence in Output
Compare Channel 2.
JTAG_TCK
ALT1
O
SD1_CLK
ALT1
GPT2_COMPARE3
Output pin that indicates a "compare
event" occurrence in Output
Compare Channel 3.
JTAG_TRST_B
ALT1
O
SD1_DATA0
ALT1
There are six signals (three input, three output) in the GPT module that can be connected
to the chip pads.
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1424
NXP Semiconductors

<!-- page 1425 -->

30.2.1
External Clock Input
The GPT counter can be operated using an external clock from outside the device, and
this is the input pin used for that purpose. The external clock input (GPT_CLK) is treated
as asynchronous to the peripheral clock (ipg_clk). To ensure proper operations of GPT,
the external clock input frequency should be less than 1/4 of frequency of the peripheral
clock (ipg_clk). Hysteresis characteristics on this pad will be required because this is a
clock input.
30.2.2
Input Capture Trigger Signals
The GPT counter value can be stored in a register, triggered by an event from outside the
device. A positive or/and negative edge on these signals GPT_CAPTURE1 ,
GPT_CAPTURE2 can trigger this capture event. These signals are treated as
asynchronous to the peripheral clock (ipg_clk). Only those transitions which occur at
least a single clock cycle (the clock selected to run the counter) after the previous
recorded transition are guaranteed to trigger a capture event.
30.2.3
Output Compare Signals
The output compare signals: GPT_COMPARE1, GPT_COMPARE2,
GPT_COMPARE3, indicate that output compare events have gone through a specified
transition.
30.3
Clocks
The clock that is input to the prescaler can be selected from 4 clock sources. The
following table describes the clock sources for GPT. Please see Clock Controller Module
(CCM) for clock setting, configuration and gating information.
Table 30-2. GPT Clocks
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
Chapter 30 General Purpose Timer (GPT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1425

<!-- page 1426 -->

• High-Frequency Clock (ipg_clk_highfreq)
Provided by the Clock Controller Module (CCM), the High Frequency Clock is
intended to be ON in Normal Power mode when the Peripheral Clock (ipg_clk) is
turned OFF, thereby enabling the GPT to be operated using the High Frequency
Clock in Normal Power mode. The CCM is expected to provide this clock after
synchronizing it to the System Bus Clock (ahb_clk) in Normal functional mode; the
CCM is also expected to switch to the unsynchronized version of the High Frequency
Clock in a Low Power mode.
• Low-Reference Clock (ipg_clk_32k)
This 32 kHz Low Reference Clock (provided by the CCM) is intended to be ON in
Low Power mode when the Peripheral Clock (ipg_clk) is turned OFF, thereby
enabling the GPT to be operated using the Low Reference Clock in Low Power
mode. The CCM is expected to provide the Low Reference Clock after
synchronizing it to the System Bus Clock (ahb_clk) in Normal functional mode; the
CCM is also expected to switch to the unsynchronized version of the Low Reference
Clock in a Low Power mode.
• Peripheral Clock (ipg_clk)
If the Peripheral Clock (ipg_clk) or the External Clock (GPT_CLK) is selected
(CLKSRC=001 or 011) as Clock Source, then the Peripheral Clock will be ON in
normal GPT operations. In Low Power modes, if the GPT is programmed to be
disabled (STOPEN or WAITEN or DOZEN=0), then the Peripheral Clock (ipg_clk)
can be switched OFF.
• External Clock (GPT_CLK)
The External Clock comes from outside the device and can be selected to run the
GPT counter. The External Clock is treated as asynchronous to the Peripheral Clock,
(ipg_clk) and is synchronized to the Peripheral Clock (ipg_clk), inside the module.
Therefore, the External Clock frequency is limited to < 1/4 frequency of the
Peripheral Clock (ipg_clk), for proper GPT operations. Note that in Low Power
modes, if the Peripheral Clock (ipg_clk) is not available, then the External Clock
cannot be used to run the counter.
• Crystal Oscillator Clock (ipg_clk_24M)
This 24 MHz Crystal Oscillator Clock (provided by the CCM) is intended to be used
against frequency change of Peripheral Clock (ipg_clk) changes to provide a more
accurate timer clock for operation system. The CCM is expected to provide the 24
MHz Crystal Oscillator Clock without synchronizing it to the System Bus Clock
(ahb_clk) in Normal functional mode. Synchronization is done in GPT module.
Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1426
NXP Semiconductors

<!-- page 1427 -->

Before synchronization, the 24 MHz Crystal Oscillator Clock is divided by a 24 MHz
clock prescaler, to make sure the clock frequency less than half of System Bus Clock
(ahb_clk).
The clock input source is configured using the clock source field (CLKSRC, in the
GPT_CR control register). The clock input to the prescaler can be disabled by
programming the CLKSRC bits (of the GPT_CR control register) to 000. The CLKSRC
field value should be changed only after disabling the GPT (by setting the EN bit in the
GPT_CR to 0).
The PRESCALER field selects the divide ratio of the input clock that drives the main
counter. The prescaler can divide the input clock by a value (from 1 to 4096) and can be
changed at any time. A change in the value of the PRESCALER field immediately affects
the output clock frequency.
Clk
Prescaler Value
Prescaled Clk
0x004
0x002
Figure 30-3. Prescaler Value Change Timing Diagram
30.4
Functional Description
This section provides a complete functional description of the GPT.
30.4.1
Operating Modes
The GPT counter can be programmed to work in either of two modes: Restart mode or
Free-Run mode.
Chapter 30 General Purpose Timer (GPT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1427

<!-- page 1428 -->

30.4.1.1
Restart Mode
In Restart mode (selectable through the GPT Control Register GPT_CR), when the
counter reaches the compared value, the counter resets and starts again from 0x00000000.
The Restart feature is associated only with Compare Channel 1.
Any write access to the Compare register of Channel 1 will reset the GPT counter. This is
done to avoid possibly missing a compare event when compare value is changed from a
higher value to lower value while counting is proceeding.
For the other two compare channels, when the compare event occurs the counter is not
reset.
30.4.1.2
Free-Run Mode
In Free-Run mode, when compare events occur for all 3 channels, the counter is not
reset; instead the counter continues to count until 0xffffffff, and then rolls over (to
0x00000000).
30.4.2
Operation
The General Purpose Timer (GPT) has a single counter (GPT_CNT) that is a 32-bit free-
running up-counter, which starts counting after it is enabled by software (EN=1). The
counter's clock source is the output of the prescaler labelled "Prescaler output" in Figure
30-1.
• If the GPT timer is disabled (EN=0), then the Main Counter and Prescaler Counter
freeze their current count values. The ENMOD bit determines the value of the GPT
counter when the EN bit is set and the Counter is enabled again.
• If the ENMOD bit is set (=1), then the Main Counter and Prescaler Counter
values are reset to 0, when GPT is enabled (EN=1).
• If ENMOD bit is programmed to 0, then the Main Counter and Prescaler Counter
restart counting from their frozen values, when GPT is enabled again (EN=1).
• If GPT is programmed to be disabled in a low power mode (STOP/WAIT), then the
Main Counter and Prescaler Counter freeze at their current count values when GPT
enters low power mode. When GPT exits a low power mode, the Main Counter and
Prescaler Counter start counting from their frozen values regardless of the ENMOD
bit value. Note that the GPT_CNT can be read at any time by the processor, and that
both Input Capture Channels use the same counter (GPT_CNT).
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1428
NXP Semiconductors

<!-- page 1429 -->

• A hardware reset resets all the GPT registers to their respective reset values. All
registers except the Output Compare Registers (OCR1, OCR2, OCR3) obtain a value
of 0x0. The Compare registers are reset to 0xFFFF_FFFF.
• The software reset (SWR bit in the GPT_CR control register) resets all of the register
bits except the EN, ENMOD, STOPEN, WAITEN, and DBGEN bits. The state of
these bits is not affected by a software reset. Note that a software reset can be given
while the GPT is disabled.
30.4.2.1
Input Capture
There are two Input Capture Channels, and each Input Capture Channel has a dedicated
capture pin, capture register and input edge detection/selection logic. Each input capture
function has an associated status flag, and can cause the processor to make an interrupt
service request.
When a selected edge transition occurs on an Input Capture pin, the contents of the
GPT_CNT is captured on the corresponding capture register and the appropriate interrupt
status flag is set. An interrupt request can be generated when the transition is detected if
its corresponding enable bit is set (in the Interrupt Register). The capture can be
programmed to occur on the input pin's rising edge, falling edge, on both rising and
falling edges, or the capture can be disabled. The events are synchronized with the clock
that was selected to run the counter. Only those transitions that occur at least one clock
cycle (clock selected to run the counter) after the previous recorded transition will be
guaranteed to trigger a capture event. There can be up to one clock cycle of uncertainty in
the latching of the input transition. The Input Capture registers can be read at any time
without affecting their values.
Clk
ipp_ind_capin1
Sig
Clk = The clock selected from CLKSRC bit field setting
ipp_ind_capin1 = Pad signal for capture channel 1
Sig = Capture signal as sensed by the module
Figure 30-4. Input Capture Event Timing
Chapter 30 General Purpose Timer (GPT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1429

<!-- page 1430 -->

30.4.2.2
Output Compare
The three Output Compare Channels use the same counter (GPT_CNT) as the Input
Capture Channels. When the programmed content of an Output Compare register
matches the value in GPT_CNT, an output compare status flag is set and an interrupt is
generated (if the corresponding bit is set in the interrupt register). Consequently, the
Output Compare timer pin will be set, cleared, toggled, not affected at all or provide an
active-low pulse for one input clock period (subject to the restriction on the maximum
frequency allowed on the pad) according to the mode bits (that were programmed).
There is also a "forced-compare" feature that allows the software to generate a compare
event when required, without the condition of the counter value that is equal to the
compare value. The action taken as a result of a forced compare is the same as when an
output compare match occurs, except that the status flags are not set and no interrupt can
be generated. Forced channels take programmed action immediately after the write to the
force-compare bits. These bits are self-negating and always read as zeros.
Clk
0
1
2
3
4
0
1
2
3
4
0
1
2
3
4
0
4
Counter
Compare Value
Output Mode
Output Signal
Interrupt
001
100
010
011
toggle
clear
set
low pulse
Figure 30-5. Output Compare and Interrupt Timing
30.4.2.3
Interrupts
There are 6 different interrupts that are generated by the GPT. If the selected clock for
running the counter is available, then all interrupts can be generated in Low Power and
Debug modes.
• Rollover Interrupt
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1430
NXP Semiconductors

<!-- page 1431 -->

The Rollover Interrupt is generated when the GPT counter reaches 0xffffffff, then
resets to 0x00000000 and continues counting. The Rollover Interrupt is enabled by
the ROVIE bit in the GPT_IR register; the associated status bit is the ROV bit in the
GPT_SR register.
• Input Capture Interrupt 1, 2
After a capture event occurs, the associated Input Capture Channel generates an
interrupt. The "capture event" interrupts are enabled by the IF2IE and IF1IE bits (in
the GPT_IR register); the associated status bits are IF2 and IF1 (in the GPT_SR
register). The capture of the counter value because of a capture event is not affected
by a pending capture interrupt. The Capture register is updated with a new counter
value when a capture event occurs, regardless of whether that Capture Channels'
interrupt has been serviced or not.
• Output Compare Interrupt 1, 2, 3
After a compare event occurs, the associated Output Compare Channel generates an
interrupt. The "compare event" interrupts are enabled by the OF3IE, OF2IE, and
OF1IE bits (in the GPT_IR register); the associated status bits are OF3, OF2, and
OF1 (in the GPT_SR register). A "forced compare" does not generate an interrupt.
A cumulative interrupt line is also present, which is asserted whenever any of the above
interrupts are posted. The cumulative interrupt line has no associated enables or status
bits.
30.4.2.4
Low Power Mode Behavior
In Low Power modes, if the clock from the selected clock source is available (except for
the External Clock (GPT_CLK), which can be used only if the Peripheral Clock (ipg_clk)
is available), the counter will continue to run depending on whether the control bit for
that mode is set. If the clock is not present or if the corresponding low power bit in the
GPT_CR control register is 0, the Main Counter and the Prescaler Counter freeze at their
current values and resume counting (from their frozen values) when the Low Power
mode is exited.
30.4.2.5
Debug Mode Behavior
In Debug mode, the modules in the device have the option of continuing to run or be
halted.
Chapter 30 General Purpose Timer (GPT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1431

<!-- page 1432 -->

• If the DBGEN bit is set, then the GPT timer will continue to run in Debug mode.
• If the DBGEN bit is not set (in the GPT_CR control register), then the GPT timer is
halted.
30.5
Initialization/ Application Information
30.5.1
Selecting the Clock Source
The CLKSRC field in the GPT_CR register selects the clock source. The CLKSRC field
value should be changed only after disabling the GPT (EN=0).
The software sequence to be followed while changing clock source is:
1. Disable GPT by setting EN=0 in GPT_CR register.
2. Disable GPT interrupt register (GPT_IR).
3. Configure Output Mode to unconnected/ disconnected—Write zeros in OM3, OM2,
and OM1 in GPT_CR
4. Disable Input Capture Modes—Write zeros in IM1 and IM2 in GPT_CR
5. Change clock source CLKSRC to the desired value in GPT_CR register.
6. Assert the SWR bit in GPT_CR register.
7. Clear GPT status register (GPT_SR) (i.e., w1c).
8. Set ENMOD=1 in GPT_CR register, to bring GPT counter to 0x00000000.
9. Enable GPT (EN=1) in GPT_CR register.
10. Enable GPT interrupt register (GPT_IR).
30.6
GPT Memory Map/Register Definition
The GPT has 10 user-accessible 32-bit registers, which are used to configure, operate,
and monitor the state of the GPT.
An IP bus write access to the GPT Control Register (GPT_CR) and the GPT Output
Compare Register1 (GPT_OCR1) results in one cycle of wait state, while other valid IP
bus accesses incur 0 wait states.
Irrespective of the Response Select signal value, a Write access to the GPT Status
Registers (Read-only registers GPT_ICR1, GPT_ICR2, GPT_CNT) will generate a bus
exception.
Initialization/ Application Information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1432
NXP Semiconductors

<!-- page 1433 -->

• If the Response Select signal is driven Low, then the Read/Write access to the
unimplemented address space of GPT (ips_addr is greater than or equal to $BASE +
$028) will generate a bus exception.
• If the Response Select is driven High, then the Read/Write access to the
unimplemented address space of GPT will not generate any error response (like a bus
exception).
GPT memory map
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
209_8000
GPT Control Register (GPT1_CR)
32
R/W
0000_0000h
30.6.1/1434
209_8004
GPT Prescaler Register (GPT1_PR)
32
R/W
0000_0000h
30.6.2/1438
209_8008
GPT Status Register (GPT1_SR)
32
R/W
0000_0000h
30.6.3/1439
209_800C
GPT Interrupt Register (GPT1_IR)
32
R/W
0000_0000h
30.6.4/1440
209_8010
GPT Output Compare Register 1 (GPT1_OCR1)
32
R/W
FFFF_FFFFh 30.6.5/1441
209_8014
GPT Output Compare Register 2 (GPT1_OCR2)
32
R/W
FFFF_FFFFh 30.6.6/1442
209_8018
GPT Output Compare Register 3 (GPT1_OCR3)
32
R/W
FFFF_FFFFh 30.6.7/1442
209_801C
GPT Input Capture Register 1 (GPT1_ICR1)
32
R
0000_0000h
30.6.8/1443
209_8020
GPT Input Capture Register 2 (GPT1_ICR2)
32
R
0000_0000h
30.6.9/1443
209_8024
GPT Counter Register (GPT1_CNT)
32
R
0000_0000h
30.6.10/
1444
20E_8000
GPT Control Register (GPT2_CR)
32
R/W
0000_0000h
30.6.1/1434
20E_8004
GPT Prescaler Register (GPT2_PR)
32
R/W
0000_0000h
30.6.2/1438
20E_8008
GPT Status Register (GPT2_SR)
32
R/W
0000_0000h
30.6.3/1439
20E_800C
GPT Interrupt Register (GPT2_IR)
32
R/W
0000_0000h
30.6.4/1440
20E_8010
GPT Output Compare Register 1 (GPT2_OCR1)
32
R/W
FFFF_FFFFh 30.6.5/1441
20E_8014
GPT Output Compare Register 2 (GPT2_OCR2)
32
R/W
FFFF_FFFFh 30.6.6/1442
20E_8018
GPT Output Compare Register 3 (GPT2_OCR3)
32
R/W
FFFF_FFFFh 30.6.7/1442
20E_801C
GPT Input Capture Register 1 (GPT2_ICR1)
32
R
0000_0000h
30.6.8/1443
20E_8020
GPT Input Capture Register 2 (GPT2_ICR2)
32
R
0000_0000h
30.6.9/1443
20E_8024
GPT Counter Register (GPT2_CNT)
32
R
0000_0000h
30.6.10/
1444
Chapter 30 General Purpose Timer (GPT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1433

<!-- page 1434 -->

30.6.1
GPT Control Register (GPTx_CR)
The GPT Control Register (GPT_CR) is used to program and configure GPT operations.
An IP Bus Write to the GPT Control Register occurs after one cycle of wait state, while
an IP Bus Read occurs after 0 wait states.
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
0
0
OM3
OM2
OM1
IM2
IM1
W
FO3
FO2
FO1
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
SWR
0
EN_
24M
FRR
CLKSRC
STOPEN
DOZEEN
WAITEN
DBGEN
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
GPTx_CR field descriptions
Field
Description
31
FO3
FO3 Force Output Compare Channel 3
FO2 Force Output Compare Channel 2
FO1 Force Output Compare Channel 1
The FOn bit causes the pin action programmed for the timer Output Compare n pin (according to the OMn
bits in this register).
• The OFn flag (OF3, OF2, OF1) in the status register is not affected.
• This bit is self-negating and always read as zero.
0
Writing a 0 has no effect.
1
Causes the programmed pin action on the timer Output Compare n pin; the OFn flag is not set.
30
FO2
See F03
Table continues on the next page...
GPT Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1434
NXP Semiconductors

<!-- page 1435 -->

GPTx_CR field descriptions (continued)
Field
Description
29
FO1
See F03
28–26
OM3
OM3 (bits 28-26) controls the Output Compare Channel 3 operating mode.
OM2 (bits 25-23) controls the Output Compare Channel 2 operating mode.
OM1 (bits 22-20) controls the Output Compare Channel 1 operating mode.
The OMn bits specify the response that a compare event will generate on the output pin of Output
Compare Channel n.
• The toggle, clear, and set options cause a change on the output pin only if a compare event occurs.
• When OMn is programmed as 1xx (active low pulse), the output pin is set to one immediately on the
next input clock; a low pulse (that is an input clock in width) occurs when there is a compare event.
Note that here, "input clock" refers to the clock selected by the CLKSRC bits of the GPT Control
Register.
000
Output disconnected. No response on pin.
001
Toggle output pin
010
Clear output pin
011
Set output pin
1xx
Generate an active low pulse (that is one input clock wide) on the output pin.
25–23
OM2
See OM3
22–20
OM1
See OM3
19–18
IM2
IM2 (bits 19-18, Input Capture Channel 2 operating mode)
IM1 (bits 17-16, Input Capture Channel 1 operating mode)
The IMn bit field determines the transition on the input pin (for Input capture channel n), which will trigger a
capture event.
00
capture disabled
01
capture on rising edge only
10
capture on falling edge only
11
capture on both edges
17–16
IM1
See IM2
15
SWR
Software reset.
This is the software reset of the GPT module. It is a self-clearing bit.
• The SWR bit is set when the module is in reset state.
• The SWR bit is cleared when the reset procedure finishes.
• Setting the SWR bit resets all of the registers to their default reset values, except for the EN,
ENMOD, STOPEN, WAITEN, and DBGEN bits in the GPT Control Register (this control register).
0
GPT is not in reset state
1
GPT is in reset state
14–11
Reserved
This read-only field is reserved and always has the value 0.
10
EN_24M
Enable 24 MHz clock input from crystal.
• A hardware reset resets the EN_24M bit.
• A software reset does not affect the EN_24M bit.
Table continues on the next page...
Chapter 30 General Purpose Timer (GPT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1435

<!-- page 1436 -->

GPTx_CR field descriptions (continued)
Field
Description
0
24M clock disabled
1
24M clock enabled
9
FRR
Free-Run or Restart mode.
The FFR bit determines the behavior of the GPT when a compare event in channel 1 occurs.
• In Restart mode, after a compare event, the counter resets to 0x00000000 and resumes counting
(after the occurrence of a compare event).
• In Free-Run mode, after a compare event, the counter continues counting until 0xFFFFFFFF and
then rolls over to 0.
0
Restart mode
1
Free-Run mode
8–6
CLKSRC
Clock Source select.
The CLKSRC bits select which clock will go to the prescaler (and subsequently be used to run the GPT
counter).
• The CLKSRC bit field value should only be changed after disabling the GPT by clearing the EN bit in
this register (GPT_CR).
• A software reset does not affect the CLKSRC bit.
000
No clock
001
Peripheral Clock (ipg_clk)
010
High Frequency Reference Clock (ipg_clk_highfreq)
011
External Clock
100
Low Frequency Reference Clock (ipg_clk_32k)
101
Crystal oscillator as Reference Clock (ipg_clk_24M)
others
Reserved
5
STOPEN
GPT Stop Mode enable.
The STOPEN read/write control bit enables GPT operation during Stop mode.
• A hardware reset resets the STOPEN bit.
• A software reset does not affect the STOPEN bit.
0
GPT is disabled in Stop mode.
1
GPT is enabled in Stop mode.
4
DOZEEN
GPT Doze Mode Enable.
• A hardware reset resets the DOZEEN bit.
• A software reset does not affect the DOZEEN bit.
0
GPT is disabled in doze mode.
1
GPT is enabled in doze mode.
3
WAITEN
GPT Wait Mode enable.
The WAITEN read/write control bit enables GPT operation during Wait mode.
• A hardware reset resets the WAITEN bit.
• A software reset does not affect the WAITEN bit.
0
GPT is disabled in wait mode.
1
GPT is enabled in wait mode.
2
DBGEN
GPT debug mode enable.
The DBGEN read/write control bit enables GPT operation during Debug mode.
Table continues on the next page...
GPT Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1436
NXP Semiconductors

<!-- page 1437 -->

GPTx_CR field descriptions (continued)
Field
Description
• A hardware reset resets the DBGEN bit.
• A software reset does not affect the DBGEN bit.
0
GPT is disabled in debug mode.
1
GPT is enabled in debug mode.
1
ENMOD
GPT Enable mode.
When the GPT is disabled (EN=0), then both the Main Counter and Prescaler Counter freeze their current
count values. The ENMOD bit determines the value of the GPT counter when Counter is enabled again (if
the EN bit is set).
• If the ENMOD bit is 1, then the Main Counter and Prescaler Counter values are reset to 0 after GPT
is enabled (EN=1).
• If the ENMOD bit is 0, then the Main Counter and Prescaler Counter restart counting from their
frozen values after GPT is enabled (EN=1).
• If GPT is programmed to be disabled in a low power mode (STOP/WAIT), then the Main Counter
and Prescaler Counter freeze at their current count values when the GPT enters low power mode.
• When GPT exits low power mode, the Main Counter and Prescaler Counter start counting from their
frozen values, regardless of the ENMOD bit value.
• Setting the SWR bit will clear the Main Counter and Prescaler Counter values, regardless of the
value of EN or ENMOD bits.
• A hardware reset resets the ENMOD bit.
• A software reset does not affect the ENMOD bit.
0
GPT counter will retain its value when it is disabled.
1
GPT counter value is reset to 0 when it is disabled.
0
EN
GPT Enable.
The EN bit is the GPT module enable bit.
Before setting the EN bit, we recommend that all registers be properly programmed.
• A hardware reset resets the EN bit.
• A software reset does not affect the EN bit.
0
GPT is disabled.
1
GPT is enabled.
Chapter 30 General Purpose Timer (GPT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1437

<!-- page 1438 -->

30.6.2
GPT Prescaler Register (GPTx_PR)
The GPT Prescaler Register (GPT_PR) contains bits that determine the divide value of
the clock that runs the counter.
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
PRESCALER24M
PRESCALER
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
GPTx_PR field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15–12
PRESCALER24M
Prescaler bits.
24M crystal clock is divided by [PRESCALER24M + 1] before selected by the CLKSRC field. If 24M
crystal clock is not selected, this feild takes no effect.
0x0
Divide by 1
0x1
Divide by 2
...
...
0xF
Divide by 16
PRESCALER
Prescaler bits.
The clock selected by the CLKSRC field is divided by [PRESCALER + 1], and then used to run the
counter.
• A change in the value of the PRESCALER bits cause the Prescaler counter to reset and a new
count period to start immediately.
• See Figure 30-3 for the timing diagram.
0x000
Divide by 1
0x001
Divide by 2
...
...
0xFFF
Divide by 4096
GPT Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1438
NXP Semiconductors

<!-- page 1439 -->

30.6.3
GPT Status Register (GPTx_SR)
The GPT Status Register (GPT_SR) contains bits that indicate that a counter has rolled
over, and if any event has occurred on the Input Capture and Output Compare channels.
The bits are cleared by writing a 1 to them.
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
ROV
IF2
IF1
OF3
OF2
OF1
W
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
GPTx_SR field descriptions
Field
Description
31–6
Reserved
This read-only field is reserved and always has the value 0.
5
ROV
Rollover Flag.
The ROV bit indicates that the counter has reached its maximum possible value and rolled over to 0 (from
which the counter continues counting). The ROV bit is only set if the counter has reached 0xFFFFFFFF in
both Restart and Free-Run modes.
0
Rollover has not occurred.
1
Rollover has occurred.
4
IF2
IF2 Input capture 2 Flag
IF1 Input capture 1 Flag
The IFn bit indicates that a capture event has occurred on Input Capture channel n.
0
Capture event has not occurred.
1
Capture event has occurred.
3
IF1
See IF2
2
OF3
OF3 Output Compare 3 Flag
OF2 Output Compare 2 Flag
OF1 Output Compare 1 Flag
The OFn bit indicates that a compare event has occurred on Output Compare channel n.
0
Compare event has not occurred.
1
Compare event has occurred.
Table continues on the next page...
Chapter 30 General Purpose Timer (GPT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1439

<!-- page 1440 -->

GPTx_SR field descriptions (continued)
Field
Description
1
OF2
See OF3
0
OF1
See OF3
30.6.4
GPT Interrupt Register (GPTx_IR)
The GPT Interrupt Register (GPT_IR) contains bits that control whether interrupts are
generated after rollover, input capture and output compare events.
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
ROVIE
IF2IE
IF1IE
OF3IE
OF2IE
OF1IE
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
GPTx_IR field descriptions
Field
Description
31–6
Reserved
This read-only field is reserved and always has the value 0.
5
ROVIE
Rollover Interrupt Enable.
The ROVIE bit controls the Rollover interrupt.
0
Rollover interrupt is disabled.
1
Rollover interrupt enabled.
4
IF2IE
IF2IE Input capture 2 Interrupt Enable
IF1IE Input capture 1 Interrupt Enable
The IFnIE bit controls the IFnIE Input Capture n Interrupt Enable.
0
IF2IE Input Capture n Interrupt Enable is disabled.
1
IF2IE Input Capture n Interrupt Enable is enabled.
Table continues on the next page...
GPT Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1440
NXP Semiconductors

<!-- page 1441 -->

GPTx_IR field descriptions (continued)
Field
Description
3
IF1IE
See IF2IE
2
OF3IE
OF3IE Output Compare 3 Interrupt Enable
OF2IE Output Compare 2 Interrupt Enable
OF1IE Output Compare 1 Interrupt Enable
The OFnIE bit controls the Output Compare Channel n interrupt.
0
Output Compare Channel n interrupt is disabled.
1
Output Compare Channel n interrupt is enabled.
1
OF2IE
See OF3IE
0
OF1IE
See OF3IE
30.6.5
GPT Output Compare Register 1 (GPTx_OCR1)
The GPT Compare Register 1 (GPT_OCR1) holds the value that determines when a
compare event will be generated on Output Compare Channel 1. Any write access to the
Compare register of Channel 1 while in Restart mode (FRR=0) will reset the GPT
counter.
An IP Bus Write access to the GPT Output Compare Register1 (GPT_OCR1) occurs
after one cycle of wait state; an IP Bus Read access occurs immediately (0 wait states).
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
COMP
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
GPTx_OCR1 field descriptions
Field
Description
COMP
Compare Value.
When the counter value equals the COMP bit field value, a compare event is generated on Output
Compare Channel 1.
Chapter 30 General Purpose Timer (GPT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1441

<!-- page 1442 -->

30.6.6
GPT Output Compare Register 2 (GPTx_OCR2)
The GPT Compare Register 2 (GPT_OCR2) holds the value that determines when a
compare event will be generated on Output Compare Channel 2.
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
COMP
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
GPTx_OCR2 field descriptions
Field
Description
COMP
Compare Value.
When the counter value equals the COMP bit field value, a compare event is generated on Output
Compare Channel 2.
30.6.7
GPT Output Compare Register 3 (GPTx_OCR3)
The GPT Compare Register 3 (GPT_OCR3) holds the value that determines when a
compare event will be generated on Output Compare Channel 3.
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
COMP
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
GPTx_OCR3 field descriptions
Field
Description
COMP
Compare Value.
When the counter value equals the COMP bit field value, a compare event is generated on Output
Compare Channel 3.
GPT Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1442
NXP Semiconductors

<!-- page 1443 -->

30.6.8
GPT Input Capture Register 1 (GPTx_ICR1)
The GPT Input Capture Register 1 (GPT_ICR1) is a read-only register that holds the
value that was in the counter during the last capture event on Input Capture Channel 1.
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
CAPT
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
GPTx_ICR1 field descriptions
Field
Description
CAPT
Capture Value.
After a capture event on Input Capture Channel 1 occurs, the current value of the counter is loaded into
GPT Input Capture Register 1.
30.6.9
GPT Input Capture Register 2 (GPTx_ICR2)
The GPT Input capture Register 2 (GPT_ICR2) is a read-only register which holds the
value that was in the counter during the last capture event on input capture channel 2.
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
CAPT
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
GPTx_ICR2 field descriptions
Field
Description
CAPT
Capture Value.
After a capture event on Input Capture Channel 2 occurs, the current value of the counter is loaded into
GPT Input Capture Register 2.
Chapter 30 General Purpose Timer (GPT)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1443

<!-- page 1444 -->

30.6.10
GPT Counter Register (GPTx_CNT)
The GPT Counter Register (GPT_CNT) is the main counter's register. GPT_CNT is a
read-only register and can be read without affecting the counting process of the GPT.
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
GPTx_CNT field descriptions
Field
Description
COUNT
Counter Value.
The COUNT bits show the current count value of the GPT counter.
GPT Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1444
NXP Semiconductors

