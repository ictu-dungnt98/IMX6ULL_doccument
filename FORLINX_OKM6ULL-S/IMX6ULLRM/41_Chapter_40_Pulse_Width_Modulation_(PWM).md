# Chapter 40: Pulse Width Modulation (PWM)

> Nguồn: `IMX6ULLRM.pdf` — trang 2473–2488

<!-- page 2473 -->

Chapter 40
Pulse Width Modulation (PWM)
40.1
Overview
The Pulse Width Modulation (PWM) has a 16-bit counter, and is optimized to generate
sound from stored sample audio images and it can also generate tones. It uses 16-bit
resolution and a 4 x 16 data FIFO.
This section presents an overview of the PWM. A block diagram of the PWM module is
shown in the figure below.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2473

<!-- page 2474 -->

S
R
PWMO
IRQ_B
PWM Signals
CMPIE
CMP
ROV
POUTC
POUTC
ROVIE
IRQEN
4x16 bit FIFO
16-bit Sample Register
16-bit Period Register
16-bit Counter Register
12-bit Prescaler
Prescaler Clock
Output (PCLK)
System Peripheral Bus
Clock Off
CLKSRC
CMP
CMP
ipg_clk
ipg_clk _highfreq
ipg_clk_32k
Figure 40-1. Pulse-Width Modulator Block Diagram
The following features characterize the PWM:
• 16-bit up-counter with clock source selection
• 4 x 16 FIFO to minimize interrupt overhead
• 12-bit prescaler for division of clock
• Sound and melody generation
• Active high or active low configured output
• Can be programmed to be active in low-power mode
• Can be programmed to be active in debug mode
• Interrupts at compare and rollover
40.2
External Signals
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2474
NXP Semiconductors

<!-- page 2475 -->

