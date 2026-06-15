# Chapter 53: Touch Screen Controller (TSC)

> Nguồn: `IMX6ULLRM.pdf` — trang 3537–3558

<!-- page 3537 -->

Chapter 53
Touch Screen Controller (TSC)
53.1
Overview
This block describes the Touch Screen Controller (TSC), which is used for ADC and
touch screen analogue block.
TSC is responsible for providing control of ADC and touch screen analogue block to
form a touch screen system, which achieves function of touch detection and touch
location detection. The controller utilizes ADC hardware trigger function and control
switches in touch screen analogue block. The controller only supports 4-wire of 5-wire
screen touch modes.
Figure 53-1. TSC block diagram
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3537

<!-- page 3538 -->

TSC
Ain[4:0]
PAD [4:0]
Switches
control
Detect_en
Detect
HW_Trigger
HW_SEL
ADC
TSC_ANA
(containing 5 instances)
ADC_CONV
ADC_COCO
53.1.1
Features
The features of TSC controller are following.
• Configure registers: 32-bit, fully support sky-blue bus interface
• 4-wire or 5-wire mode of touch screen
• Low power wake up functions
• ADC average function and custom 8-bit, 10-bit, and 12-bit conversion result
• Custom pre-charge and de-glitch threshold time setting
• Total control five analogue groups of switches
• Fully asynchronous interface to ADC and analogue switches
• Easy software operation
• Software takes control of operation flow
• Strong debug functions—enable software recognize the IP as a trnasparent box and
operation ouput directly
• Software reset function
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3538
NXP Semiconductors

<!-- page 3539 -->

