# Chapter 59: Watchdog Timer (WDOG)

> Nguồn: `IMX6ULLRM.pdf` — trang 4079–4098

<!-- page 4079 -->

Chapter 59
Watchdog Timer (WDOG)
59.1
Overview
The Watchdog Timer (WDOG) protects against system failures by providing a method by
which to escape from unexpected events or programming errors.
Once the WDOG is activated, it must be serviced by the software on a periodic basis. If
servicing does not take place, the timer times out. Upon timeout, the WDOG asserts the
internal system reset signal, WDOG_RESET_B_DEB to the System Reset Controller
(SRC).
There is also a provision for WDOG signal assertion by timeout counter expiration. There
is an option of programmable interrupt generation before the counter actually times out.
The time at which the interrupt needs to be generated prior to counter timeout is
programmable. There is a power down counter which is enabled out of any reset (POR,
Warm/Cold). This counter has a fixed timeout period of 16 seconds, upon which it asserts
the WDOG signal.
Flow diagrams for the timeout counter, power down counter and interrupt operations are
are shown in Flow Diagrams.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4079

<!-- page 4080 -->

LOW POWER
WAIT Mode
LOW POWER 
STOP/ DOZE
 Mode
DEBUG Mode
Low Frequency
Reference Clock
Peripheral Bus
Low Frequency
Reference Clock
Low Power
Control
Control
Power Down Counter
WDOG-1 Generation
Logic
Pre Time-Out Interrupt
Logic
Time-Out Counter
WDOG-1 Reset
Generation Logic
TIMEOUT
WDOG-1
Interrupt
wdog_rst
Reset
Figure 59-1. WDOG Diagram
59.1.1
Features
The WDOG features are listed below:
• Configurable timeout counter with timeout periods from 0.5 to 128 seconds which,
after timeout expiration, result in the assertion of WDOG_RESET_B_DEB reset
signal .
• Time resolution of 0.5 seconds
• Configurable timeout counter that can be programmed to run or stop during low-
power modes
• Configurable timeout counter that can be programmed to run or stop during DEBUG
mode
• Programmable interrupt generation prior to timeout
• The duration between interrupt and timeout events can be programmed from 0 to
127.5 seconds in steps of 0.5 seconds.
• Power down counter with fixed timeout period of 16 seconds, which if not disabled
after reset will assert WDOG_B signal low
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4080
NXP Semiconductors

<!-- page 4081 -->

• Power down counter will be enabled out of any reset (POR, Warm / Cold reset)
by default.
59.2
External signals
Table 59-1. WDOG External Signals
Signal
Description
Pad
Mode
Direction
WDOG1_ANY
Global WDOG signal
ENET2_RX_ER
ALT8
IO
GPIO1_IO09
ALT1
LCD_DATA19
ALT2
LCD_RESET
ALT4
WDOG1_B
This signal will power down the chip. GPIO1_IO01
ALT8
IO
GPIO1_IO08
ALT1
UART3_RTS_B
ALT8
WDOG1_RST_B_DEB
This signal is a reset source for the
chip.
ENET1_TX_DATA1
ALT8
O
LCD_CLK
ALT8
WDOG2_B
This signal will power down the chip. LCD_VSYNC
ALT4
IO
WDOG2_RST_B_DEB
This signal is a reset source for the
chip.
ENET1_TX_EN
ALT8
O
WDOG3_B
This signal will power down the chip. GPIO1_IO00
ALT8
IO
WDOG3_RST_B_DEB
This signal is a reset source for the
chip.
LCD_HSYNC
ALT4
O
59.3
Clocks
This section describes clocks and special clocking requirements of the block.
The WDOG uses the low frequency reference clock for its counter and control
operations. The peripheral bus clock is used for register read/write operations.
The following table describes the clock sources for WDOG. Please see Introduction for
clock setting, configuration and gating information.
Table 59-2. WDOG Clocks
Clock name
Clock Root
Description
ipg_clk
ipg_clk_root
IP Global functional clock. All functionality inside the WDOG module is
synchronized to this clock.
ipg_clk_s
ipg_clk_root
IP slave bus clock. This clock is synchronized to ipg_clk and is only used
for register read/write operations.
Table continues on the next page...
Chapter 59 Watchdog Timer (WDOG)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4081