The PWM follows IP Bus protocol when interfacing with the processor core. PWM does
not have any interface signals with any other block inside the chip except for clock and
reset inputs from the Clock Control Module (CCM), System Reset Controller (SRC), and
interrupt signals to the processor interrupt handler. There is a single output signal.
The following table outlines the external signals.
Table 40-1. PWM External Signals
Signal
Description
Pad
Mode
Direction
PWM1_OUT
This is the PWM1 functional output
of the PWM. A modulated signal of
the block is observed at this pin. It
can be viewed as a clock signal
whose period and duty cycle can be
varied with different settings of the
cycle of 50%.
ENET1_RX_DATA0
ALT2
O
GPIO1_IO08
ALT0
LCD_DATA00
ALT1
PWM2_OUT
This is the PWM2 functional output
of the PWM. A modulated signal of
the block is observed at this pin. It
can be viewed as a clock signal
whose period and duty cycle can be
varied with different settings of the
cycle of 50%.
ENET1_RX_DATA1
ALT2
O
GPIO1_IO09
ALT0
LCD_DATA01
ALT1
PWM3_OUT
This is the PWM3 functional output
of the PWM. A modulated signal of
the block is observed at this pin. It
can be viewed as a clock signal
whose period and duty cycle can be
varied with different settings of the
cycle of 50%.
GPIO1_IO04
ALT1
O
LCD_DATA02
ALT1
NAND_ALE
ALT3
PWM4_OUT
This is the PWM4 functional output
of the PWM. A modulated signal of
the block is observed at this pin. It
can be viewed as a clock signal
whose period and duty cycle can be
varied with different settings of the
cycle of 50%.
GPIO1_IO05
ALT1
O
LCD_DATA03
ALT1
NAND_WP_B
ALT3
PWM5_OUT
This is the PWM5 functional output
of the PWM. A modulated signal of
the block is observed at this pin. It
can be viewed as a clock signal
whose period and duty cycle can be
varied with different settings of the
cycle of 50%.
ENET1_TX_DATA1
ALT2
O
LCD_DATA18
ALT1
NAND_DQS
ALT3
PWM6_OUT
This is the PWM6 functional output
of the PWM. A modulated signal of
the block is observed at this pin. It
can be viewed as a clock signal
whose period and duty cycle can be
varied with different settings of the
cycle of 50%.
ENET1_TX_EN
ALT2
O
JTAG_TDI
ALT4
LCD_DATA19
ALT1
PWM7_OUT
This is the PWM7 functional output
of the PWM. A modulated signal of
CSI_VSYNC
ALT6
O
ENET1_TX_CLK
ALT2
Table continues on the next page...
Chapter 40 Pulse Width Modulation (PWM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2475

<!-- page 2476 -->

Table 40-1. PWM External Signals (continued)
Signal
Description
Pad
Mode
Direction
the block is observed at this pin. It
can be viewed as a clock signal
whose period and duty cycle can be
varied with different settings of the
cycle of 50%.
JTAG_TCK
ALT4
PWM8_OUT
This is the PWM8 functional output
of the PWM. A modulated signal of
the block is observed at this pin. It
can be viewed as a clock signal
whose period and duty cycle can be
varied with different settings of the
cycle of 50%.
CSI_HSYNC
ALT6
O
ENET1_RX_ER
ALT2
JTAG_TRST_B
ALT4
40.3
Clocks
The table found here describes the clock sources for PWM. Please see Clock Controller
Module (CCM) for clock setting, configuration and gating information.
Table 40-2. PWM Clocks
Clock name
Clock Root
Description
ipg_clk
ipg_clk_root
Peripheral clock
ipg_clk_32k
ckil_sync_clk_root
low-frequency reference clock (32 kHz)
ipg_clk_highfreq
perclk_clk_root
high-frequency reference clock
ipg_clk_s
ipg_clk_root
Peripheral access clock
The clock that feeds the prescaler can be selected from:
• High-frequency reference clock (ipg_clk_highfreq) pat_ref or CKIH
This is a high frequency clock, provided by the Clock Control Module (CCM). This
clock should be on in the low power mode when the ipg_clk is turned off. Thus, the
PWM can be run on this clock in the low power mode. The CCM is expected to
provide this clock after synchronizing it to ahb_clk in the normal functional mode
and then switch to the unsynchronized version in the low power mode.
• Low-frequency reference clock (ipg_clk_32k, CKIL)
Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2476
NXP Semiconductors

<!-- page 2477 -->

This is the 32 KHz low reference clock which is provided by the CCM. This clock
should be on in the low power mode when ipg_clk is turned off. Thus, PWM can be
run on this clock in the low power mode. The CCM is expected to provide this clock
after synchronizing it to ahb_clk in the normal functional mode and then switch to
the unsynchronized version in the low power mode.
• Peripheral clock (ipg_clk)
This clock should be on in normal operations. In low power mode, it can be switched
off.
• Peripheral access clock (ipg_clk_s)
This clock is used for register read/write.
The clock input source is determined by the PWM control register field
PWM_CR[CLKSRC]. The CLKSRC value should only be changed when the PWM is
disabled.
A change in the value of the PRESCALER field of the control register is immediately
reflected on its output clock frequency.
40.4
Functional Description
The following sections detail the PWM operation and function.
40.4.1
Operation
The output of the PWM is a toggling signal whose frequency and duty cycle can be
modulated by programming the appropriate registers. It has a 16-bit up counter which
counts from 0x0000 until the counter value equals the PWM_PR + 1. After this match
occurs the counter is reset to 0x0000.
At the beginning of a count period cycle, the PWMO pin is set to one (default) and the
counter begins counting up from 0x0000. The sample value in the sample FIFO is
compared on each count of prescaler clock. When the sample and count values match, the
PWMO signal is cleared to zero (default). The counter continues counting until the period
match occurs and subsequently another period cycle begins.
When the PWM is enabled, the counter starts running and generates an output with the
reset values in the period and sample registers. It is recommended that the programming
of these registers be done before PWM is enabled.
Chapter 40 Pulse Width Modulation (PWM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2477

<!-- page 2478 -->

A hardware reset results in all the PWM count and sample registers being cleared and the
FIFO being flushed. The control register shows that FIFO is empty and it can be written
into, and the PWM is disabled. A software reset has the same results, however the state of
the DBGEN, STOPEN, DOZEN, and WAITEN bits in the control register are not
affected. Software reset can be asserted even when the PWM is in disabled state.
40.4.1.1
FIFO
Digital sample values can be loaded into the pulse-width modulator as 16-bit words. The
endianess can be changed using the BCTR and HCTR bits of the control register. A 4-
word (16-bit) FIFO minimizes interrupt overhead. A maskable interrupt is generated
when the number of data words fall below the water level set by the FWM field in the
control register.
A write to the PWM_SAR sample register results in the value being stored into the FIFO
if it is not full. A write when the FIFO is full sets FWE (FIFO write error) bit in the status
register and the FIFO contents remain unchanged. The FIFO can be written at any time,
but can be read only when the PWM is enabled. The PWM_SR[FIFOAV] field shows
how many data words are currently contained in the FIFO and whether or not it can be
written into.
A read on the sample register yields the current FIFO value that is being used, or will be
used, by the PWM for generation on the output signal. Therefore, a write and a
subsequent read on the sample register may result in different values being obtained.
40.4.1.2
Rollover and Compare Event
The counter is reset to 0x0000 after its value equals the PWM_PR[PERIOD] + 1 and
resumes counting thereafter. This event is referred to as a rollover. For example, if
PWM_PR[PERIOD] = 0x0000, the counter is reset when it equals 0x0001. When
PWM_PR[PERIOD] = 0xFFFF or 0xFFFE, the counter is reset when it equals 0xFFFF.
For more information, see the PWM Period Register (PWM_PR) description.
During a rollover event the output is either set (default), reset or has no effect according
to the programming of the POUTC field in the control register. This event can also
generate an interrupt if the respective interrupt enable bit is set in the control register.
When the counter value reaches the sample value, the output of the PWM is reset
(default), set or has no effect according to the programming of the POUTC field of
control register. This event is referred to as a compare event. This event can also generate
an interrupt if the respective interrupt enable bit is set in the control register.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2478
NXP Semiconductors

<!-- page 2479 -->

If the rollover event sets the PWM output signal, the compare event will reset it and vice
versa for a particular programming configuration of POUTC field.
40.4.1.3
Low Power Mode Behavior
In low power mode, if the clock from the selected clock source is available, the PWM
counter continues to run and an output is produced, depending on whether the control bit
for that mode is set or not. In the absence of the clock itself, or if the corresponding low
power bit in the control register is 0, the counter is reset and resumes counting when it
exits the low power mode.
40.4.1.4
Debug Mode Behavior
In debug mode, PWM has the option of continuing to run or be halted. If the DBGEN bit
is not set in the PWM_PWMCR, the PWM is halted. If the DBGEN bit is set, then the
PWM will continue to run in the debug mode.
40.5
Enable Sequence for the PWM
The sequence found here should be used to enable the PWM.
1. Configure the desired settings for the PWM Control Register (PWMx_PWMCR)
while keeping the PWM disabled (PWMx_PWMCR[0]=0).
2. Enable the desired interrupts in the PWM Interrupt Register (PWMx_PWMIR).
3. One to three initial samples may be written to the PWM Sample Register
(PWMx_PWMSAR). The initial sample values will be loaded into the PWM FIFO
even if the PWM is not yet enabled. Do not write a 4th sample because the FIFO will
become full and trigger a FIFO Write Error (FWE). This error will prevent the PWM
from starting once it is enabled.
4. Check the FIFO Write Error status bit (FWE), the Compare status bit (CMP) and the
Roll-over status bit (ROV) in the PWM Status Register (PWMx_PWMSR) to make
sure they are all zero. Any non-zero status bits should be cleared by writing a 1 to
them.
5. Write the desired period to the PWM Period Register (PWMx_PWMPR).
6. Enable the PWM by writing a 1 to the PWM Enable bit, PWMx_PWMCR[0], while
maintaining the other register bits in their previously configured state.
Chapter 40 Pulse Width Modulation (PWM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2479

<!-- page 2480 -->

40.6
Disable Sequence for the PWM
The PWM can be disabled at any time by clearing the PWM enable bit,
PWMx_PWMCR[0] to 0.
Any data remaining in the FIFO will not be produced at the PWM output after the PWM
has been disabled and will remain in the FIFO until the PWM is enabled again. A
software reset (setting PWMx_PWMCR[3] to 1) or a hardware reset will clear the FIFO
and any remaining data will be lost.
40.7
PWM Memory Map/Register Definition
The PWM includes six user-accessible 32-bit registers.
PWM memory map
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
208_0000
PWM Control Register (PWM1_PWMCR)
32
R/W
0000_0000h
40.7.1/2482
208_0004
PWM Status Register (PWM1_PWMSR)
32
w1c
0000_0008h
40.7.2/2484
208_0008
PWM Interrupt Register (PWM1_PWMIR)
32
R/W
0000_0000h
40.7.3/2485
208_000C
PWM Sample Register (PWM1_PWMSAR)
32
R/W
0000_0000h
40.7.4/2486
208_0010
PWM Period Register (PWM1_PWMPR)
32
R/W
0000_FFFEh
40.7.5/2487
208_0014
PWM Counter Register (PWM1_PWMCNR)
32
R
0000_0000h
40.7.6/2488
208_4000
PWM Control Register (PWM2_PWMCR)
32
R/W
0000_0000h
40.7.1/2482
208_4004
PWM Status Register (PWM2_PWMSR)
32
w1c
0000_0008h
40.7.2/2484
208_4008
PWM Interrupt Register (PWM2_PWMIR)
32
R/W
0000_0000h
40.7.3/2485
208_400C
PWM Sample Register (PWM2_PWMSAR)
32
R/W
0000_0000h
40.7.4/2486
208_4010
PWM Period Register (PWM2_PWMPR)
32
R/W
0000_FFFEh
40.7.5/2487
208_4014
PWM Counter Register (PWM2_PWMCNR)
32
R
0000_0000h
40.7.6/2488
208_8000
PWM Control Register (PWM3_PWMCR)
32
R/W
0000_0000h
40.7.1/2482
208_8004
PWM Status Register (PWM3_PWMSR)
32
w1c
0000_0008h
40.7.2/2484
208_8008
PWM Interrupt Register (PWM3_PWMIR)
32
R/W
0000_0000h
40.7.3/2485
208_800C
PWM Sample Register (PWM3_PWMSAR)
32
R/W
0000_0000h
40.7.4/2486
208_8010
PWM Period Register (PWM3_PWMPR)
32
R/W
0000_FFFEh
40.7.5/2487
208_8014
PWM Counter Register (PWM3_PWMCNR)
32
R
0000_0000h
40.7.6/2488
208_C000
PWM Control Register (PWM4_PWMCR)
32
R/W
0000_0000h
40.7.1/2482
208_C004
PWM Status Register (PWM4_PWMSR)
32
w1c
0000_0008h
40.7.2/2484
208_C008
PWM Interrupt Register (PWM4_PWMIR)
32
R/W
0000_0000h
40.7.3/2485
208_C00C
PWM Sample Register (PWM4_PWMSAR)
32
R/W
0000_0000h
40.7.4/2486
Table continues on the next page...
PWM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2480
NXP Semiconductors

<!-- page 2481 -->

PWM memory map (continued)
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
208_C010
PWM Period Register (PWM4_PWMPR)
32
R/W
0000_FFFEh
40.7.5/2487
208_C014
PWM Counter Register (PWM4_PWMCNR)
32
R
0000_0000h
40.7.6/2488
20F_0000
PWM Control Register (PWM5_PWMCR)
32
R/W
0000_0000h
40.7.1/2482
20F_0004
PWM Status Register (PWM5_PWMSR)
32
w1c
0000_0008h
40.7.2/2484
20F_0008
PWM Interrupt Register (PWM5_PWMIR)
32
R/W
0000_0000h
40.7.3/2485
20F_000C
PWM Sample Register (PWM5_PWMSAR)
32
R/W
0000_0000h
40.7.4/2486
20F_0010
PWM Period Register (PWM5_PWMPR)
32
R/W
0000_FFFEh
40.7.5/2487
20F_0014
PWM Counter Register (PWM5_PWMCNR)
32
R
0000_0000h
40.7.6/2488
20F_4000
PWM Control Register (PWM6_PWMCR)
32
R/W
0000_0000h
40.7.1/2482
20F_4004
PWM Status Register (PWM6_PWMSR)
32
w1c
0000_0008h
40.7.2/2484
20F_4008
PWM Interrupt Register (PWM6_PWMIR)
32
R/W
0000_0000h
40.7.3/2485
20F_400C
PWM Sample Register (PWM6_PWMSAR)
32
R/W
0000_0000h
40.7.4/2486
20F_4010
PWM Period Register (PWM6_PWMPR)
32
R/W
0000_FFFEh
40.7.5/2487
20F_4014
PWM Counter Register (PWM6_PWMCNR)
32
R
0000_0000h
40.7.6/2488
20F_8000
PWM Control Register (PWM7_PWMCR)
32
R/W
0000_0000h
40.7.1/2482
20F_8004
PWM Status Register (PWM7_PWMSR)
32
w1c
0000_0008h
40.7.2/2484
20F_8008
PWM Interrupt Register (PWM7_PWMIR)
32
R/W
0000_0000h
40.7.3/2485
20F_800C
PWM Sample Register (PWM7_PWMSAR)
32
R/W
0000_0000h
40.7.4/2486
20F_8010
PWM Period Register (PWM7_PWMPR)
32
R/W
0000_FFFEh
40.7.5/2487
20F_8014
PWM Counter Register (PWM7_PWMCNR)
32
R
0000_0000h
40.7.6/2488
20F_C000
PWM Control Register (PWM8_PWMCR)
32
R/W
0000_0000h
40.7.1/2482
20F_C004
PWM Status Register (PWM8_PWMSR)
32
w1c
0000_0008h
40.7.2/2484
20F_C008
PWM Interrupt Register (PWM8_PWMIR)
32
R/W
0000_0000h
40.7.3/2485
20F_C00C
PWM Sample Register (PWM8_PWMSAR)
32
R/W
0000_0000h
40.7.4/2486
20F_C010
PWM Period Register (PWM8_PWMPR)
32
R/W
0000_FFFEh
40.7.5/2487
20F_C014
PWM Counter Register (PWM8_PWMCNR)
32
R
0000_0000h
40.7.6/2488
Chapter 40 Pulse Width Modulation (PWM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2481

<!-- page 2482 -->

40.7.1
PWM Control Register (PWMx_PWMCR)
The PWM control register (PWM_PWMCR) is used to configure the operating settings
of the PWM. It contains the prescaler for the clock division.
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
FWM
STOPEN
DOZEN
WAITEN
DBGEN
BCTR
HCTR
POUTC
CLKSRC
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
PRESCALER
SWR
REPEAT
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
PWMx_PWMCR field descriptions
Field
Description
31–28
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
27–26
FWM
FIFO Water Mark. These bits are used to set the data level at which the FIFO empty flag will be set and
the corresponding interrupt generated
00
FIFO empty flag is set when there are more than or equal to 1 empty slots in FIFO
01
FIFO empty flag is set when there are more than or equal to 2 empty slots in FIFO
10
FIFO empty flag is set when there are more than or equal to 3 empty slots in FIFO
11
FIFO empty flag is set when there are more than or equal to 4 empty slots in FIFO
25
STOPEN
Stop Mode Enable. This bit keeps the PWM functional while in stop mode. When this bit is cleared, the
input clock is gated off in stop mode. This bit is not affected by software reset. It is cleared by hardware
reset.
0
Inactive in stop mode
1
Active in stop mode
24
DOZEN
Doze Mode Enable. This bit keeps the PWM functional in doze mode. When this bit is cleared, the input
clock is gated off in doze mode. This bit is not affected by software reset. It is cleared by hardware reset.
0
Inactive in doze mode
1
Active in doze mode
23
WAITEN
Wait Mode Enable. This bit keeps the PWM functional in wait mode. When this bit is cleared, the input
clock is gated off in wait mode. This bit is not affected by software reset. It is cleared by hardware reset.
Table continues on the next page...
PWM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2482
NXP Semiconductors

<!-- page 2483 -->

PWMx_PWMCR field descriptions (continued)
Field
Description
0
Inactive in wait mode
1
Active in wait mode
22
DBGEN
Debug Mode Enable. This bit keeps the PWM functional in debug mode. When this bit is cleared, the input
clock is gated off in debug mode. This bit is not affected by software reset. It is cleared by hardware reset.
0
Inactive in debug mode
1
Active in debug mode
21
BCTR
Byte Data Swap Control. This bit determines the byte ordering of the 16-bit data when it goes into the
FIFO from the sample register.
0
byte ordering remains the same
1
byte ordering is reversed
20
HCTR
Half-word Data Swap Control. This bit determines which half word data from the 32-bit IP Bus interface is
written into the lower 16 bits of the sample register.
0
Half word swapping does not take place
1
Half words from write data bus are swapped
19–18
POUTC
PWM Output Configuration. This bit field determines the mode of PWM output on the output pin.
00
Output pin is set at rollover and cleared at comparison
01
Output pin is cleared at rollover and set at comparison
10
PWM output is disconnected
11
PWM output is disconnected
17–16
CLKSRC
Select Clock Source. These bits determine which clock input will be selected for running the counter. After
reset the system functional clock is selected. The input clock can also be turned off if these bits are set to
00. This field value should only be changed when the PWM is disabled
00
Clock is off
01
ipg_clk
10
ipg_clk_highfreq
11
ipg_clk_32k
15–4
PRESCALER
Counter Clock Prescaler Value. This bit field determines the value by which the clock will be divided
before it goes to the counter.
0x000
Divide by 1
0x001
Divide by 2
0xfff
Divide by 4096
3
SWR
Software Reset. PWM is reset when this bit is set to 1. It is a self clearing bit. A write 1 to this bit is a single
wait state write cycle. When the block is in reset state this bit is set and is cleared when the reset
procedure is over. Setting this bit resets all the registers to their reset values except for the DBGEN,
STOPEN, DOZEN, and WAITEN bits in this control register.
0
PWM is out of reset
1
PWM is undergoing reset
2–1
REPEAT
Sample Repeat. This bit field determines the number of times each sample from the FIFO is to be used.
00
Use each sample once
01
Use each sample twice
10
Use each sample four times
11
Use each sample eight times
Table continues on the next page...
Chapter 40 Pulse Width Modulation (PWM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2483

<!-- page 2484 -->

PWMx_PWMCR field descriptions (continued)
Field
Description
0
EN
PWM Enable. This bit enables the PWM. If this bit is not enabled, the clock prescaler and the counter is
reset. When the PWM is enabled, it begins a new period, the output pin is set to start a new period while
the prescaler and counter are released and counting begins.
To make the PWM work with softreset and disable/enable, users can do software reset by seting the SWR
bit, wait software reset done, configure the registers, and then enable the PWM by setting this bit to "1"
Users can also disable/enable the PWM if PWM would like to be stopped and resumed with same
registers configurations .
0
PWM disabled
1
PWM enabled
40.7.2
PWM Status Register (PWMx_PWMSR)
The PWM status register (PWM_PWMSR) contains seven bits which display the state of
the FIFO and the occurrence of rollover and compare events. The FIFOAV bit is read-
only but the other four bits can be cleared by writing 1 to them. The FE, ROV, and CMP
bits are associated with FIFO-Empty, Roll-over, and Compare interrupts, respectively.
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
FWE
CMP
ROV
FE
FIFOAV
W
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
1
0
0
0
PWMx_PWMSR field descriptions
Field
Description
31–7
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
6
FWE
FIFO Write Error Status. This bit shows that an attempt has been made to write FIFO when it is full.
0
FIFO write error not occurred
1
FIFO write error occurred
5
CMP
Compare Status. This bit shows that a compare event has occurred.
0
Compare event not occurred
1
Compare event occurred
Table continues on the next page...
PWM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2484
NXP Semiconductors

<!-- page 2485 -->

PWMx_PWMSR field descriptions (continued)
Field
Description
4
ROV
Roll-over Status. This bit shows that a roll-over event has occurred.
0
Roll-over event not occurred
1
Roll-over event occurred
3
FE
FIFO Empty Status Bit. This bit indicates the FIFO data level in comparison to the water level set by FWM
field in the control register.
0
Data level is above water mark
1
When the data level falls below the mark set by FWM field
FIFOAV
FIFO Available. These read-only bits indicate the data level remaining in the FIFO. An attempted write to
these bits will not affect their value and no transfer error is generated.
000
No data available
001
1 word of data in FIFO
010
2 words of data in FIFO
011
3 words of data in FIFO
100
4 words of data in FIFO
101
unused
110
unused
111
unused
40.7.3
PWM Interrupt Register (PWMx_PWMIR)
The PWM Interrupt register (PWM_PWMIR) contains three bits which control the
generation of the compare, rollover and FIFO empty interrupts.
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
CIE
RIE
FIE
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
PWMx_PWMIR field descriptions
Field
Description
31–3
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
2
CIE
Compare Interrupt Enable. This bit controls the generation of the Compare interrupt.
Table continues on the next page...
Chapter 40 Pulse Width Modulation (PWM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2485

<!-- page 2486 -->

PWMx_PWMIR field descriptions (continued)
Field
Description
0
Compare Interrupt not enabled
1
Compare Interrupt enabled
1
RIE
Roll-over Interrupt Enable. This bit controls the generation of the Rollover interrupt.
0
Roll-over interrupt not enabled
1
Roll-over Interrupt enabled
0
FIE
FIFO Empty Interrupt Enable. This bit controls the generation of the FIFO Empty interrupt.
0
FIFO Empty interrupt disabled
1
FIFO Empty interrupt enabled
40.7.4
PWM Sample Register (PWMx_PWMSAR)
The PWM sample register (PWM_PWMSAR) is the input to the FIFO. 16-bit words are
loaded into the FIFO. The FIFO can be written at any time, but can be read only when the
PWM is enabled. The PWM will run at the last set duty-cycle setting if all the values of
the FIFO has been utilized, until the FIFO is reloaded or the PWM is disabled. When a
new value is written, the duty cycle changes after the current period is over.
A value of zero in the sample register will result in the PWMO output signal always
being low/high (POUTC = 00 it will be low and POUTC = 01 it will be high), and no
output waveform will be produced. If the value in this register is higher than the PERIOD
+ 1, the output will never be set/reset depending on POUTC value.
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
0
SAMPLE
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
PWMx_PWMSAR field descriptions
Field
Description
31–16
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
SAMPLE
Sample Value. This is the input to the 4x16 FIFO. The value in this register denotes the value of the
sample being currently used.
PWM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2486
NXP Semiconductors

<!-- page 2487 -->

40.7.5
PWM Period Register (PWMx_PWMPR)
The PWM period register (PWM_PWMPR) determines the period of the PWM output
signal. After the counter value matches PERIOD + 1, the counter is reset to start another
period.
PWMO (Hz) = PCLK(Hz) / (period +2)
A value of zero in the PWM_PWMPR will result in a period of two clock cycles for the
output signal. Writing 0xFFFF to this register will achieve the same result as writing
0xFFFE.
A change in the period value due to a write in PWM_PWMPR results in the counter
being reset to zero and the start of a new count period.
NOTE
Settings PWM_PWMPR to 0xFFFF when PWMx_PWMCR
REPEAT bits are set to non-zero values is not allowed.
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
0
PERIOD
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
0
PWMx_PWMPR field descriptions
Field
Description
31–16
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
PERIOD
Period Value. These bits determine the Period of the count cycle. The counter counts up to [Period Value]
+1 and is then reset to 0x0000.
Chapter 40 Pulse Width Modulation (PWM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2487

<!-- page 2488 -->

40.7.6
PWM Counter Register (PWMx_PWMCNR)
The read-only pulse-width modulator counter register (PWM_PWMCNR) contains the
current count value and can be read at any time without disturbing the counter.
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
0
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
PWMx_PWMCNR field descriptions
Field
Description
31–16
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
COUNT
Counter Value. These bits are the counter register value and denotes the current count state the counter
register is in.
PWM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2488
NXP Semiconductors

