# Chapter 33: Keypad Port (KPP)

> Nguồn: `IMX6ULLRM.pdf` — trang 2111–2130

<!-- page 2111 -->

Chapter 33
Keypad Port (KPP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2111

<!-- page 2112 -->

33.1
Overview
The Keypad Port (KPP) is a 16-bit peripheral that can be used as a keypad matrix
interface or as general purpose input/output (I/O).
The figure below shows the KPP block diagram. The KPP provides interface for the
keypad matrix with 2-point contact or 3-point contact keys. The KPP is designed to
simplify the software task of scanning a keypad matrix. With appropriate software
support, the KPP is capable of detecting, debouncing, and decoding one or multiple keys
pressed simultaneously on the keypad.
KPP_KDDR[KRDD]
PULL-UP / DATA DIRECTION (KPP_KDDR) AND
ROW ENABLE CONTROLS (KPP_KPCR)
DATA DIRECTION (KPP_KDDR) AND
OPEN DRAIN ENABLE (KPP_KPCR) CONTROLS
KPP_KPDR[KCD]
KPP_KPSR
KPP_KPCR[KCO]
KPP_KDDR[KCDD]
KPP_KPDR[KRD]
KPP_KPCR[KRE]
Glitch Suppression
Logic
Low Freq
Reference
Clock
KEYPAD MATRIX
UP TO 8X8
TO INTERRUPT
CONTROLLER
Figure 33-1. KPP Peripheral Block Diagram
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2112
NXP Semiconductors

<!-- page 2113 -->

33.1.1
Features
The KPP includes these distinctive features:
• Supports up to an 8 x 8 external key pad matrix
• Port pins can be used as general purpose I/O
• Open drain design
• Glitch suppression circuit design
• Multiple-key detection
• Long key-press detection
• Standby key-press detection
• Synchronizer chain clear
• Supports a 2-point and 3-point contact key matrix
33.1.2
Modes and Operations
This block supports the following modes:
• Run Mode-This is the normal functional mode in which the KPP can detect any key
press event.
• Low Power Mode-The keypad can detect any key press even in low power modes
(when there is no MCU clock).
33.2
Clocks
The table found here describes the clock sources for KPP.
Please see Clock Controller Module (CCM) for clock setting, configuration and gating
information.
Table 33-1. KPP Clocks
Clock name
Clock Root
Description
ipg_clk_32k
ckil_sync_clk_root
Low-frequency reference clock (32 kHz)
ipg_clk_s
ipg_clk_root
Peripheral access clock
Chapter 33 Keypad Port (KPP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2113

<!-- page 2114 -->

33.3
External Signals
There are several pins dedicated to the KPP. Keypads of any configuration up to eight
rows and eight columns are supported through the software configuration of the
peripheral pins. Any pins not used for the keypad are available as general purpose I/O.
The registers are configured such that the pins can be treated as an I/O port up to 16 bits
wide.
See the table below for the list of external signals.
Table 33-2. KPP External Signals
Signal
Description
Pad
Mode
Direction
KPP_COL0
Column input or output pin, from
chip
ENET1_RX_DATA1
ALT6
IO
NAND_WE_B
ALT3
KPP_COL1
Column input or output pin, from
chip
ENET1_TX_DATA0
ALT6
IO
NAND_DATA01
ALT3
KPP_COL2
Column input or output pin, from
chip
ENET1_TX_EN
ALT6
IO
NAND_DATA03
ALT3
KPP_COL3
Column input or output pin, from
chip
ENET1_RX_ER
ALT6
IO
KPP_COL4
Column input or output pin, from
chip
ENET2_RX_DATA1
ALT6
IO
KPP_COL5
Column input or output pin, from
chip
ENET2_TX_DATA0
ALT6
IO
KPP_COL6
Column input or output pin, from
chip
ENET2_TX_EN
ALT6
IO
KPP_COL7
Column input or output pin, from
chip
ENET2_RX_ER
ALT6
IO
KPP_ROW0
Row input or output pin, from chip
ENET1_RX_DATA0
ALT6
IO
NAND_RE_B
ALT3
KPP_ROW1
Row input or output pin, from chip
ENET1_RX_EN
ALT6
IO
NAND_DATA00
ALT3
KPP_ROW2
Row input or output pin, from chip
ENET1_RX_DATA1
ALT6
IO
NAND_DATA02
ALT3
KPP_ROW3
Row input or output pin, from chip
ENET1_TX_CLK
ALT6
IO
KPP_ROW4
Row input or output pin, from chip
ENET2_RX_DATA0
ALT6
IO
KPP_ROW5
Row input or output pin, from chip
ENET2_RX_EN
ALT6
IO
KPP_ROW6
Row input or output pin, from chip
ENET2_TX_DATA1
ALT6
IO
KPP_ROW7
Row input or output pin, from chip
ENET2_TX_CLK
ALT6
IO
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2114
NXP Semiconductors

<!-- page 2115 -->

33.3.1
Input Pins
Any of the 16 pins associated with the KPP can be configured as inputs by writing a "0"
to the appropriate bits in the KPP_KDDR. Additionally, the least significant 8 bits (ROW
inputs) corresponding to KPP_KDDR[KRDD] have internal pull-ups, which are enabled
when the pin is used as an input.
33.3.2
Output Pins
Any of the 16 pins associated with the KPP can be configured as outputs by writing the
appropriate bits in the KPP_KDDR to a "1". Additionally, the 8 most significant bits
(15-8) can be designated as open drain outputs by writing a "1" to the appropriate bits in
the KPP_KPCR. The lower 8 bits (7-0) are always in "totem pole" style, driven when
configured as outputs.
See the table below.
Table 33-3. Keypad Port Column Modes
KPP_KDDR (15:8)
KPP_KPCR (15:8)
Pin Function
0
x
Input
1
0
Totem-Pole Output
1
1
Open-Drain Output
NOTE
Totem pole capability should be provided for column pins.
Totem pole configuration helps for a faster discharge of keypad
capacitance when all columns need to be quickly brought to a
"1" during the scan routine. With this configuration, delay
between the scanning of two subsequent columns is reduced.
33.3.3
Generation of Transfer Error Signal on Peripheral Bus
If there is an access to an address which is not implemented, then the KPP asserts a
transfer error signal on Peripheral Bus.
Chapter 33 Keypad Port (KPP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2115

<!-- page 2116 -->

33.4
Functional Description
The Keypad Port (KPP) is designed to simplify the software task of scanning a keypad
matrix. With appropriate software support and matrix organization, the KPP is capable of
detecting, debouncing, and decoding one or more keys pressed simultaneously on the
keypad.
Logic in the KPP is capable of detecting a key press even while the processor is in one of
the low power standby modes provided that a low frequency reference clock
(ipg_clk_32k) is on. The KPP may generate an Arm platform interrupt any time a key
press or key release is detected. This interrupt is capable of forcing the processor out of a
low power mode.
33.4.1
Keypad Matrix Construction
The KPP is designed to interface to a keypad matrix, which shorts the intersecting row
and column lines together whenever a key is depressed. The interface is not optimized for
any other switch configuration.
33.4.2
Keypad Port Configuration
The software must initialize the KPP for the size of the keypad matrix. Pins connected to
the keypad columns should be configured as open-drain outputs. Pins connected to the
keypad rows should be configured as inputs. On-chip, pull-up resistors should be
implemented for active keypad rows.
In addition to enabled row inputs in the Keypad Control register, corresponding interrupt
(depress or/and release) must also be enabled to generate an interrupt.
Discrete switches that are not part of the matrix may be connected to any unused row
inputs. The second terminal of the discrete switch is connected to ground. The hardware
detects closures of these switches without the need for software polling.
33.4.3
Keypad Matrix Scanning
Keypad scanning is performed by a software loop that walks a zero across each of the
keypad columns, reading the value on the rows at each step. The process is repeated
several times in succession, with the results of each pass optionally compared to those
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2116
NXP Semiconductors

<!-- page 2117 -->

from the previous pass. When several (3 or 4) consecutive scans yield the same key
closures, a valid key press has been detected. Software then can decode exactly which
switch was depressed and pass the value up to the next higher software layer.
The basic debouncing period, which must be defined in the software routine, may be
controlled with an internal timer. The basic period is the period between the scan of two
consecutive columns, so the debouncing time between two consecutive scans of the
whole matrix shall be the number of columns multiplied by the basic period.
33.4.4
Keypad Standby
There is no need for the Arm platform to continually scan the keypad. Between key
presses, the keypad can be left in a state that requires no software intervention until the
next key press is detected. To place the keypad in a standby state, software should write
all column outputs low. Row inputs are left enabled. At this point, the Arm platform can
attend to other tasks or revert to a low power standby mode. The KPP will interrupt the
Arm platform if any key is pressed.
Upon receiving a keypad interrupt, the Arm platform should set all the column strobes
high, and begin a normal keypad scanning routine to determine which key was pressed. It
is important that open-drain drivers be used when scanning to prevent a possible DC path
between power and ground through two or more switches.
33.4.5
Glitch Suppression on Keypad Inputs
A glitch suppression circuit qualifies the keypad inputs to prevent noise from
inadvertently interrupting the Arm platform. The circuit is a 4-state synchronizer clocked
from a low frequency reference clock (ipg_clk_32k) source. This clock must continue to
run in any low power mode where the keypad is a wake-up source, as the Arm platform
interrupt is generated from the synchronized input. An interrupt is not generated until all
four synchronizer stages have latched a valid key assertion. This guarantees the filtering
out of any noise less than three clock periods in duration of a low frequency reference
clock. Noise filtering of the duration between three to four clock periods cannot be
guaranteed. The interrupt output is latched in an S-R latch and remains asserted until
cleared by the software. The Set input of the latch is rising-edge clocked. See the figure
below.
Chapter 33 Keypad Port (KPP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2117

<!-- page 2118 -->

D     Q
   
    
      S 
D     Q
    
      S 
D     Q
    
      S 
D     Q
    
      S 
D     Q
    
      S 
D     Q
    
      S 
FF
FF
FF
FF
FF
FF
Row Pins
KEYPAD
MATRIX
Column Pins
ANDing of pins with
RDW-enable bits
NAND
KPKD
Clear KPKD Status Flag
Clear KPKD Synchronizer
D
R
KPKR
Clear KPKR Status Flag
Clear KPKR Synchronizer
Low Freq
Ref Clock
KPP_KPCR[KRE]
D
R
Figure 33-2. Keypad Synchronizer Functional Diagram
33.4.6
Multiple Key Closures
Using the key press and key release interrupts, the software can detect multiple keys or
achieve n key rollover. The key scanning routine can be programmed accordingly (See
Initialization/Application Information for more information).
The following figures illustrate the interface of a 2-contact keypad matrix with the KPP
controller. With proper enabling of row lines and the performing scan-routine, multiple
key presses can be detected. When keys present on the same row are pressed,
corresponding row lines (multiple lines) become low when the column is driven low
during a scan-routine. By reading the data-register, pressed keys can be detected.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2118
NXP Semiconductors

<!-- page 2119 -->

Similarly, when keys present on same row line are pressed, the corresponding row line
(only one line) becomes low when logic "0" is driven on the column line during a scan-
routine.
Output configuration
Input configuration
with pull-ups
Row
lines
Column
lines
Keypad Port
Controller
Switch matrix
Multiple key
presses
Figure 33-3. Multiple Key Presses on Same Column Line (Simplified View)
Chapter 33 Keypad Port (KPP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2119

<!-- page 2120 -->

Output configuration
Input configuration
with pull-ups
Row
lines
Column
lines
Keypad Port
Controller
Switch matrix
Multiple key
presses
Figure 33-4. Multiple Key Presses on Same Row Line (Simplified View)
NOTE
An n key rollover is a technique with which the system can
recognize the order in which keys are pressed.
33.4.6.1
Ghost Key Problem and Correction
The KPP detects if one or multiple keys are pressed or released. In the case where a
simple keypad matrix with two-contact switches is used, there is a chance of "ghost" key
detection when three or more keys are pressed. This is a limitation imposed by such a
keypad matrix.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2120
NXP Semiconductors

<!-- page 2121 -->

As seen in Figure 33-5, three keys pressed simultaneously can cause a short between the
column currently "scanned" by the software and another column. Depending on the
location of the third key pressed, a "ghost" key press may be detected.
However, this can be corrected by using a keypad matrix that provides "ghost" key
protection. Such a matrix implements a one-way "diode" at all keypad points between
rows and columns. This way, the multiple pressing of three keys will not cause a short at
a fourth key (see Figure 33-6).
Column pulled 
down
Column not
pulled down
Three real 
key presses
Pulled down
row
Pulled down
row
The path of the 
zero pull down 
that reaches the 
wrong row and 
so generates a 
ghost key press
Ghost key
press
Figure 33-5. Decoding Wrong Three- Key-Presses
Chapter 33 Keypad Port (KPP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2121

<!-- page 2122 -->

Column pulled 
down
Column not
pulled down
The path of zero pull down 
gets stopped at this point
Three real 
key presses
Diode prevents ghost key
press
Pulled down
row
Pulled down
row
The path of the 
zero pull down
cannot reach the
wrong row
Switches with
diode
Figure 33-6. Matrix with "Ghost" Key Protections
33.4.7
3-Point Contact Keys Support
The KPP supports interfacing to a matrix consisting of 3-point contact keys. As shown in
Figure 33-7, two points of such a key are connected to keypad lines, while a third point is
connected to ground (low logic).
The keypad lines should be configured as input and a pull-up should to be present on
these lines. When such a key is pressed, corresponding keypad lines go low and an
interrupt is generated. There is no need to perform a scanning routine for identification of
pressed key as it can be done by reading the keypad data-register. A limitation with such
a matrix is that for every key at least one keypad row line should be used.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2122
NXP Semiconductors

<!-- page 2123 -->

Keypad Port
Controller
Keypad
Lines
Input Configuration
with Pull-ups
3-Point Contact Keys
GND
Figure 33-7. KPP Interface with 3-point Contact Key Matrix (Simplified View)
33.5
Initialization/Application Information
33.5.1
Typical Keypad Configuration and Scanning Sequence
Perform the following steps to configure the keypad:
1. Enable the number of rows in the keypad (KPP_KPCR[KRE]).
2. Write 0s to KPP_KPDR[KCD].
3. Configure the keypad columns as open-drain (KPP_KPCR[KCO]).
4. Configure columns as output (KPP_KDDR[KCDD]) and rows as input
(KPP_KDDR[KRDD]).
5. Clear the KPKD Status Flag and Synchronizer chain.
6. Set the KDIE control bit, and clear the KRIE control bit (avoid false release events).
Chapter 33 Keypad Port (KPP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2123

<!-- page 2124 -->

7. (The system is now in standby mode, and awaiting a key press.)
33.5.2
Key Press Interrupt Scanning Sequence
Perform the following steps to perform a keypad scanning routine:
1. Disable both (depress and release) keypad interrupts.
2. Write 1s to KPP_KPDR[KCD], setting column data to 1s.
3. Configure columns as totem pole outputs (for quick discharging of keypad
capacitance).
4. Configure columns as open-drain.
5. Write a single column to 0, and other columns to 1.
6. Sample row inputs and save data. Multiple key presses can be detected on a single
column.
7. Repeat Steps 2-6 for remaining columns.
8. Return all columns to 0 in preparation for standby mode.
9. Clear KPKD and KPKR status bit(s) by writing to a "1"; set the KPKR synchronizer
chain by writing a "1" to the KPP_KRSS register; and clear the KPKD synchronizer
chain by writing a "1" to the KDSC register.
10. Re-enable the appropriate keypad interrupt(s) so that the KDIE detects a key hold
condition, or the KRIE detects a key-release event.
33.5.3
Additional Comments
The order of key press detection can be done in software only. Therefore, the software
may need to run the scan routines at very short intervals of time per the application's
demands. The reason that such functionality cannot be put in the KPP is that the block is
limited by the number of external pins.
For the keys that require a very precise order (such as game keys), individual GPIO pins
may be more useful.
33.6
KPP Memory Map/Register Definition
The KPP contains four registers.
KPP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2124
NXP Semiconductors

<!-- page 2125 -->

KPP memory map
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
20B_8000
Keypad Control Register (KPP_KPCR)
16
R/W
0000h
33.6.1/2125
20B_8002
Keypad Status Register (KPP_KPSR)
16
R/W
0400h
33.6.2/2126
20B_8004
Keypad Data Direction Register (KPP_KDDR)
16
R/W
0000h
33.6.3/2127
20B_8006
Keypad Data Register (KPP_KPDR)
16
R/W
0000h
33.6.4/2128
33.6.1
Keypad Control Register (KPP_KPCR)
The Keypad Control Register determines which of the eight possible column strobes are
to be open drain when configured as outputs, and which of the eight row sense lines are
considered in generating an interrupt to the core.
It is up to the programmer to ensure that pins being used for functions other than the
keypad are properly disabled. The KPP_KPCR register is byte- or half-word-addressable.
Address: 20B_8000h base + 0h offset = 20B_8000h
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
KCO
KRE
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
KPP_KPCR field descriptions
Field
Description
15–8
KCO
Keypad Column Strobe Open-Drain Enable. Setting a column open-drain enable bit (KCO7-KCO0)
disables the pull-up driver on that pin. Clearing the bit allows the pin to drive to the high state. This bit has
no effect when the pin is configured as an input.
NOTE: Configuration of external port control logic (for example, IOMUX) should be done properly so that
the KPP controls an open-drain enable of the pin.
0
TOTEM_POLE — Column strobe output is totem pole drive.
1
OPEN_DRAIN — Column strobe output is open drain.
KRE
Keypad Row Enable. Setting a row enable control bit in this register enables the corresponding row line to
participate in interrupt generation. Likewise, clearing a bit disables that row from being used to generate
an interrupt. This register is cleared by a reset, disabling all rows. The row-enable logic is independent of
the programmed direction of the pin. Writing a "0" to the data register of the pins configured as outputs will
cause a keypad interrupt to be generated if the row enable associated with that bit is set.
0
Row is not included in the keypad key press detect.
1
Row is included in the keypad key press detect.
Chapter 33 Keypad Port (KPP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2125

<!-- page 2126 -->

33.6.2
Keypad Status Register (KPP_KPSR)
The Keypad Status Register reflects the state of the key press detect circuit. The
KPP_KPSR register is byte- or half-word-addressable.
Address: 20B_8000h base + 2h offset = 20B_8002h
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
KRIE
KDIE
Write
Reset
0
0
0
0
0
1
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
0
0
KPKR
KPKD
Write
KRSS
KDSC
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
KPP_KPSR field descriptions
Field
Description
15–10
Reserved
This read-only field is reserved and always has the value 0.
9
KRIE
Keypad Release Interrupt Enable. The software should ensure that the interrupt for a Key Release event
is masked until it has entered the key pressed state, and vice versa, unless this activity is desired (as
might be the case when a repeated interrupt is to be generated). The synchronizer chains are capable of
being initialized to detect repeated key presses or releases. If they are not initialized when the
corresponding event flag is cleared, false interrupts may be generated for depress (or release) events
shorter than the length of the corresponding chain.
0
No interrupt request is generated when KPKR is set.
1
An interrupt request is generated when KPKR is set.
8
KDIE
Keypad Key Depress Interrupt Enable. Software should ensure that the interrupt for a Key Release event
is masked until it has entered the key pressed state, and vice-versa, unless this activity is desired (as
might be the case when a repeated interrupt is to be generated). The synchronizer chains are capable of
being initialized to detect repeated key presses or releases. If they are not initialized when the
corresponding event flag is cleared, false interrupts may be generated for depress (or release) events
shorter than the length of the corresponding chain.
0
No interrupt request is generated when KPKD is set.
1
An interrupt request is generated when KPKD is set.
7–4
Reserved
This read-only field is reserved and always has the value 0.
3
KRSS
Key Release Synchronizer Set. Self-clear bit. The Key release synchronizer is set by writing a logic one
into this bit.
Reads return a value of "0".
0
No effect
1
Set bits which sets keypad release synchronizer chain
Table continues on the next page...
KPP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2126
NXP Semiconductors

<!-- page 2127 -->

KPP_KPSR field descriptions (continued)
Field
Description
2
KDSC
Key Depress Synchronizer Clear. Self-clear bit. The Key depress synchronizer is cleared by writing a logic
"1" into this bit.
Reads return a value of "0".
0
No effect
1
Set bits that clear the keypad depress synchronizer chain
1
KPKR
Keypad Key Release. The keypad key release (KPKR) status bit is set when all enabled rows are detected
high after synchronization (the KPKR status bit will be set when cleared by a reset). The KPKR bit may be
used to generate a maskable key release interrupt. The key release synchronizer may be set high by
software after scanning the keypad to ensure a known state. Due to the logic function of the release and
depress synchronizer chains, it is possible to see the re-assertion of a status flag (KPKD or KPKR) if it is
cleared by software prior to the system exiting the state it represents.
Reset value of register is "0" as long as reset is asserted. However when reset is de-asserted, the value of
the register depends upon the external row pins and can become "1".
0
No key release detected
1
All keys have been released
0
KPKD
Keypad Key Depress. The keypad key depress (KPKD) status bit is set when one or more enabled rows
are detected low after synchronization. The KPKD status bit remains set until cleared by the software. The
KPKD bit may be used to generate a maskable key depress interrupt. If desired, the software may clear
the key press synchronizer chain to allow a repeated interrupt to be generated while a key remains
pressed. In this case, a new interrupt will be generated after the synchronizer delay (4 cycles of the low
frequency reference clock (ipg_clk_32k) elapses if a key remains pressed. This functionality can be used
to detect a long key press. This allows detection of additional key presses of the same key or other keys.
Due to the logic function of the release and depress synchronizer chains, it is possible to see the re-
assertion of a status flag (KPKD or KPKR) if it is cleared by the software prior to the system exiting the
state it represents.
0
No key presses detected
1
A key has been depressed
33.6.3
Keypad Data Direction Register (KPP_KDDR)
The bits in the KPP_KDDR control the direction of the keypad port pins. The upper eight
bits in the register affect the pins designated as column strobes, while the lower eight bits
affect the row sense pins. Setting any bit in this register configures the corresponding pin
as an output. Clearing any bit in this register configures the corresponding port pin as an
input. For the Keypad Row DDR, an internal pull-up is enabled if the corresponding bit is
clear. This register is cleared by a reset, configuring all pins as inputs. The KPP_KDDR
register is byte- or half-word addressable.
NOTE
When a pin is used as row pin for keypad purposes, all
corresponding pull-ups should be enabled at the upper level (for
example, IOMUX) when the bit in KRDD is cleared.
Chapter 33 Keypad Port (KPP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2127

<!-- page 2128 -->

Address: 20B_8000h base + 4h offset = 20B_8004h
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
KCDD
KRDD
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
KPP_KDDR field descriptions
Field
Description
15–8
KCDD
Keypad Column Data Direction Register. Setting a bit configures the corresponding COLn pin as an output
(where n = 7 through 0).
0
INPUT — COLn pin is configured as an input.
1
OUTPUT — COLn pin is configured as an output.
KRDD
Keypad Row Data Direction. Setting a bit configures the corresponding ROWn pin as an output (where n =
7 through 0).
0
INPUT — ROWn pin configured as an input.
1
OUTPUT — ROWn pin configured as an output.
33.6.4
Keypad Data Register (KPP_KPDR)
This 16-bit register is used to access the column and row data. Data written to this
register is stored in an internal latch, and for each pin configured as an output, the stored
data is driven onto the pin. A read of this register returns the value on the pin for those
bits configured as inputs. Otherwise, the value read is the value stored in the register.
The KPP_KPDR register is byte- or half-word addressable. This register is not initialized
by a reset. Valid data should be written to this register before any bits are configured as
outputs.
Address: 20B_8000h base + 6h offset = 20B_8006h
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
KCD
KRD
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
KPP_KPDR field descriptions
Field
Description
15–8
KCD
Keypad Column Data. A read of these bits returns the value on the pin for those bits configured as inputs.
Otherwise, the value read is the value stored in the register.
0 Read/Write "0" from/to column ports
1 Read/Write "1" from/to column ports
KRD
Keypad Row Data. A read of these bits returns the value on the pin for those bits configured as inputs.
Otherwise, the value read is the value stored in the register.
0 Read/Write "0" from/to row ports
1 Read/Write "1" from/to row ports
KPP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2128
NXP Semiconductors

<!-- page 2129 -->

KPP_KPDR field descriptions (continued)
Field
Description
Chapter 33 Keypad Port (KPP)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2129

<!-- page 2130 -->

KPP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2130
NXP Semiconductors