<!-- page 4082 -->

Table 59-2. WDOG Clocks (continued)
Clock name
Clock Root
Description
ipg_clk_32k
ckil_sync_clk_root
Low frequency (32.768 kHz) clock that continues to run in low-power
mode. It is assumed that the Clock Controller will provide this clock signal
synchronized to ipg_clk in the normal mode, and switch to a non-
synchronized signal in low-power mode when the ipg_clk is off.
59.4
Watchdog mechanism and system integration
There are two WDOG modules, WDOG1 and WDOG2 (TZ) in the chip. The modules are
disabled by default (after reset). WDOG1 will be configured during boot while WDOG2
is dedicated for secure world purposes and will be activated by TZ software if required.
The TZ watchdog (TZ watchdog) module protects against TZ starvation by providing a
method of escaping normal mode and forcing a switch to the TZ mode.TZ starvation is a
situation where the normal OS prevents switching to the TZ mode. Such a situation is
undesirable as it can compromise the system’s security.
Once the TZ WDOG module is activated, it must be serviced by TZ on a periodic basis.
If servicing does not take place, the timer times out. Upon a timeout, the TZ WDOG
asserts a TZ-mapped interrupt that forces switching to the TZ mode. If it is still not
serviced, the TZ WDOG asserts a security violation signal to the CSU. The TZ WDOG
module cannot be programmed or de-activated by normal mode software.
The WDOG modules operate as follows:
• If servicing does not take place, the timer times out and the wdog_rst_b signal is
activated (low)
• Interrupt can be generated before the counter actually times out
• The wdog_rst_b signal can be activated by software
• There is a power-down counter which gets enabled out of any reset. This counter has
a fixed timeout period of 16 seconds upon which it will assert the ipp_wdog_b
signal.
The following figure shows the WDOG1 and WDOG2 connectivity at the system level.
Watchdog mechanism and system integration
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4082
NXP Semiconductors

<!-- page 4083 -->

Figure 59-2. System integration
59.5
Functional description
This section provides a complete functional description of the block.
59.5.1
Timeout event
The WDOG provides timeout periods from 0.5 to 128 seconds with a time resolution of
0.5 seconds.
The user can determine the timeout period by writing to the WDOG timeout field
(WT[7:0]) in the Watchdog Control Register (WDOG_WCR). The WDOG must be
enabled by setting the WDE bit of Watchdog Control Register (WDOG_WCR) for the
timeout counter to start running. After the WDOG is enabled, the counter is activated,
loads the timeout value and begins to count down from this programmed value. The timer
will time out when the counter reaches zero and the WDOG outputs a system reset signal,
WDOG_RESET_B_DEB and asserts WDOG_B (WDT bit should be set in Watchdog
Control Register (WDOG_WCR)).
Chapter 59 Watchdog Timer (WDOG)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4083

<!-- page 4084 -->

However, the timeout condition can be prevented by reloading the counter with the new
timeout value (WT[7:0] of WDOG_WCR) if a service routine (see Servicing WDOG to
reload the counter) is performed before the counter reaches zero. If any system errors
occur which prevent the software from servicing the Watchdog Service Register
(WDOG_WSR), the timeout condition occurs. By performing the service routine, the
WDOG reloads its counter to the timeout value indicated by bits WT[7:0] of the
Watchdog Control Register (WDOG_WCR) and it restarts the countdown.
A system reset will reset the counter and place it in the idle state at any time during the
countdown. The counter flow diagram is shown in Flow Diagrams.
NOTE
The timeout value is reloaded to the counter either at the time
WDOG is enabled or after the service routine has been
performed.
59.5.1.1
Servicing WDOG to reload the counter
To reload a timeout value to the counter the proper service sequence begins by writing
0x_5555 followed by 0x_AAAA to the Watchdog Service Register (WDOG_WSR). Any
number of instructions can be executed between the two writes. If the WDOG_WSR is
not loaded with 0x_5555 prior to writing 0x_AAAA to the WDOG_WSR, the counter is
not reloaded. If any value other than 0x_AAAA is written to the WDOG_WSR after
0x_5555, the counter is not reloaded. This service sequence will reload the counter with
the timeout value WT[7:0] of Watchdog Control Register (WDOG_WCR). The timeout
value can be changed at any point; it is reloaded when WDOG is serviced by the core.
59.5.2
Interrupt event
Prior to timeout, the WDOG can generate an interrupt which can be considered a warning
that timeout will occur shortly.
The duration between interrupt event and timeout event can be controlled by writing to
the WICT field of Watchdog Interrupt Control Register (WDOG_WICR). It can vary
between 0 and 127.5 seconds. If the WDOG is serviced (Servicing WDOG to reload the
counter)before the interrupt generation, the counter will be reloaded with the timeout
value WT[7:0] of Watchdog Control Register (WDOG_WCR) and the interrupt will not
be triggered.
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4084
NXP Semiconductors