53.2
Functional Description
This block works with ADC and TSC analogue to form a touch screen system. The
system is responsible to detect touch on screen and measure the coordinate of the touch
point. The touch screen controller, which is at the heart of the system, given control to
TSC analogue and ADC. TSC analogue provides positive or negative voltage to the
screen if the touch screen controller provides relevant signals. The ADC convert
coordinates value if requested by touch screen controller.
53.2.1
Operating modes
The TSC can be worked in the following modes.
53.2.1.1
Idle
The TSC always stays at idle status if finish a coordinate measurement. The TSC only
starts to detect a touch or starts to measure coordinate value if set the start_sen bit. The
TSC returns to idle status after finish current task if disable bit is set by software.
53.2.1.2
Pre-charge
Pre-charge is a preparation for detection stage. Before detection stage, the upper layer of
screen is required to charge to positive high. The time required for the pre-charge can be
set in the pre-charge_timer.
53.2.1.3
Detection
Detection is a stage to sense touch detect on the screen. This stage is initialed a delay (set
by pre-charge_timer) in order to wait enough time for the lower screen layer to achieve
even-potential status. After the TSC send out detect enable signal to detect signal from
analogue, once receiving the signal, TSC starts to measure coordinates or waiting for the
instruction from software according to the value of auto_measure. If auto_measure is set
then the TSC automatically measures coordinates after detect a touch. Otherwise TSC
Chapter 53 Touch Screen Controller (TSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3539

<!-- page 3540 -->

waits for software order after detects a touch (and generates an interrupt). The software
can choose to drop the measure (and return back to idle) by setting drop_measure, or start
the measure by setting start_measure.
53.2.1.4
Measurement
During the measure stage, the TSC hardware gives control to TSC analogue and ADC.
No software operation is needed. If requesting average function, do average configuration
for ADC.
53.2.1.5
Data valid check
After measure the coordinate value, TSC do a touch detects again. If no touch has been
detected, then previous measured coordinates’ value is invalid. Otherwise, the measured
coordinates’ value is valid.
53.2.1.6
Interrupt
Each interrupt provides three software interface bits: interrupt enable, interrupt signal
enable, and interrupt signal.
53.2.1.7
Reset
The TSC has two resets: ipg_reset_b and sw_rst. The ipg_reset_b reset is a hardware
reset, which resets all registers in TSC block. While the sw_rst is a software reset, which
resets every register except ips directly access ones.
53.2.1.8
Debug mode
The TSC provides fully software control signals. Once debug_en has been set, then all
TSC outputs will be controlled by software. Software can also observe all TSC inputs
through debug interface. Furthermore, the debug registers also provides current state
machine states. Software can always check the current hardware state.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3540
NXP Semiconductors

<!-- page 3541 -->

53.2.2
Configuration
53.2.2.1
TSC configurations
The following tables provide 4-wire and 5-wire screen touch modes.
Table 53-1. 4-wire screen touch mode
wiper
ynlr
ypll
xnur
xpul
X measurement
OFF
OFF
OFF
LOW
HIGH
Y measurement
OFF
LOW
HIGH
OFF
OFF
Pre-charge
OFF
OFF
OFF
HIGH (200K, PULL
UP)
HIGH (200K, PULL
UP)
Intermediate
OFF
OFF
OFF
OFF
HIGH (200K)
Touch screen
dection
OFF
LOW
LOW
OFF
HIGH (200K)
Table 53-2. 5-wire screen touch mode
wiper
ynlr
ypll
xnur
xpul
X measurement
OFF
LOW
HIGH
LOW
HIGH
Y measurement
OFF
LOW
LOW
HIGH
HIGH
Pre-charge
HIGH (200K, PULL
UP)
OFF
OFF
OFF
OFF
Intermediate1
HIGH (200K)
OFF
OFF
OFF
OFF
Touch screen
dection
HIGH (200K)
LOW
LOW
OFF
OFF
1.
All other intermediate states switche to OFF.
53.2.2.2
TSC-ADC-TSC analogue configuration
The touch screen controller needs to co-work with ADC and TSC analogue.
The ADC is responsible for analogue value conversion. Following tables show the
channels that the ADC used.
Table 53-3. 4-wire screen touch mode
X measurement
Channel 1
Connects to TSC ana YNLR
Table continues on the next page...
Chapter 53 Touch Screen Controller (TSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3541

<!-- page 3542 -->

Table 53-3. 4-wire screen touch mode (continued)
Y measurement
Channel 3
Connects to TSC ana YNUR
Table 53-4. 5-wire screen touch mode
X measurement
Channel 0
Connects to TSC ana WIPER
Y measurement
Channel 0
Connects to TSC ana WIPER
53.2.2.3
TSC, TSC analogue and ADC connection
The following table describes the connections among the TSC, TSC analogue, and ADC.
Table 53-5. TSC, TSC analogue and ADC connection
TSC controller ports
TSC analogue IP ports
TSC analogue system
integration instance Name
ADC Ain ports
wiper_pull_up
pu_en
1
Ain [0]
wiper-200k_pull_up
pull_up-200k_en
wiper_pull_down
pd_en
ynlr_pull_up
pu_en
2
Ain [1]
ynlr_200k_pull_up
pull_up_200k_en
ynlr_pull_down
pd_en
ypll_pull_up
pu_en
3
Ain [2]
ypll_200k_pull_up
pull_up_200k_en
ypll_pull_down
pd_en
xnur_pull_up
pu_en
4
Ain [3]
xnur_200k_pull_up
pull_up_200k_en
xnur_pull_down
pd_en
xpul_pull_up
pu_en
5
Ain [4]
xpul_200k_pull_up
pull_up_200k_en
xpul_pull_down
pd_en
53.2.2.4
TSC and GPIO
From TSC point of view, it does not care what kinds of PAD used. It can use digital pad
or analogue pad.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3542
NXP Semiconductors

<!-- page 3543 -->

Table 53-6. The ports used in TSC and GPIO
TSC function ports
TSC analogue instance
ADC Ain pin
GPIO ports
wiper
1
Ain [0]
GPIO1_IO00
ynlr
2
Ain [1]
GPIO1_IO01
ypll
3
Ain [2]
GPIO1_IO02
xnur
4
Ain [3]
GPIO1_IO03
xpul
5
Ain [4]
GPIO1_IO04
NOTE
For the PAD used for TSC, make sure the PAD behavior , such
as a wire only connects to the Pin and TSC analogue switches.
For the PAD used for GPIO, for example, has a keeper to
prevent the GPIO pad working from a wire only connects the
Pin and TSC. In such condition, disable keeper when TSC
working.
53.2.2.5
ADC-TSC co-working
The TSC is designed to work with the ADC. Two IP must work together to achieve the
correct functions. The coordinate work includes two steps:
1. TSC starts ADC
TSC sends two signals: trigger and hardware trigger select signal: HWTS[4:0].
ADC regards triggers as clock to capture the select signal: HWTS. The details of
information about trigger and HWTS is show in the ADC hardware trigger chapter.
The TSC hardware makes sure that the HWTS signals ready one clock cycles before
sending trigger signals. Make sure that the trigger delay is less than HWTS delay +
one clock cycle.
The TSC send HWTS as in the following table:
TSC 4-wire mode
TSC 5-wire mode
x-coordinate measure
HWTS = 5'b01000
HWTS = 5'b10000
y-coordinate measure
HWTS = 5'b00010
HWTS = 5'b10000
Chapter 53 Touch Screen Controller (TSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3543

<!-- page 3544 -->

TSC HWTS[4:0] connects to the ADC HWTS[4:0]. The integration change will lead
change in driver implementation. On ADC side, HWTS = 1 << x indicates the x logic
channel is selected to start hardware ADC conversion. Configure ADC_HCx to
configure x logic channel and conversion will store in ADC_Rx.
Each ADC hardware trigger logic channel can be configured to one of many physical
channels. The details of the ADC configuration, refer to the ADC hardware trigger
chapter. Software driver configures the physical ADC. A sample configuration is
shown in the following table.
TSC 4-wire mode
TSC 5-wire mode
x-coordinate measure
ADC measures channel 1 or 2, so
configure ADC_HC3[ADCH] to 1 or 2.
ADC measure channel 0, so configure
ADC_HC[4] to 0.
y-coordinate measure
ADC measures channel3 or 4, so
configure ADC_HC1[ADCH] to 3 or 4.
ADC measures channel 0, so
configure ADC_HC[4] to 0.
Before TSC starts work, software driver configure ADC_HCx. TSC hardware
automatically sends trigger and HWTS at the correct time.
2. ADC sends back converted value and complete signals to TSC.
When ADC finishes conversion, the ADC would send a complete signal to TSC. A
set of handshake signals between ADC and TSC makes sure that the TSC could
receive complete signals, store correct ADC converted value, and clear ADC coco
signals at correct order. All parts of this step are automatically done by hardware.
NOTE
For different ADC conversion modes, such 8-bit, 10-bit,
12-bit mode, average mode, please configure in ADC
registers.
53.3
TSC Memory Map/Register Definition
The TSC Memory Map and Register Definition is described in the following section.
TSC memory map
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
204_0000
PS Input Buffer Address (TSC_BASIC_SETTING)
32
R/W
0000_0000h
53.3.1/3545
204_0010
PS Input Buffer Address
(TSC_PS_INPUT_BUFFER_ADDR)
32
R/W
0000_0000h
53.3.2/3546
Table continues on the next page...
TSC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3544
NXP Semiconductors

<!-- page 3545 -->

TSC memory map (continued)
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
204_0020
Flow Control (TSC_FLOW_CONTROL)
32
R/W
0000_0000h
53.3.3/3547
204_0030
Measure Value (TSC_MEASEURE_VALUE)
32
R
0000_0000h
53.3.4/3548
204_0040
Interrupt Enable (TSC_INT_EN)
32
R/W
0000_0000h
53.3.5/3549
204_0050
Interrupt Signal Enable (TSC_INT_SIG_EN)
32
R/W
0000_0000h
53.3.6/3550
204_0060
Intterrupt Status (TSC_INT_STATUS)
32
R/W
0000_0000h
53.3.7/3551
204_0070
TSC_DEBUG_MODE
32
R/W
0000_0000h
53.3.8/3553
204_0080
TSC_DEBUG_MODE2
32
R/W
0000_0000h
53.3.9/3555
53.3.1
PS Input Buffer Address (TSC_BASIC_SETTING)
Address: 204_0000h base + 0h offset = 204_0000h
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
MEASURE_DELAY_TIME
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
MEASURE_DELAY_TIME
0
4_5_
WIRE
0
AUTO_
MEASURE
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
TSC_BASIC_SETTING field descriptions
Field
Description
31–8
MEASURE_
DELAY_TIME
Measure Delay Time
Before X-axis or Y-axis measurement, the screen need some time before even potential distribution ready.
7–5
Reserved
This read-only field is reserved and always has the value 0.
4
4_5_WIRE
4/5 Wire detection
4-Wire Detection Mode or 5-Wire Detection Mode
0
4-Wire Detection Mode
1
5-Wire Detection Mode
Table continues on the next page...
Chapter 53 Touch Screen Controller (TSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3545

<!-- page 3546 -->

TSC_BASIC_SETTING field descriptions (continued)
Field
Description
3–1
Reserved
This read-only field is reserved and always has the value 0.
0
AUTO_
MEASURE
Auto Measure
This field indicates after detect touch, whether automatic start measurement. SW must make sure that the
detect interrupt should be disable. This bit is not HW self-clear.
0
Disable Auto Measure
1
Auto Measure
53.3.2
PS Input Buffer Address (TSC_PS_INPUT_BUFFER_ADDR)
Address: 204_0000h base + 10h offset = 204_0010h
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
PRE_CHARGE_TIME
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
TSC_PS_INPUT_BUFFER_ADDR field descriptions
Field
Description
PRE_CHARGE_
TIME
Auto Measure
This field indicates after detect touch, whether automatic start measurement. SW must make sure that the
detect interrupt should be disable. This bit is not HW self-clear.
0
Disable Auto Measure
1
Auto Measure
TSC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3546
NXP Semiconductors

<!-- page 3547 -->

53.3.3
Flow Control (TSC_FLOW_CONTROL)
Address: 204_0000h base + 20h offset = 204_0020h
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
DISABLE
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
START_SENSE
0
DROP_
MEASURE
0
START_
MEASURE
0
SW_
RST
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
TSC_FLOW_CONTROL field descriptions
Field
Description
31–17
Reserved
This read-only field is reserved and always has the value 0.
16
DISABLE
This bit is for SW disable registers. After set this bit, the hardware returns to idle status after finish the
current state operation. SW must check the SW_IDLE bit to confirm that the controller has return to idle
status. It’s a HW self-clean bit.
0
Leave HW state machine control
1
SW set to idle status
15–13
Reserved
This read-only field is reserved and always has the value 0.
12
START_SENSE
Start Sense
It’s a HW self-clean bit.
0
Stay at idle status
1
Start sense detection and (if auto_measure set to 1) measure after detect a touch
11–9
Reserved
This read-only field is reserved and always has the value 0.
8
DROP_
MEASURE
Drop Measure
This field indicates whether start measure X/Y coordinate value after detect a touch It’s a HW self-clean
bit.
0
Do not drop measure for now
1
Drop the measure and controller return to idle status
Table continues on the next page...
Chapter 53 Touch Screen Controller (TSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3547

<!-- page 3548 -->

TSC_FLOW_CONTROL field descriptions (continued)
Field
Description
7–5
Reserved
This read-only field is reserved and always has the value 0.
4
START_
MEASURE
Start Measure
This field indicates whether start measure X/Y coordinate value after detect a touch It’s a self-clean bit.
0
Do not start measure for now
1
Start measure the X/Y coordinate value
3–1
Reserved
This read-only field is reserved and always has the value 0.
0
SW_RST
Soft Reset
This is a synchronization reset, which reset all HW registers.
NOTE: All SW accessible registers would keep as it original setting Software reset would be self-clear.
53.3.4
Measure Value (TSC_MEASEURE_VALUE)
Address: 204_0000h base + 30h offset = 204_0030h
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
X_VALUE
0
Y_VALUE
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
TSC_MEASEURE_VALUE field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27–16
X_VALUE
X Value
Coordinate value
NOTE: It is an ADC conversion value, SW need to convert it to fit screen size.
15–12
Reserved
This read-only field is reserved and always has the value 0.
Y_VALUE
Y Value
Y coordinate value, note, it is an ADC conversion value, SW need to convert it to fit screen size
TSC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3548
NXP Semiconductors

<!-- page 3549 -->

53.3.5
Interrupt Enable (TSC_INT_EN)
Address: 204_0000h base + 40h offset = 204_0040h
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
IDLE_SW_INT_
EN
0
DETECT_INT_
EN
0
MEASURE_INT_
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
TSC_INT_EN field descriptions
Field
Description
31–13
Reserved
This read-only field is reserved and always has the value 0.
12
IDLE_SW_INT_
EN
Idle Software Interrupt Enable
This field indicates whether enable the software return to idle status interrupt. This interrupt is generated if
the controller has return to idle status. This bit is only valid if disable bit in flow control register set to 1’b1.
0
Disable idle software interrupt
1
Enable idle software interrupt
11–5
Reserved
Reserved
This read-only field is reserved and always has the value 0.
4
DETECT_INT_
EN
Detect Interrupt Enable
This field indicates whether enable the detect interrupt. This interrupt is generated if there is a touch detect
after pre-charge ready.
0
Disable detect interrupt
1
Enable detect interrupt
3–1
Reserved
This read-only field is reserved and always has the value 0.
0
MEASURE_INT_
EN
Measure Interrupt Enable
This field indicates whether enable the measure interrupt. This interrupt is generated after the touch
detection which follows measurement.
0
Disable measure
Chapter 53 Touch Screen Controller (TSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3549

<!-- page 3550 -->

53.3.6
Interrupt Signal Enable (TSC_INT_SIG_EN)
Address: 204_0000h base + 50h offset = 204_0050h
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
IDLE_SW_SIG_
EN
0
VALID_SIG_EN
0
DETECT_SIG_
EN
0
MEASURE_SIG_
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
TSC_INT_SIG_EN field descriptions
Field
Description
31–13
Reserved
This read-only field is reserved and always has the value 0.
12
IDLE_SW_SIG_
EN
Idle Software Signal Enable
This field indicates whether enable the software return to idle status. This signal is generated if the
controller has return to idle status. This bit is only valid if disable bit in flow control register set to 1’b1.
0
Disable idle software signal
1
Enable idle software signal
11–9
Reserved
This read-only field is reserved and always has the value 0.
8
VALID_SIG_EN
Valid Signal Enable
This field indicates whether enable the valid signal. This field generated at the same time with
MEASURE_SIG_EN.
0
Disable valid signal
1
Enable valid signal
7–5
Reserved
This read-only field is reserved and always has the value 0.
4
DETECT_SIG_
EN
Detect Signal Enable
This field indicates whether enable the detect signal.
0
Disable detect signal
1
Enable detect signal
Table continues on the next page...
TSC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3550
NXP Semiconductors

<!-- page 3551 -->

TSC_INT_SIG_EN field descriptions (continued)
Field
Description
3–1
Reserved
This read-only field is reserved and always has the value 0.
0
MEASURE_SIG_
EN
Measure Signal Enable
This field indicates whether enable the measure signal.
53.3.7
Intterrupt Status (TSC_INT_STATUS)
Address: 204_0000h base + 60h offset = 204_0060h
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
IDLE_SW
0
VALID
0
DETECT
0
MEASURE
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
TSC_INT_STATUS field descriptions
Field
Description
31–13
Reserved
This read-only field is reserved and always has the value 0.
12
IDLE_SW
Idle Software
This field indicates whether the state machine return to idle status. This signal is generated if the controller
has return to idle status. This bit is only valid if disable bit in flow control register set to 1’b1.
0
Haven’t return to idle status
1
Already return to idle status
11–9
Reserved
This read-only field is reserved and always has the value 0.
8
VALID
Valid Signal
This field indicats whether the measure value is valid. This field generated at the same time with
MEASURE_SIG.
0
There is no touch detected after measurement, indicates that the measured value is not valid
1
There is touch detection after measurement, indicates that the measure is valid
7–5
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Chapter 53 Touch Screen Controller (TSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3551

<!-- page 3552 -->

TSC_INT_STATUS field descriptions (continued)
Field
Description
4
DETECT
Detect Signal
This field indicates whether there is a detect signal.
0
Does not exist a detect signal
1
Exist detect signal
3–1
Reserved
This read-only field is reserved and always has the value 0.
0
MEASURE
Measure Signal
This field indicates whether there is a measure signal.
0
Does not exist a measure signal
1
Exist a measure signal
TSC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3552
NXP Semiconductors

<!-- page 3553 -->

53.3.8
TSC_DEBUG_MODE
Address: 204_0000h base + 70h offset = 204_0070h
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
DEBUG_EN
0
ADC_COCO_CLEAR_DISABLE
ADC_COCO_CLEAR
TRIGGER
0
EXT_HWTS
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
ADC_COCO
ADC_CONV_VALUE
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
Chapter 53 Touch Screen Controller (TSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3553

<!-- page 3554 -->

TSC_DEBUG_MODE field descriptions
Field
Description
31–29
Reserved
This read-only field is reserved and always has the value 0.
28
DEBUG_EN
Debug Enable
The RO registers in debug_mode and debug_mode2 always reflect the latest value and is not controlled
by this bit. All RW SW bits are controlled by this bit.
0
Enable debug mode
1
Disable debug mode
27
Reserved
This read-only field is reserved and always has the value 0.
26
ADC_COCO_
CLEAR_
DISABLE
ADC COCO Clear Disable
This bit could prevent TSC HW generates an ADC COCO clear signal.
NOTE: This bit does not effect ADC_COCO_CLEAR bit.
0
Allow TSC hardware generates ADC COCO clear
1
Prevent TSC from generate ADC COCO clear signal
—
—
25
ADC_COCO_
CLEAR
ADC Coco Clear
Original ADC coco only clear is system read conv result from IPS bus. However, TSC read conv result
directly from ADC to lower SW load, so that ADC requires TSC generates a clear signal.
0
No ADC COCO clear
1
Set ADC COCO clear
24
TRIGGER
Trigger
Hardware trigger signal to ADC
0
No hardware trigger signal
1
Hardware trigger signal, the signal must last at least 1 ips clock period
23–21
Reserved
This read-only field is reserved and always has the value 0.
20–16
EXT_HWTS
Hardware Trigger Select Signal
Hardware trigger select signal, select which channel to start conversion.
15–13
Reserved
This read-only field is reserved and always has the value 0.
12
ADC_COCO
ADC COCO Signal
This signal is generated by ADC.
ADC_CONV_
VALUE
ADC Conversion Value
This signal is generated by ADC.
TSC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3554
NXP Semiconductors

<!-- page 3555 -->

53.3.9
TSC_DEBUG_MODE2
Address: 204_0000h base + 80h offset = 204_0080h
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
DE_GLITCH
DETECT_ENABLE_FIVE_WIRE
0
DETECT_ENABLE_FOUR_WIRE
INTERMEDIATE
STATE_MACHINE
0
DETECT_FIVE_WIRE
DETECT_FOUR_WIRE
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
WIPER_200K_PULL_UP
WIPER_PULL_UP
WIPER_PULL_DOWN
YNLR_200K_PULL_UP
YNLR_PULL_UP
YNLR_PULL_DOWN
YPLL_200K_PULL_UP
YPLL_PULL_UP
YPLL_PULL_DOWN
XNUR_200K_PULL_UP
XNUR_PULL_UP
XNUR_PULL_DOWN
XPUL_200K_PULL_UP
XPUL_PULL_UP
XPUL_PULL_DOWN
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
Chapter 53 Touch Screen Controller (TSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3555

<!-- page 3556 -->

TSC_DEBUG_MODE2 field descriptions
Field
Description
31
Reserved
This read-only field is reserved and always has the value 0.
30–29
DE_GLITCH
This field indicates glitch threshold. The threshold is defined by number of clock cycles. A detect signal is
only valid if it is exist longer than threshold. Any signal transfer through detect and length is smaller than
threshold is regards as a glitch.
00
• Normal function: 0x1fff ipg clock cycles;
• Low power mode: 0x9 low power clock cycles
01
• Normal function: 0xfff ipg clock cycles;
• Low power mode: :0x7 low power clock cycles
10
• Normal function: 0x7ff ipg clock cycles;
• Low power mode:0x5 low power clock cycles
11
• Normal function: 0x3 ipg clock cycles;
• Low power mode:0x3 low power clock cycles
28
DETECT_
ENABLE_FIVE_
WIRE
Detect Enable Five Wire
0
Do not read five wire detect value, read default value from analogue
1
Read five wire detect status from analogue
27–25
Reserved
This read-only field is reserved and always has the value 0.
24
DETECT_
ENABLE_FOUR_
WIRE
Detect Enable Four Wire
0
Do not read four wire detect value, read default value from analogue
1
Read four wire detect status from analogue
23
INTERMEDIATE
Intermediate State
It’s an intermediate state, between two state machine states, in order to provide better timing for analogue.
It lasts for only once cycle. Intermediate state exists after pre-charge, detect, x- measure, y-measure, and
2nd-pre-charge, 2nd-detect. Note, the intermediate after pre-charge and 2nd-pre-charge is different.
0
Not in intermedia
1
Intermedia
22–20
STATE_
MACHINE
State Machine
000
Idle
001
Pre-charge
010
Detect
011
X-measure
100
Y-measure
101
Pre-charge
110
Detect
19–18
Reserved
This read-only field is reserved and always has the value 0.
17
DETECT_FIVE_
WIRE
Detect Five Wire
This field in only valid when the touch controller is under detect mode. That is not in idle.
NOTE: It is in measure mode, not per-charge mode. This is an asynchronous signal.
Table continues on the next page...
TSC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3556
NXP Semiconductors

<!-- page 3557 -->

TSC_DEBUG_MODE2 field descriptions (continued)
Field
Description
0
No detect signal
1
Yes, there is a detect on the touch screen.
16
DETECT_FOUR_
WIRE
Detect Four Wire
This field in only valid when the touch controller is under detect mode. That is not in idle.
NOTE: It is in measure mode, not per-charge mode. This is an asynchronous signal.
0
No detect signal
1
Yes, there is a detect on the touch screen.
15
Reserved
This read-only field is reserved and always has the value 0.
14
WIPER_200K_
PULL_UP
Wiper Wire 200K Pull Up Switch
This is a control signal of this wiper wire 200k pull up switch.
0
Close the switch
1
Open up the switch
13
WIPER_PULL_
UP
Wiper Wire Pull Up Switch
This is a control signal of this switch.
0
Close the switch
1
Open up the switch
12
WIPER_PULL_
DOWN
Wiper Wire Pull Down Switch
This is a control signal of this wiper wire pull down switch.
0
Close the switch
1
Open up the switch
11
YNLR_200K_
PULL_UP
YNLR Wire 200K Pull Up Switch
This is a control signal of this YNLR wire 200K pull up switch.
0
Close the switch
1
Open up the switch
10
YNLR_PULL_UP
YNLR Wire Pull Up Switch
This is a control signal of this YNLR wire pull up switch.
0
Close the switch
1
Open up the switch
9
YNLR_PULL_
DOWN
YNLR Wire Pull Down Switch
This is a control signal of this YNLR wire pull down switch.
0
Close the switch
1
Open up the switch
8
YPLL_200K_
PULL_UP
YPLL Wire 200K Pull Up Switch
This is a control signal of this YPLL wire 200k pull up switch.
Table continues on the next page...
Chapter 53 Touch Screen Controller (TSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3557

<!-- page 3558 -->

TSC_DEBUG_MODE2 field descriptions (continued)
Field
Description
0
Close the switch
1
Open up the switch
7
YPLL_PULL_UP
YPLL Wire Pull Up Switch
This is a control signal of this YPLL wire pull up switch.
0
Close the switch
1
Open the switch
6
YPLL_PULL_
DOWN
YPLL Wire Pull Down Switch
This is a control signal of this YPLL wire pull down switch.
0
Close the switch
1
Open up the switch
5
XNUR_200K_
PULL_UP
XNUR Wire 200K Pull Up Switch
This is a control signal of this XNUR wire 200K pull up switch.
0
Close the switch
1
Open up the switch
4
XNUR_PULL_UP
XNUR Wire Pull Up Switch
This is a control signal of this XNUR Wire Pull Up Switch.
0
Close the switch
1
Open up the switch
3
XNUR_PULL_
DOWN
XNUR Wire Pull Down Switch
This is a control signal of this XNUR Wire Pull Down Switch.
0
Close the switch
1
Open up the switch
2
XPUL_200K_
PULL_UP
XPUL Wire 200K Pull Up Switch
This is a control signal of this XPUL Wire 200K Pull Up Switch.
0
Close the switch
1
Open up the switch
1
XPUL_PULL_UP
XPUL Wire Pull Up Switch
This is a control signal of this XPUL Wire Pull Up Switch.
0
Close the switch
1
Open up the switch
0
XPUL_PULL_
DOWN
XPUL Wire Pull Down Switch
This is a control signal of this XPUL wire pull down switch.
0
Close the switch
1
Open up the switch
TSC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3558
NXP Semiconductors