<!-- page 4085 -->

59.5.3
Power-down counter event
The power-down counter inside WDOG will be enabled out of reset. This counter has a
fixed timeout value of 16 seconds, after which it will drive the WDOG_B signal low.
To prevent this, the software must disable this counter by clearing the PDE bit of
Watchdog Miscellaneous Control Register (WDOG_WMCR) within 16 seconds of reset
deassertion. Once disabled, this counter can't be enabled again until the next system reset
occurs. This feature is intended to prevent the hanging up of cores after reset, as WDOG
is not enabled out of reset.
59.5.4
Low power modes
59.5.4.1
STOP and DOZE mode
If the WDOG timer disable bit for low power STOP and DOZE mode (WDZST) bit in
the Watchdog Control Register (WDOG_WCR), is cleared, the WDOG timer continues
to operate using the low frequency reference clock. If the low power enable (WDZST) bit
is set, the WDOG timer operation will be suspended in low power STOP or DOZE mode.
Upon exiting low power STOP or DOZE mode, the WDOG operation returns to what it
was prior to entering the STOP or DOZE mode.
59.5.4.2
WAIT mode
If the WDOG timer disable bit for low power WAIT mode (WDW) bit in the Watchdog
Control Register (WDOG_WCR), is cleared, the WDOG timer continues to operate using
the low frequency reference clock . If the low power WAIT enable (WDW) bit is set, the
WDOG timer operation will be suspended. Upon exiting low power WAIT mode, the
WDOG operation returns to what it was prior to entering the WAIT mode.
NOTE
The WDOG timer won't be able to detect events that happen for
periods shorter than one low frequency reference clock cycle.
For example, in repeated WAIT mode entry or exit, if the RUN
mode time is less than one low frequency reference clock cycle
and if the WDW bit is set, the WDOG timer may never time
out, even though the system is in RUN mode for a finite
duration; WDOG may not see a low frequency reference clock
edge during its wake time.
Chapter 59 Watchdog Timer (WDOG)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4085

<!-- page 4086 -->

59.5.5
Debug mode
The WDOG timer can be configured for continual operation, or for suspension during
debug mode. If the WDOG debug enable (WDBG) bit is set in the Watchdog Control
Register (WDOG_WCR), the WDOG timer operation is suspended in debug mode. If the
WDBG bit is set and the debug mode is entered, WDOG timer operation is suspended
after two low frequency reference clocks. Similarly, WDOG timer operation continues
after two low frequency reference clocks of debug mode exit. Register read and write
accesses in debug mode continue to function normally. Also, while in debug mode, the
WDE bit of Watchdog Control Register (WDOG_WCR) can be enabled/disabled
directly. If the WDOG debug enable (WDBG) bit is cleared then WDOG timer operation
is not suspended. The power-down counter is not affected by debug mode entry/exit.
NOTE
If the WDE bit of Watchdog Control Register (WDOG_WCR)
is set/cleared while in debug mode, it remains set/cleared even
after exiting debug mode.
59.5.6
Operations
59.5.6.1
Watchdog reset generation
The WDOG generated reset signal WDOG_RESET_B_DEB is asserted by the following
operations:
• A software write to the Software Reset Signal (SRS) bit of the Watchdog Control
Register (WDOG_WCR).
• WDOG timeout. See Timeout event.
The wdog_rst will be asserted for one clock cycle of low frequency reference clock for
both a timeout condition and a software write occurrence. It remains asserted for 1 clock
cycle of low frequency reference clock even if a system reset is asserted in between.
Figure 59-4 shows the timing diagram of this signal due to a timeout condition.
59.5.6.2
WDOG_B generation
The WDOG asserts WDOG_B in the following scenarios:
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4086
NXP Semiconductors

<!-- page 4087 -->

• Software write to WDA bit of Watchdog Control Register (WDOG_WCR).
WDOG_B signal remains asserted as long as the WDA bit is "0".
• WDOG timeout condition, WDT bit of Watchdog Control Register (WDOG_WCR)
must be set for this scenario. A description of the timeout condition can be found in
the Timeout event. WDOG_B signal remains asserted until a power-on reset (POR)
occurs. It gets cleared after the POR occurs (not due to any other system reset).
Figure 59-5 shows the timing diagram of WDOG_B due to timeout condition.
• WDOG power-down counter timeout, PDE bit of Watchdog Miscellaneous Control
Register (WDOG_WMCR) should not be cleared for this scenario. A description of
this counter can be found in the Power-down counter event. WDOG_B signal
remains asserted for one clock cycle of low frequency reference clock.
Figure 59-3 shows the scenarios under which WDOG_B gets asserted.
Power Down Counter
WDOG-1 Time Out Counter
Logic
WDOG-1
WDOG_WCR[WDT]
WDOG_WCR[WDA]
Low Frequency
Reference Clock
WDOG_WMCR[PDE]
Watchdog Control Register (WDOG_WCR)
Watchdog Misc. Control Register (WDOG_WMCR)
Figure 59-3. WDOG_B generation
Chapter 59 Watchdog Timer (WDOG)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4087

<!-- page 4088 -->

Low frequency
reference clock
Time-out
Counter
wdog_rst
System reset
WDOG-1
01
00
Figure 59-4. WDOG timeout condition/WDT bit is not set
Low frequency
reference clock
Time-out
Counter
wdog_rst
System reset
WDOG-1
01
00
Power on reset
Figure 59-5. WDOG timeout condition/WDT bit is set
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4088
NXP Semiconductors

<!-- page 4089 -->

59.5.7
Reset
The block is reset by a system reset and the WDOG counter will be disabled. The power-
down counter is enabled and starts counting.
59.5.8
Interrupt
The WDOG has the feature of Interrupt generation before timeout.
The interrupt will be generated only if the WIE bit in Watchdog Interrupt Control
Register (WDOG_WICR) is set. The exact time at which the interrupt should occur (prior
to timeout) depends on the value of WICT field of Watchdog Interrupt Control Register
(WDOG_WICR). For example, if the WICT field has a value 0x04, then the interrupt
will be generated two seconds prior to timeout. Once the interrupt is triggered the WTIS
bit in Watchdog Interrupt Control Register (WDOG_WICR) will be set. The software
needs to clear this bit to deassert the interrupt. If the WDOG is serviced before the
interrupt generation then the counter will be reloaded with the timeout value WT[7:0] of
Watchdog Control Register (WDOG_WCR) and interrupt would not be triggered.
59.5.9
Flow Diagrams
A flow diagram of WDOG operation is shown below.
Chapter 59 Watchdog Timer (WDOG)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4089

<!-- page 4090 -->

Reset
(Cold/Warm)
negated?
Counter in
IDLE State
start counter
Decrement counter
PDE bit
cleared?
Is
count=0?
Assert WDOG
no
no
no
yes
yes
yes
Figure 59-6. Power-Down Counter Flow Diagram
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4090
NXP Semiconductors

<!-- page 4091 -->

Reset
Negated?
no
Enable interrupt
& WDOG timer
yes
Decrement counter
yes
Interrupt
count=0?
no
Is
WDOG
serviced?
yes
Reload counter
no
Assert interrupt
yes
Interrupt
Count=0?
Figure 59-7. Interrupt Generation Flow Diagram
59.6
Initialization
The following sequence should be performed for WDOG initialization.
• PDE bit of Watchdog Miscellaneous Control Register (WDOG_WMCR) should be
cleared to disable the power down counter.
Chapter 59 Watchdog Timer (WDOG)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4091

<!-- page 4092 -->

• WT field of Watchdog Control Register (WDOG_WCR) should be programmed for
sufficient timeout value.
• WDOG should be enabled by setting WDE bit of Watchdog Control Register
(WDOG_WCR) so that the timeout counter loads the WT field value of Watchdog
Control Register (WDOG_WCR) and starts counting.
59.7
WDOG Memory Map/Register Definition
The WDOG Memory Map/Register Definition can be found here.
The WDOG has user-accessible, 16-bit registers used to configure, operate, and monitor
the state of the Watchdog Timer. Byte operations can be performed on these registers. If
a 32-bit access is performed,the WDOG will not generate a peripheral bus error but will
behave normally, like a 16-Bit access, making read/write possible. A 32-Bit access
should be avoided, as the system may go to an unknown state.
WDOG memory map
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
20B_C000
Watchdog Control Register (WDOG1_WCR)
16
R/W
0030h
59.7.1/4093
20B_C002
Watchdog Service Register (WDOG1_WSR)
16
R/W
0000h
59.7.2/4094
20B_C004
Watchdog Reset Status Register (WDOG1_WRSR)
16
R
0000h
59.7.3/4095
20B_C006
Watchdog Interrupt Control Register (WDOG1_WICR)
16
R/W
0004h
59.7.4/4096
20B_C008
Watchdog Miscellaneous Control Register
(WDOG1_WMCR)
16
R/W
0001h
59.7.5/4097
20C_0000
Watchdog Control Register (WDOG2_WCR)
16
R/W
0030h
59.7.1/4093
20C_0002
Watchdog Service Register (WDOG2_WSR)
16
R/W
0000h
59.7.2/4094
20C_0004
Watchdog Reset Status Register (WDOG2_WRSR)
16
R
0000h
59.7.3/4095
20C_0006
Watchdog Interrupt Control Register (WDOG2_WICR)
16
R/W
0004h
59.7.4/4096
20C_0008
Watchdog Miscellaneous Control Register
(WDOG2_WMCR)
16
R/W
0001h
59.7.5/4097
21E_4000
Watchdog Control Register (WDOG3_WCR)
16
R/W
0030h
59.7.1/4093
21E_4002
Watchdog Service Register (WDOG3_WSR)
16
R/W
0000h
59.7.2/4094
21E_4004
Watchdog Reset Status Register (WDOG3_WRSR)
16
R
0000h
59.7.3/4095
21E_4006
Watchdog Interrupt Control Register (WDOG3_WICR)
16
R/W
0004h
59.7.4/4096
21E_4008
Watchdog Miscellaneous Control Register
(WDOG3_WMCR)
16
R/W
0001h
59.7.5/4097
WDOG Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4092
NXP Semiconductors

<!-- page 4093 -->

59.7.1
Watchdog Control Register (WDOGx_WCR)
The Watchdog Control Register (WDOG_WCR) controls the WDOG operation.
• WDZST, WDBG and WDW are write-once only bits. Once the software does a write
access to these bits, they will be locked and cannot be reprogrammed until the next
system reset assertion.
• WDE is a write one once only bit. Once software performs a write "1" operation to
this bit it cannot be reset/cleared until the next system reset.
• WDT is also a write one once only bit. Once software performs a write "1" operation
to this bit it cannot be reset/cleared until the next POR. This bit does not get reset/
cleared due to any system reset.
Address: Base address + 0h offset
Bit
15
14
13
12
11
10
9
8
Read
WT
Write
Reset
0
0
0
0
0
0
0
0
Bit
7
6
5
4
3
2
1
0
Read
WDW
SRE
WDA
SRS
WDT
WDE
WDBG
WDZST
Write
Reset
0
0
1
1
0
0
0
0
WDOGx_WCR field descriptions
Field
Description
15–8
WT
Watchdog Time-out Field. This 8-bit field contains the time-out value that is loaded into the Watchdog
counter after the service routine has been performed or after the Watchdog is enabled. After reset,
WT[7:0] must have a value written to it before enabling the Watchdog otherwise count value of zero which
is 0.5 seconds is loaded into the counter.
NOTE: The time-out value can be written at any point of time but it is loaded to the counter at the time
when WDOG is enabled or after the service routine has been performed. For more information
see Timeout event .
0x00
- 0.5 Seconds (Default).
0x01
- 1.0 Seconds.
0x02
- 1.5 Seconds.
0x03
- 2.0 Seconds.
0xff
- 128 Seconds.
7
WDW
Watchdog Disable for Wait. This bit determines the operation of WDOG during Low Power WAIT mode.
This is a write once only bit.
0
Continue WDOG timer operation (Default).
1
Suspend WDOG timer operation.
6
SRE
software reset extension, an option way to generate software reset
Table continues on the next page...
Chapter 59 Watchdog Timer (WDOG)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4093

<!-- page 4094 -->

WDOGx_WCR field descriptions (continued)
Field
Description
adopt a new way to generate a more robust software reset. This bit can be set/clear with IP bus and will
be reset with power-on reset .
0
using original way to generate software reset (default)
1
using new way to generate software reset.
5
WDA
WDOG_B assertion. Controls the software assertion of the WDOG_B signal.
0
Assert WDOG_B output.
1
No effect on system (Default).
4
SRS
Software Reset Signal. Controls the software assertion of the WDOG-generated reset signal
WDOG_RESET_B_DEB . This bit automatically resets to "1" after it has been asserted to "0".
NOTE: This bit does not generate the software reset to the block.
0
Assert system reset signal.
1
No effect on the system (Default).
3
WDT
WDOG_B Time-out assertion. Determines if the WDOG_B gets asserted upon a Watchdog Time-out
Event. This is a write-one once only bit.
NOTE: There is no effect on WDOG_RESET_B_DEB (WDOG Reset) upon writing on this bit. WDOG_B
gets asserted along with WDOG_RESET_B_DEB if this bit is set.
0
No effect on WDOG_B (Default).
1
Assert WDOG_B upon a Watchdog Time-out event.
2
WDE
Watchdog Enable. Enables or disables the WDOG block. This is a write one once only bit. It is not
possible to clear this bit by a software write, once the bit is set.
NOTE: This bit can be set/reset in debug mode (exception).
0
Disable the Watchdog (Default).
1
Enable the Watchdog.
1
WDBG
Watchdog DEBUG Enable. Determines the operation of the WDOG during DEBUG mode. This bit is write
once only.
0
Continue WDOG timer operation (Default).
1
Suspend the watchdog timer.
0
WDZST
Watchdog Low Power. Determines the operation of the WDOG during low-power modes. This bit is write
once-only.
NOTE: The WDOG can continue/suspend the timer operation in the low-power modes (STOP and DOZE
mode).
0
Continue timer operation (Default).
1
Suspend the watchdog timer.
59.7.2
Watchdog Service Register (WDOGx_WSR)
When enabled, the WDOG requires that a service sequence be written to the Watchdog
Service Register (WSR) to prevent the timeout condition.
WDOG Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4094
NXP Semiconductors

<!-- page 4095 -->

NOTE
Executing the service sequence will reload the WDOG timeout
counter.
Address: Base address + 2h offset
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
Read
WSR
Write
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
WDOGx_WSR field descriptions
Field
Description
WSR
Watchdog Service Register. This 16-bit field contains the Watchdog service sequence. Both writes must
occur in the order listed prior to the time-out, but any number of instructions can be executed between the
two writes. The service sequence must be performed as follows:
0x5555
Write to the Watchdog Service Register (WDOG_WSR).
0xAAAA Write to the Watchdog Service Register (WDOG_WSR).
59.7.3
Watchdog Reset Status Register (WDOGx_WRSR)
The WRSR is a read-only register that records the source of the output reset assertion. It
is not cleared by a hard reset. Therefore, only one bit in the WRSR will always be
asserted high. The register will always indicate the source of the last reset generated due
to WDOG. Read access to this register is with one wait state. Any write performed on
this register will generate a Peripheral Bus Error .
A reset can be generated by the following sources, as listed in priority from highest to
lowest:
• Watchdog Time-out
• Software Reset
Address: Base address + 4h offset
Bit
15
14
13
12
11
10
9
8
Read
0
Write
Reset
0
0
0
0
0
0
0
0
Bit
7
6
5
4
3
2
1
0
Read
0
POR
0
TOUT
SFTW
Write
Reset
0
0
0
0
0
0
0
0
Chapter 59 Watchdog Timer (WDOG)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4095

<!-- page 4096 -->

WDOGx_WRSR field descriptions
Field
Description
15–5
Reserved
This read-only field is reserved and always has the value 0.
4
POR
Power On Reset. Indicates whether the reset is the result of a power on reset.
0
Reset is not the result of a power on reset.
1
Reset is the result of a power on reset.
3–2
Reserved
This read-only field is reserved and always has the value 0.
1
TOUT
Timeout. Indicates whether the reset is the result of a WDOG timeout.
0
Reset is not the result of a WDOG timeout.
1
Reset is the result of a WDOG timeout.
0
SFTW
Software Reset. Indicates whether the reset is the result of a WDOG software reset by asserting SRS bit
0
Reset is not the result of a software reset.
1
Reset is the result of a software reset.
59.7.4
Watchdog Interrupt Control Register (WDOGx_WICR)
The WDOG_WICR controls the WDOG interrupt generation.
Address: Base address + 6h offset
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
Read
WIE
WTIS
0
WICT
Write
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
1
0
0
WDOGx_WICR field descriptions
Field
Description
15
WIE
Watchdog Timer Interrupt enable bit. Reset value is 0.
NOTE: This bit is a write once only bit. Once the software does a write access to this bit, it will get locked
and cannot be reprogrammed until the next system reset assertion
0
Disable Interrupt (Default).
1
Enable Interrupt.
14
WTIS
Watchdog TImer Interrupt Status bit will reflect the timer interrupt status, whether interrupt has occurred or
not. Once the interrupt has been triggered software must clear this bit by writing 1 to it.
0
No interrupt has occurred (Default).
1
Interrupt has occurred
13–8
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
WDOG Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4096
NXP Semiconductors

<!-- page 4097 -->

WDOGx_WICR field descriptions (continued)
Field
Description
WICT
Watchdog Interrupt Count Time-out (WICT) field determines, how long before the counter time-out must
the interrupt occur. The reset value is 0x04 implies interrupt will occur 2 seconds before time-out. The
maximum value that can be programmed to WICT field is 127.5 seconds with a resolution of 0.5 seconds.
NOTE: This field is write once only. Once the software does a write access to this field, it will get locked
and cannot be reprogrammed until the next system reset assertion.
0x00
WICT[7:0] = Time duration between interrupt and time-out is 0 seconds.
0x01
WICT[7:0] = Time duration between interrupt and time-out is 0.5 seconds.
0x04
WICT[7:0] = Time duration between interrupt and time-out is 2 seconds (Default).
0xff
WICT[7:0] = Time duration between interrupt and time-out is 127.5 seconds.
59.7.5
Watchdog Miscellaneous Control Register
(WDOGx_WMCR)
WDOG_WMCR Controls the Power Down counter operation.
Address: Base address + 8h offset
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
Read
0
PDE
Write
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
1
WDOGx_WMCR field descriptions
Field
Description
15–1
Reserved
This read-only field is reserved and always has the value 0.
0
PDE
Power Down Enable bit. Reset value of this bit is 1, which means the power down counter inside the
WDOG is enabled after reset. The software must write 0 to this bit to disable the counter within 16
seconds of reset de-assertion. Once disabled this counter cannot be enabled again. See Power-down
counter event for operation of this counter.
NOTE: This bit is write-one once only bit. Once software sets this bit it cannot be reset until the next
system reset.
0
Power Down Counter of WDOG is disabled.
1
Power Down Counter of WDOG is enabled (Default).
Chapter 59 Watchdog Timer (WDOG)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4097

<!-- page 4098 -->

WDOG Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4098
NXP Semiconductors

